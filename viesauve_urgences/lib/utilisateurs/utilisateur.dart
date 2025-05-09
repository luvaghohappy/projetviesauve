import 'dart:convert';
import 'package:http/http.dart' as http;
import '../const.dart' as AppConstants;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  String searchQuery = '';

  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final secteurIdStr = prefs.getString('secteur_id');
      final fonction = prefs.getString('fonction') ?? '';

      if (secteurIdStr == null || fonction.isEmpty) {
        throw Exception('Secteur ID ou fonction manquants');
      }

      final secteurId = int.tryParse(secteurIdStr);
      if (secteurId == null) {
        throw Exception('Secteur ID invalide');
      }

      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}selectuser.php"),
        body: {'secteur_id': secteurId.toString(), 'fonction': fonction},
      );

      if (response.statusCode == 200) {
        try {
          final List<dynamic> decoded = json.decode(response.body);
          setState(() {
            items = List<Map<String, dynamic>>.from(decoded);
            filteredItems = items;
          });
        } catch (jsonError) {
          print("Erreur lors du décodage JSON: $jsonError");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réponse invalide du serveur')),
          );
        }
      } else {
        print('Erreur HTTP: Code ${response.statusCode}');
        throw Exception('Échec du chargement');
      }
    } catch (e) {
      print('Erreur catch générale: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec du chargement des données')),
      );
    }
  }

  void _filterItems(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredItems = items;
      } else {
        filteredItems =
            items.where((user) {
              final name = '${user['noms']}';
              return name.toLowerCase().contains(query.toLowerCase());
            }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Utilisateurs de vie sauve',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 10,
            right: 10,
            child: SizedBox(
              width: 300,
              child: TextField(
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
              SizedBox(width: 20),
          Positioned.fill(
            top: 80,
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              thickness: 12.0,
              radius: const Radius.circular(10),
              trackVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  thickness: 12.0,
                  radius: const Radius.circular(10),
                  trackVisibility: true,
                  child: SingleChildScrollView(
                    controller: _verticalScrollController,
                    scrollDirection: Axis.vertical,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25),
                      child: Card(
                        elevation: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DataTable(
                            columnSpacing: 20.0,
                            headingRowColor: MaterialStateProperty.all(
                              Colors.blue.shade200,
                            ),
                            columns: const [
                              DataColumn(label: Text('#')),
                              DataColumn(label: Text('Noms')),
                              DataColumn(label: Text('Sexe')),
                              DataColumn(label: Text('Date naissance')),
                              DataColumn(label: Text('Secteur')),
                              DataColumn(label: Text('Adresse')),
                              DataColumn(label: Text('telephone')),
                              DataColumn(label: Text('Email')),
                              DataColumn(label: Text('Etat_civil')),
                              DataColumn(label: Text('Groupe_sanguin')),
                              DataColumn(label: Text('Allergies')),
                              DataColumn(label: Text('maladies')),
                              DataColumn(label: Text('medicaments')),
                              DataColumn(label: Text('Contact_urgence_nom')),
                              DataColumn(label: Text('Contact_urgence_lien')),
                              DataColumn(label: Text('Contact_urgence_tel')),
                              DataColumn(label: Text('Enfants')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: List<DataRow>.generate(filteredItems.length, (
                              index,
                            ) {
                              final user = filteredItems[index];
                              final enfants =
                                  user['enfants'] as List<dynamic>? ?? [];

                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(user['noms'] ?? '')),
                                  DataCell(Text(user['sexe'] ?? '')),
                                  DataCell(Text(user['date_naissance'] ?? '')),
                                  DataCell(Text(user['nom_secteur'] ?? '')),
                                  DataCell(Text(user['adresse'] ?? '')),
                                  DataCell(Text(user['telephone'] ?? '')),
                                  DataCell(Text(user['email'] ?? '')),
                                  DataCell(Text(user['etat_civil'] ?? '')),
                                  DataCell(Text(user['groupe_sanguin'] ?? '')),
                                  DataCell(Text(user['allergies'] ?? '')),
                                  DataCell(Text(user['maladies'] ?? '')),
                                  DataCell(Text(user['medicaments'] ?? '')),
                                  DataCell(
                                    Text(user['contact_urgence_nom'] ?? ''),
                                  ),
                                  DataCell(
                                    Text(user['contact_urgence_lien'] ?? ''),
                                  ),
                                  DataCell(
                                    Text(user['contact_urgence_tel'] ?? ''),
                                  ),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children:
                                          enfants.isNotEmpty
                                              ? enfants.map((e) {
                                                return Text(
                                                  "${e['noms']} (${e['date_naissance']}${e['sexe']})",
                                                );
                                              }).toList()
                                              : [const Text('Aucun')],
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        // 🔴 Bouton Alerte
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          margin: EdgeInsets.only(right: 8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              // Action : Voir alertes
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.notifications,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  "Alerte",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            color: Colors.white,
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              // Action : Révoquer droit
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.lock_person_outlined,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  "Révoquer",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
