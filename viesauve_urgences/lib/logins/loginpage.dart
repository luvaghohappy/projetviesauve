import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../const.dart' as AppConstants;

class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController identifiantController = TextEditingController();
  final TextEditingController motDePasseController = TextEditingController();

  bool loading = false;
  String error = '';
  bool _isPasswordHidden = true;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final url = Uri.parse('${AppConstants.baseUrl}getagent.php');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "identifiant": identifiantController.text.trim(),
          "mot_de_passe": motDePasseController.text.trim(),
        }),
      );

      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"]) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          final user = data["user"];

          await prefs.setString('role', data["role"]);
          await prefs.setString('noms', user["noms"]);
          await prefs.setString('email', user["email"]);
          await prefs.setString('code', user["CODE"]);
          await prefs.setString('fonction', user["Fonction"]);
          await prefs.setString('secteur_id', user["secteur_id"].toString());
          await prefs.setString('serviceType', user["serviceType"] ?? '');
          await prefs.setString('image_path', user["image_path"]);

          final role = data["role"];
          if (role == "SuperAdmin") {
            Navigator.pushReplacementNamed(context, '/superadmin');
          } else if (role == "Administrateur") {
            Navigator.pushReplacementNamed(context, '/admin');
          } else if (role == "Operateur") {
            // Redirige vers l'accueil des opérateurs
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            // Affiche une erreur si ce n'est pas un opérateur
            setState(() {
              error = "Accès refusé.";
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          }
        } else {
          setState(() {
            error = data["message"] ?? "Identifiants incorrects.";
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error)));
        }
      } else {
        setState(() {
          error = "Erreur du serveur : ${response.statusCode}";
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      setState(() {
        error = "Erreur de connexion : $e";
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      print("Erreur de login: $e");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login2.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            height: h * 0.5,
            width: 600,
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'VIESAUVE LOGIN',
                  style: TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: identifiantController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.tealAccent),
                    labelText: 'Email ou CODE',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: motDePasseController,
                  obscureText: _isPasswordHidden,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.tealAccent),
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.tealAccent,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      '✔ Remember me',
                      style: TextStyle(color: Colors.white60),
                    ),
                    Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "LOGIN",
                      style: TextStyle(letterSpacing: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
