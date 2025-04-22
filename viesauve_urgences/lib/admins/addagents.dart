import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../const.dart' as AppConstants;

class AddAgentsPages extends StatefulWidget {
  const AddAgentsPages({super.key});

  @override
  State<AddAgentsPages> createState() => _AddAgentsPagesState();
}

class _AddAgentsPagesState extends State<AddAgentsPages> {
  final TextEditingController txtnoms = TextEditingController();
  final TextEditingController txtemail = TextEditingController();
  final TextEditingController txtcode = TextEditingController();
  final TextEditingController txtmot_de_passe = TextEditingController();
  TextEditingController secteurIdController = TextEditingController();
  final List<String> fonctions = ['Operateur', 'Agent'];
  final List<String> serviceType = ['Pompier', 'Police', 'Ambulancier', 'Chat'];
  final ImagePicker picker = ImagePicker();
  File? _imageFile;
  Uint8List? _webImage;
  bool _isPasswordHidden = true;

  Future<void> chargerInfosDepuisPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final secteur = prefs.getString('secteur_id') ?? '';

    setState(() {
      secteurIdController.text = secteur;
    });
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // Lire l'image en mémoire pour Flutter Web
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } else {
      print('No image selected.');
    }
  }

  String? sexe;
  String? selectedFonction;
  String? selectedServiceType;
  List<Map<String, dynamic>> secteurs = [];

  @override
  void initState() {
    super.initState();
    chargerInfosDepuisPrefs();
  }

  Future<void> enregistrerAdmin() async {
    // Impression des valeurs pour debug
    print("Image: ${_imageFile?.path}");
    print("Noms: ${txtnoms.text.trim()}");
    print("Email: ${txtemail.text.trim()}");
    print("Code: ${txtcode.text.trim()}");
    print("Mot de passe: ${txtmot_de_passe.text.trim()}");
    print("Fonction sélectionnée: $selectedFonction");
    print("Secteur ID sélectionné: ${secteurIdController.text.trim()}");
    print("ServiceType sélectionné: $selectedServiceType");
    print("Sexe sélectionné: $sexe");

    if ((kIsWeb && _webImage == null) ||
        (!kIsWeb && _imageFile == null) ||
        txtnoms.text.trim().isEmpty ||
        txtemail.text.trim().isEmpty ||
        txtcode.text.trim().isEmpty ||
        txtmot_de_passe.text.trim().isEmpty ||
        selectedFonction == null ||
        selectedFonction!.isEmpty ||
        secteurIdController.text.trim().isEmpty ||
        selectedServiceType == null ||
        selectedServiceType!.isEmpty ||
        sexe == null ||
        sexe!.isEmpty) {
      print("Erreur: Un ou plusieurs champs sont vides.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs sont obligatoires')),
      );
      return;
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppConstants.baseUrl}insert_agent.php"),
    );

    request.fields['noms'] = txtnoms.text;
    request.fields['email'] = txtemail.text;
    request.fields['CODE'] = txtcode.text;
    request.fields['mot_de_passe'] = txtmot_de_passe.text;
    request.fields['Fonction'] = selectedFonction!;
    request.fields['secteur_id'] = secteurIdController.text;
    request.fields['serviceType'] = selectedServiceType!;
    request.fields['sexe'] = sexe!;

    if (kIsWeb && _webImage != null) {
      request.fields['image_base64'] = base64Encode(_webImage!);
    } else if (_imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseJson = jsonDecode(responseBody);

      if (responseJson['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("noms", txtnoms.text);
        prefs.setString("Fonction", selectedFonction!);
        prefs.setString("secteur_id", secteurIdController.text);
        prefs.setString("serviceType", selectedServiceType!);
        prefs.setString("sexe", sexe!);
        prefs.setString("image_path", responseJson["image_path"]);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Administrateur ajouté avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${responseJson['error']}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l’enregistrement')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Card(
            elevation: 5,
            child: Container(
              height: h * 0.89,
              width: 800,
              child: Padding(
                padding: const EdgeInsets.all(50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: Text(
                        'ENREGISTREMENT ADMINISTRATEUR',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 30)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: getImage,
                          child: Container(
                            width: 150,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              image:
                                  _imageFile != null || _webImage != null
                                      ? DecorationImage(
                                        image:
                                            kIsWeb
                                                ? MemoryImage(_webImage!)
                                                : FileImage(_imageFile!)
                                                    as ImageProvider,
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:
                                _imageFile == null && _webImage == null
                                    ? const Icon(
                                      Icons.add_a_photo,
                                      size: 20,
                                      color: Colors.white,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(width: 60),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              textField("Noms", txtnoms),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text("Sexe : "),
                                  Radio<String>(
                                    value: "M",
                                    groupValue: sexe,
                                    onChanged:
                                        (val) => setState(() => sexe = val),
                                  ),
                                  const Text("Masculin"),
                                  Radio<String>(
                                    value: "F",
                                    groupValue: sexe,
                                    onChanged:
                                        (val) => setState(() => sexe = val),
                                  ),
                                  const Text("Féminin"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        textField("Email", txtemail),
                        textField("Code", txtcode),
                      ],
                    ),

                    Row(
                      children: [
                        dropdownField("Fonction", fonctions, selectedFonction, (
                          value,
                        ) {
                          setState(() => selectedFonction = value);
                        }),
                        SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: secteurIdController,
                              enabled: false,
                              decoration: InputDecoration(
                                hintText: secteurIdController.text,
                                labelText: 'N° Secteur',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        dropdownField(
                          "Service",
                          serviceType,
                          selectedServiceType,
                          (value) {
                            setState(() => selectedServiceType = value);
                          },
                        ),
                        SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextField(
                              controller: txtmot_de_passe,
                              obscureText: _isPasswordHidden,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordHidden
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordHidden = !_isPasswordHidden;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: 700,
                      child: ElevatedButton(
                        onPressed: enregistrerAdmin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Enregistrer",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget textField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: 300,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dropdownField(
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SizedBox(
        width: 300,
        child: DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items:
              items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
