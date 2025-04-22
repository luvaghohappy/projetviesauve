import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:viesauve_urgences/admins/addagents.dart';
import 'package:viesauve_urgences/logins/loginpage.dart';
import '../const.dart' as AppConstants;

class AdminPage extends StatefulWidget {
  final bool isDarkMode;

  const AdminPage({super.key, required this.isDarkMode});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Widget _selectedPage = Statuts();

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

    return Container(
      width: 240,
      color: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            onTap: () => handleItemSelected(0, Statuts()),
          ),
          SideMenuItem(
            icon: Icons.person_2_outlined,
            label: 'Administrateurs',
            isDarkMode: widget.isDarkMode,
            isActive: selectedIndex == 1,
            onTap: () => handleItemSelected(1, const AddAgentsPages()),
          ),
          SideMenuItem(
            icon: Icons.list_alt,
            label: 'Listes',
            isDarkMode: widget.isDarkMode,
            isActive: selectedIndex == 2,
            onTap: () => handleItemSelected(2, const AddAgentsPages()),
          ),
          SideMenuItem(
            icon: Icons.report,
            label: 'Rapports',
            isDarkMode: widget.isDarkMode,
            isActive: selectedIndex == 3,
            onTap: () => handleItemSelected(3, AddAgentsPages()),
          ),
          SideMenuItem(
            icon: Icons.login_outlined,
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
    final activeColor = isDarkMode ? Colors.blue : Colors.orange;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: isActive ? activeColor : textColor),
        title: Text(
          label,
          style: TextStyle(color: isActive ? activeColor : textColor),
        ),
        tileColor: isActive ? activeColor.withOpacity(0.2) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}

class Statuts extends StatefulWidget {
  @override
  State<Statuts> createState() => _StatutsState();
}

class _StatutsState extends State<Statuts> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SizedBox(height: 16),
          Text("01 - 25 March, 2020", style: TextStyle(color: Colors.grey)),
          SizedBox(height: 32),
          Placeholder(fallbackHeight: 100), // Future Chart
          SizedBox(height: 32),
          Text(
            "Today",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 16),
          Placeholder(fallbackHeight: 200), // Future list
        ],
      ),
    );
  }
}
