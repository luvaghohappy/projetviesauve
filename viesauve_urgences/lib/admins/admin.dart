import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viesauve_urgences/admins/addagents.dart';
import 'package:viesauve_urgences/logins/loginpage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import '../const.dart' as AppConstants;
import '../utilisateurs/utilisateur.dart';

class AdminPage extends StatefulWidget {
  final bool isDarkMode;

  const AdminPage({super.key, required this.isDarkMode});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget _selectedPage = DashboardPage();

  void _onMenuItemSelected(Widget page) {
    setState(() {
      _selectedPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SideMenu(
            onItemSelected: _onMenuItemSelected,
            isDarkMode: widget.isDarkMode,
          ),
          SizedBox(width: 20),
          Expanded(child: _selectedPage),
        ],
      ),
    );
  }
}

class SideMenu extends StatefulWidget {
  final Function(Widget) onItemSelected;
  final bool isDarkMode;

  const SideMenu({
    super.key,
    required this.onItemSelected,
    required this.isDarkMode,
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  String? noms;
  String? email;
  String? fonction;
  String? imagePath;
  int selectedIndex = 0; // Indice de l'élément sélectionné

  void handleItemSelected(int index, Widget page) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(page);
  }

  @override
  void initState() {
    super.initState();
    chargerInfosDepuisPrefs();
  }

  Future<void> chargerInfosDepuisPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      noms = prefs.getString('noms') ?? '';
      email = prefs.getString('email') ?? '';
      fonction = prefs.getString('fonction') ?? '';
      imagePath = prefs.getString('image_path') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = "${AppConstants.baseUrl}${imagePath}";
    print("Image URL: $imageUrl");

    return Card(
      elevation: 5,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue,
              backgroundImage:
                  imageUrl != null ? NetworkImage(imageUrl!) : null,
              onBackgroundImageError: (_, __) {},
              child:
                  imageUrl == null
                      ? const Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(noms ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(email ?? ''), Text(fonction ?? '')],
              ),
            ),

            const SizedBox(height: 50),
            SideMenuItem(
              icon: Icons.dashboard,
              label: 'Dashboard',
              isDarkMode: widget.isDarkMode,
              isActive: selectedIndex == 0,
              onTap: () => handleItemSelected(0, DashboardPage()),
            ),
            SideMenuItem(
              icon: Icons.support_agent,
              label: 'Agents',
              isDarkMode: widget.isDarkMode,
              isActive: selectedIndex == 1,
              onTap: () => handleItemSelected(1, const AddAgentsPages()),
            ),
            SideMenuItem(
              icon: Icons.person,
              label: 'Utilisateurs',
              isDarkMode: widget.isDarkMode,
              isActive: selectedIndex == 2,
              onTap: () => handleItemSelected(2, const UsersPage()),
            ),
            SideMenuItem(
              icon: Icons.report,
              label: 'Rapports',
              isDarkMode: widget.isDarkMode,
              isActive: selectedIndex == 3,
              onTap: () => handleItemSelected(3, AddAgentsPages()),
            ),
            SideMenuItem(
              icon: Icons.logout_outlined,
              label: 'Deconnexion',
              isDarkMode: widget.isDarkMode,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyLogin()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget menuItem(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.white60, size: 20),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class SideMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDarkMode;

  const SideMenuItem({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor =
        isDarkMode
            ? const Color.fromARGB(255, 8, 88, 153)
            : const Color.fromARGB(255, 8, 88, 153);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isActive ? activeColor : textColor),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isActive ? activeColor : textColor,
          ),
        ),
        tileColor: isActive ? activeColor.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<TableInfo> tableInfoList = [];
  List<Color> colors = [Colors.blue, Colors.green, Colors.purple];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Récupération des données enregistrées
      final secteurId = prefs.getString('secteur_id');
      final fonction = prefs.getString('fonction');

      // Vérification que les données sont bien présentes
      if (secteurId == null || fonction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Données administrateur manquantes")),
        );
        return;
      }

      final response = await http.post(
        Uri.parse("${AppConstants.baseUrl}state_admin.php"),
        body: {'secteur_id': secteurId, 'fonction': fonction},
      );

      if (response.statusCode == 200) {
        final body = response.body;
        print("Response body: $body");
        final decodedResponse = json.decode(body);

        if (decodedResponse['status'] == 'success') {
          print("Utilisateurs: ${decodedResponse['utilisateurs']}");
          print("Agents: ${decodedResponse['agents']}");
          print("Alertes: ${decodedResponse['alertes']}");

          setState(() {
            tableInfoList = [
              TableInfo(
                tableName: "Utilisateurs",
                recordCount: decodedResponse['utilisateurs'],
              ),
              TableInfo(
                tableName: "Agents",
                recordCount: decodedResponse['agents'],
              ),
              TableInfo(
                tableName: "Alertes",
                recordCount: decodedResponse['alertes'],
              ),
            ];
          });
        } else {
          String message = decodedResponse['message'] ?? 'Erreur inconnue';
          print("Message in response: $message");
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } else {
        throw Exception('Erreur lors du chargement');
      }
    } catch (e) {
      print("Error while fetching data: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Échec du chargement')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 20),

            // Résumé Cards (Row en haut)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children:
                    tableInfoList.asMap().entries.map((entry) {
                      int index = entry.key;
                      TableInfo info = entry.value;
                      return Container(
                        width: 200,
                        height: 130,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              info.recordCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              info.tableName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 30),

            // Statistiques (Column: Bar chart + Pie chart)
            Expanded(
              child: Row(
                children: [
                  // Bar Chart Card
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: BarChart(
                        BarChartData(
                          maxY: 50,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int index = value.toInt();
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      tableInfoList.isNotEmpty &&
                                              index < tableInfoList.length
                                          ? tableInfoList[index].tableName
                                          : '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  List<int> yTitles = [10, 20, 30, 40, 50];
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Text(
                                      yTitles.contains(value.toInt())
                                          ? value.toInt().toString()
                                          : '',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barGroups: List.generate(tableInfoList.length, (i) {
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: tableInfoList[i].recordCount.toDouble(),
                                  color: colors[i % colors.length],
                                  width: 15,
                                ),
                              ],
                            );
                          }),
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Répartition par table",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Partie principale : légendes à gauche, PieChart à droite
                          Expanded(
                            child: Row(
                              children: [
                                // Légendes à gauche (en colonne)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    tableInfoList.length,
                                    (i) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 12,
                                              height: 12,
                                              color: colors[i % colors.length],
                                            ),
                                            const SizedBox(width: 8),
                                            Text(tableInfoList[i].tableName),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 20),

                                // PieChart à droite
                                Expanded(
                                  child: PieChart(
                                    PieChartData(
                                      sections: List.generate(
                                        tableInfoList.length,
                                        (i) {
                                          return PieChartSectionData(
                                            color: colors[i % colors.length],
                                            value:
                                                tableInfoList[i].recordCount
                                                    .toDouble(),
                                            title:
                                                '${tableInfoList[i].recordCount}',
                                            radius: 60,
                                            titleStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 40,
                                    ),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}

class TableInfo {
  final String tableName;
  final int recordCount;

  TableInfo({required this.tableName, required this.recordCount});

  factory TableInfo.fromJson(Map<String, dynamic> json) {
    return TableInfo(
      tableName: json['table_name'] ?? 'Unknown',
      recordCount: int.tryParse(json['record_count'].toString()) ?? 0,
    );
  }
}
