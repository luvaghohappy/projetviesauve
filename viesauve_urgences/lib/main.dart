import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'admins/admin.dart';
import 'agents/agents.dart';
import 'const.dart' as AppConstants show baseUrl;
import 'logins/loginpage.dart';
import 'superadmin/super.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyLogin(),
      routes: {
        '/home': (context) => FirstPage(),
        '/superadmin':
            (context) =>
                SuperAdminPage(isDarkMode: _themeMode == ThemeMode.dark),
        '/admin':
            (context) => AdminPage(isDarkMode: _themeMode == ThemeMode.dark),
        '/agent': (context) => AgentsPages(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  String? noms;
  String? serviceType;
  String? fonction;
  String? secteurId;
  String? imagePath;
  List<Map<String, dynamic>> alertes = [];
  Timer? _timer; // Declare the timer

  @override
  void initState() {
    super.initState();
    fetchData();
    chargerInfosPrefs();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> chargerInfosPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      noms = prefs.getString('noms') ?? '';
      serviceType = prefs.getString('serviceType') ?? '';
      secteurId = prefs.getString('secteur_id') ?? '';
      fonction = prefs.getString('fonction') ?? '';
      imagePath = prefs.getString('image_path') ?? '';
    });
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${AppConstants.baseUrl}selectalerte.php?serviceType=$serviceType&secteur_id=$secteurId",
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          alertes = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load items');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec du chargement des alertes')),
      );
    }
  }

  Map<String, dynamic>? selectedAlerte;
  bool showJson = false;
  bool showMap = false;

  @override
  Widget build(BuildContext context) {
    final imageUrl = "${AppConstants.baseUrl}${imagePath}";
    print("Image URL: $imageUrl");

    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.blue,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              onBackgroundImageError: (exception, stackTrace) {
                print("Erreur image : $exception");
              },
              child:
                  imageUrl == null
                      ? const Icon(Icons.person, size: 20, color: Colors.white)
                      : null,
            ),

            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  noms ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  fonction ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: _showAgentDialog,
            child: const Text('📋 Agents disponibles'),
          ),
        ],
      ),

      body: Row(
        children: [
          // Sidebar
          Container(
            width: 360,
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        '🚨 ALERTES',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 20),
                      Text(
                        serviceType ?? '',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: alertes.length,
                    itemBuilder: (context, index) {
                      final alerte = alertes[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[300],
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'U${alerte['user_id']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(alerte['messages'].toString()),
                            ],
                          ),
                          subtitle: GestureDetector(
                            onTap: () => setState(() => showMap = true),
                            child: Text(
                              alerte['locations'].toString(),
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 12,
                            child: Text(
                              alerte['etat'].toString()[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap:
                              () => setState(() {
                                selectedAlerte = alerte;
                                showJson = false;
                              }),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Contenu principal
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                children: [
                  Card(
                    child: Container(
                      height: h * 0.5,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: Offset(0, 4),
                            blurStyle: BlurStyle.normal,
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child:
                          selectedAlerte == null
                              ? const Center(
                                child: Text('Sélectionnez une alerte'),
                              )
                              : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      title: Text(
                                        'Détails de l’alerte: ${selectedAlerte!['messages']}',
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed:
                                            () => setState(
                                              () => showJson = !showJson,
                                            ),
                                        child: const Text('Voir plus'),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: const Text(
                                            'Agents à proximité',
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {},
                                          child: const Text('Tous les postes'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (showJson)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(jsonEncode(selectedAlerte)),
                      ),
                    ),
                  if (showMap)
                    Container(
                      height: 200,
                      color: Colors.blue[100],
                      alignment: Alignment.center,
                      child: const Text('🗺️ Carte de localisation ici'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAgentDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agents disponibles'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ListTile(title: Text('Agent A')),
                ListTile(title: Text('Agent B')),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Envoyer'),
              ),
            ],
          ),
    );
  }
}
