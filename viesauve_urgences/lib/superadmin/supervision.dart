import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:html' as html;
import '../const.dart' as AppConstants;

class SupervisionPage extends StatefulWidget {
  @override
  _SupervisionPageState createState() => _SupervisionPageState();
}

class _SupervisionPageState extends State<SupervisionPage> {
  String? selectedTable;
  String? selectedSecteur;
  List<String> tables = ['utilisateurs', 'agents', 'alertes'];
  List<String> secteurs = [];
  List<Map<String, dynamic>> items = [];
  late ScrollController _horizontalScrollController;
  late ScrollController _verticalScrollController;

  @override
  void initState() {
    super.initState();
    fetchSecteurs();
    _horizontalScrollController = ScrollController();
    _verticalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  void fetchSecteurs() async {
    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}get_secteurs.php"),
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        secteurs = List<String>.from(jsonData);
      });
    } else {
      print("Erreur de chargement des secteurs : ${response.statusCode}");
    }
  }

  void fetchData() async {
    if (selectedTable == null || selectedTable!.isEmpty) {
      print("Aucune table sélectionnée");
      return;
    }

    String url =
        "${AppConstants.baseUrl}get_table_data.php?table=$selectedTable";

    if (selectedSecteur != null && selectedSecteur!.isNotEmpty) {
      url += "&secteur=$selectedSecteur";
    }

    print("URL appelée : $url");

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey("error")) {
        print("Erreur serveur : ${decoded["error"]}");
        return;
      }

      setState(() {
        items = List<Map<String, dynamic>>.from(decoded);
      });
    } else {
      print("Erreur HTTP : ${response.statusCode}");
    }
  }

  void printData() {
    // Utilise le package 'printing' ou autre méthode pour imprimer.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Supervision')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      hint: Text("Choisir une table"),
                      decoration: InputDecoration(
                        labelText: "Tables",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: selectedTable,
                      onChanged: (value) {
                        setState(() {
                          selectedTable = value;
                          selectedSecteur = null;
                          items.clear();
                        });
                        fetchData();
                      },
                      items:
                          tables.map((table) {
                            return DropdownMenuItem(
                              value: table,
                              child: Text(table),
                            );
                          }).toList(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButtonFormField<String>(
                      hint: Text("Choisir un secteur"),
                      decoration: InputDecoration(
                        labelText: "Secteurs",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      value: selectedSecteur,
                      onChanged: (value) {
                        setState(() {
                          selectedSecteur = value;
                        });
                        fetchData();
                      },
                      items:
                          secteurs.map((secteur) {
                            return DropdownMenuItem(
                              value: secteur,
                              child: Text(secteur),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),
            Expanded(
              child:
                  items.isEmpty
                      ? Center(child: Text("Aucune donnée"))
                      : Stack(
                        children: [
                          Scrollbar(
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
                                    padding: const EdgeInsets.only(
                                      left: 25,
                                      right: 80,
                                      bottom: 60,
                                    ),
                                    child: Card(
                                      elevation: 4,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey,
                                            width: 2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: DataTable(
                                          columnSpacing: 20.0,
                                          headingRowColor:
                                              MaterialStateProperty.all(
                                                Colors.blue.shade200,
                                              ),
                                          columns:
                                              items[0].keys.map((key) {
                                                return DataColumn(
                                                  label: Text(
                                                    key,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                          rows:
                                              items.map((row) {
                                                return DataRow(
                                                  cells:
                                                      row.values.map((value) {
                                                        return DataCell(
                                                          Text(
                                                            value.toString(),
                                                          ),
                                                        );
                                                      }).toList(),
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: ElevatedButton.icon(
                              onPressed: printData,
                              icon: Icon(Icons.print),
                              label: Text("Imprimer"),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
