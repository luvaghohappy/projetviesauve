import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../const.dart' as AppConstants;

class RapportsPages extends StatefulWidget {
  const RapportsPages({super.key});

  @override
  State<RapportsPages> createState() => _RapportsPagesState();
}

class _RapportsPagesState extends State<RapportsPages> {
  String? selectedTable;
  String? selectedSecteur;
  List<String> tables = [
    'utilisateurs',
    'agents',
    'alertes',
    'administrateurs',
  ];
  List<String> secteurs = [];
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> filteredItems = [];
  DateTime? startDate;
  DateTime? endDate;
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
    }
  }

  void fetchData() async {
    if (selectedTable == null) return;

    String url =
        "${AppConstants.baseUrl}get_table_rapport.php?table=$selectedTable";
    if (selectedSecteur != null && selectedSecteur!.isNotEmpty) {
      url += "&secteur=$selectedSecteur";
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is List) {
        setState(() {
          items = List<Map<String, dynamic>>.from(decoded);
          filteredItems = List<Map<String, dynamic>>.from(decoded);
        });
      }
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        _filterItems();
      });
    }
  }

  void _filterItems() {
    if (startDate != null && endDate != null) {
      filteredItems =
          items.where((item) {
            final createdAt =
                DateTime.tryParse(item['created_at'] ?? '') ?? DateTime(1900);
            return createdAt.isAfter(startDate!.subtract(Duration(days: 1))) &&
                createdAt.isBefore(endDate!.add(Duration(days: 1)));
          }).toList();
    } else {
      filteredItems = List.from(items);
    }
  }

  Future<void> _generatePdf() async {
    if (filteredItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucun élément à imprimer.')),
      );
      return;
    }

    final robotoRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final robotoBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Bold.ttf'),
    );

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Rapport',
                  style: pw.TextStyle(font: robotoBold, fontSize: 24),
                ),
                pw.SizedBox(height: 20),
                pw.Table.fromTextArray(
                  headers: filteredItems[0].keys.toList(),
                  data:
                      filteredItems
                          .map(
                            (item) =>
                                item.values.map((e) => e.toString()).toList(),
                          )
                          .toList(),
                  headerStyle: pw.TextStyle(font: robotoBold),
                  cellStyle: pw.TextStyle(font: robotoRegular),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _generatePdf,
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
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
          ),
          Expanded(
            child:
                items.isEmpty
                    ? const Center(child: Text("Aucune donnée disponible."))
                    : Scrollbar(
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
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DataTable(
                                    columnSpacing: 20.0,
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.blue.shade200,
                                    ),
                                    columns:
                                        items[0].keys
                                            .map(
                                              (key) =>
                                                  DataColumn(label: Text(key)),
                                            )
                                            .toList(),
                                    rows:
                                        filteredItems
                                            .map(
                                              (item) => DataRow(
                                                cells:
                                                    item.values
                                                        .map(
                                                          (e) => DataCell(
                                                            Text(e.toString()),
                                                          ),
                                                        )
                                                        .toList(),
                                              ),
                                            )
                                            .toList(),
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
