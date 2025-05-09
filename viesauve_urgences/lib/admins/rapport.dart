// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'dart:html' as html;

// class RapportsAdminPages extends StatefulWidget {
//   const RapportsAdminPages({super.key});

//   @override
//   State<RapportsAdminPages> createState() => _RapportsAdminPagesState();
// }

// class _RapportsAdminPagesState extends State<RapportsAdminPages> {
//   List<Map<String, dynamic>> items = [];
//   List<Map<String, dynamic>> filteredItems = [];
//   String searchQuery = '';
//   DateTime? startDate;
//   DateTime? endDate;

//   Future<void> fetchData() async {
//     try {
//       final response = await http.get(
//         Uri.parse("http://192.168.43.149:81/projetSV/get_data.php"),
//       );

//       setState(() {
//         items = List<Map<String, dynamic>>.from(json.decode(response.body));
//         filteredItems = items;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to load items'),
//         ),
//       );
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchData(); // Load initial data when the app starts
//   }

//   void _filterItems() {
//     setState(() {
//       filteredItems = items.where((user) {
//         final userDate = DateTime.tryParse(user['created_at'] ?? '');
//         final service = user['service']?.toLowerCase() ?? '';

//         bool matchesService = service.contains(searchQuery.toLowerCase());
//         bool matchesDate = true;

//         if (startDate != null && endDate != null && userDate != null) {
//           // On utilise `isAfter` pour inclure `startDate` et `isBefore` pour inclure `endDate`.
//           matchesDate =
//               (userDate.isAfter(startDate!.subtract(Duration(seconds: 1))) ||
//                       userDate.isAtSameMomentAs(startDate!)) &&
//                   (userDate.isBefore(endDate!.add(Duration(days: 1))) ||
//                       userDate.isAtSameMomentAs(endDate!));
//         }

//         return matchesService && matchesDate;
//       }).toList();
//     });
//   }

//   Future<void> _selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         startDate = picked.start;
//         endDate = picked.end;
//       });
//       _filterItems();
//       _showFilteredResultsDialog(context);
//     }
//   }

//   void _showFilteredResultsDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Résultats Filtrés'),
//           content: filteredItems.isEmpty
//               ? const Center(
//                   child: Text(
//                     'Aucun Element trouvé a cette date',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                 )
//               : SizedBox(
//                   width: double.maxFinite,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: DataTable(
//                       columns: const [
//                         DataColumn(label: Text('Nom')),
//                         DataColumn(label: Text('Postnom')),
//                         DataColumn(label: Text('Prenom')),
//                         DataColumn(label: Text('Sexe')),
//                         DataColumn(label: Text('Locations')),
//                         DataColumn(label: Text('Date_Heure')),
//                         DataColumn(label: Text('Services')),
//                       ],
//                       rows: List.generate(filteredItems.length, (index) {
//                         final item = filteredItems[index];
//                         return DataRow(
//                           cells: [
//                             DataCell(Text(item['nom'] ?? '')),
//                             DataCell(Text(item['postnom'] ?? '')),
//                             DataCell(Text(item['prenom'] ?? '')),
//                             DataCell(Text(item['sexe'] ?? '')),
//                             DataCell(
//                               Text(
//                                 item['locations'] ?? '',
//                               ),
//                             ),
//                             DataCell(Text(item['created_at'] ?? '')),
//                             DataCell(Text(item['service'] ?? '')),
//                           ],
//                         );
//                       }),
//                     ),
//                   ),
//                 ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Quitter'),
//             ),
//             ElevatedButton(
//               onPressed: _generatePdf,
//               child: const Text('Imprimer'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _generatePdf() async {
//     print("Generating PDF...");

//     // Vérifier si filteredItems contient des données
//     if (filteredItems.isEmpty) {
//       print("No items to print. FilteredItems is empty.");
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content:
//               Text('Aucun élément à imprimer. Veuillez appliquer un filtre.'),
//         ),
//       );
//       return;
//     }

//     try {
//       // Afficher les éléments filtrés dans la console
//       print("Filtered items for PDF:");
//       for (var item in filteredItems) {
//         print(item);
//       }

//       // Charger les polices
//       final robotoRegular =
//           pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
//       final robotoBold =
//           pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Bold.ttf'));

//       final pdf = pw.Document();

//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text(
//                   'Rapport',
//                   style: pw.TextStyle(
//                     fontSize: 24,
//                     fontWeight: pw.FontWeight.bold,
//                     font: robotoBold,
//                   ),
//                 ),
//                 pw.SizedBox(height: 20),
//                 pw.Table.fromTextArray(
//                   headers: [
//                     'Nom',
//                     'Postnom',
//                     'Prenom',
//                     'Sexe',
//                     'Locations',
//                     'Date_Heure',
//                     'Services'
//                   ],
//                   headerStyle: pw.TextStyle(
//                     font: robotoBold,
//                   ),
//                   data: filteredItems.map((item) {
//                     return [
//                       item['nom'] ?? '',
//                       item['postnom'] ?? '',
//                       item['prenom'] ?? '',
//                       item['sexe'] ?? '',
//                       item['locations'] ?? '',
//                       item['created_at'] ?? '',
//                       item['service'] ?? '',
//                     ];
//                   }).toList(),
//                   cellStyle: pw.TextStyle(
//                     font: robotoRegular,
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       );

//       print("PDF generated successfully.");

//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//       );
//     } catch (e) {
//       print("Error generating PDF: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Rapport'),
//         actions: [
//           IconButton(
//               icon: const Icon(Icons.print),
//               onPressed: () {
//                 _generatePdf();
//               }),
//         ],
//       ),
//       body: Column(children: [
//         Padding(
//           padding: const EdgeInsets.all(10.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               SizedBox(
//                 width: 300,
//                 child: TextField(
//                   onChanged: (query) {
//                     searchQuery = query;
//                     _filterItems();
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Rechercher par service...',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                     ),
//                     prefixIcon: const Icon(Icons.search),
//                   ),
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () => _selectDateRange(context),
//                 child: const Text('Sélectionner une plage de dates'),
//               ),
//             ],
//           ),
//         ),
//         filteredItems.isEmpty
//             ? const Center(
//                 child: Text(
//                   'Aucun Element trouvé a cette date',
//                   style: TextStyle(fontSize: 18),
//                 ),
//               )
//             : Expanded(
//                 child: SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: DataTable(
//                       columns: const [
//                         DataColumn(label: Text('Nom')),
//                         DataColumn(label: Text('Postnom')),
//                         DataColumn(label: Text('Prenom')),
//                         DataColumn(label: Text('Sexe')),
//                         DataColumn(label: Text('Locations')),
//                         DataColumn(label: Text('Date_Heure')),
//                         DataColumn(label: Text('Services')),
//                       ],
//                       rows: List.generate(filteredItems.length, (index) {
//                         final item = filteredItems[index];
//                         return DataRow(
//                           cells: [
//                             DataCell(Text(item['nom'] ?? '')),
//                             DataCell(Text(item['postnom'] ?? '')),
//                             DataCell(Text(item['prenom'] ?? '')),
//                             DataCell(Text(item['sexe'] ?? '')),
//                             DataCell(
//                               Text(
//                                 item['locations'] ?? '',
//                               ),
//                             ),
//                             DataCell(Text(item['created_at'] ?? '')),
//                             DataCell(Text(item['service'] ?? '')),
//                           ],
//                         );
//                       }),
//                     ),
//                   ),
//                 ),
//               ),
//       ]),
//     );
//   }
// }
