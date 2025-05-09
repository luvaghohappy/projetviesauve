import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:viesauve_urgences/logins/loginpage.dart';
import 'const.dart' as AppConstants show baseUrl;
import 'package:geolocator/geolocator.dart';

import 'utilisateurs/utilisateur.dart';

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
  Map<String, dynamic>? selectedUserData;
  Map<String, dynamic>? selectedAlerte;

  Timer? _timer;
  bool showJson = false;
  double? latitude;
  double? longitude;

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
    _timer?.cancel();
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

  Future<Map<String, dynamic>> fetchUserDetails(String userId) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}get_user_details.php'),
      body: {'user_id': userId},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur de chargement des données utilisateur');
    }
  }

  void _showMapDialog(BuildContext context, double lat, double lng) async {
    GoogleMapController? mapController;
    Marker? userMarker;

    Position position = await Geolocator.getCurrentPosition();
    LatLng userLatLng = LatLng(position.latitude, position.longitude);

    Stream<Position> positionStream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            positionStream.listen((pos) {
              setState(() {
                userMarker = Marker(
                  markerId: MarkerId('user'),
                  position: LatLng(pos.latitude, pos.longitude),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure,
                  ),
                );
                mapController?.animateCamera(
                  CameraUpdate.newLatLng(LatLng(pos.latitude, pos.longitude)),
                );
              });
            });

            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SizedBox(
                width: 900,
                height: 900,
                child: Column(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(lat, lng),
                            zoom: 14,
                          ),
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                          markers: {
                            Marker(
                              markerId: MarkerId('alert'),
                              position: LatLng(lat, lng),
                            ),
                            if (userMarker != null) userMarker!,
                          },
                          myLocationEnabled: false,
                          zoomControlsEnabled: true,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            print("👮‍♂️ Bouton 'Agent à proximité' cliqué");
                          },
                          icon: Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                          ),
                          label: Text("Agent à proximité"),
                        ),
                        SizedBox(width: 10),
                        TextButton.icon(
                          onPressed: () {
                            _showAgentDialog();
                          },
                          icon: Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                          ),
                          label: Text("Afficher Agent"),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = "${AppConstants.baseUrl}${imagePath ?? ''}";
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
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
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.menu, color: Colors.black),
            onSelected: (value) {
              switch (value) {
                case 0:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UsersPage()),
                  );
                  break;
                case 1:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyMenuPage()),
                  );
                  break;
                case 2:
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyLogin()),
                  );
                  break;
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<int>>[
                  PopupMenuItem<int>(
                    value: 0,
                    child: Row(
                      children: const [
                        Icon(Icons.person, size: 15, color: Colors.black),
                        SizedBox(width: 8),
                        Text('Utilisateurs'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 1,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.support_agent,
                          size: 15,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text('Agents'),
                      ],
                    ),
                  ),
                  PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout_outlined,
                          size: 15,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text('Deconnexion'),
                      ],
                    ),
                  ),
                ],
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
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                'U${alerte['user_id']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 10),
                              Text(alerte['messages'].toString()),
                            ],
                          ),
                          subtitle: Text(alerte['locations'].toString()),
                          trailing: CircleAvatar(
                            backgroundColor: Colors.red,
                            radius: 12,
                            child: Text(
                              alerte['etat'].toString()[0].toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          onTap: () async {
                            setState(() {
                              selectedAlerte = alerte;
                              showJson = false;
                            });

                            final userData = await fetchUserDetails(
                              alerte['user_id'].toString(),
                            );

                            setState(() {
                              selectedUserData = userData;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Content view
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            selectedAlerte == null
                                ? Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Center(
                                    child: Text(
                                      'Sélectionnez une alerte',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                )
                                : Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '🧾 Alerte de U${selectedAlerte!['user_id']}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        'Message : ${selectedAlerte!['messages']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          print(
                                            "🟢 Bouton 'Localisation' cliqué",
                                          );

                                          final loc =
                                              selectedAlerte!['locations'];
                                          print(
                                            "📍 Valeur brute de 'locations': $loc",
                                          );

                                          if (loc != null &&
                                              loc.startsWith('POINT(') &&
                                              loc.endsWith(')')) {
                                            final pointStr = loc.substring(
                                              6,
                                              loc.length - 1,
                                            ); // enlève POINT( )
                                            final parts = pointStr.split(
                                              ' ',
                                            ); // sépare longitude et latitude
                                            print(
                                              "🔍 Coordonnées extraites: $parts",
                                            );

                                            final lng = double.tryParse(
                                              parts[0].trim(),
                                            );
                                            final lat = double.tryParse(
                                              parts[1].trim(),
                                            );

                                            print("📌 Latitude: $lat");
                                            print("📌 Longitude: $lng");

                                            if (lat != null && lng != null) {
                                              print(
                                                "✅ Coordonnées valides. Affichage de la carte...",
                                              );

                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    content: SizedBox(
                                                      width: 900,
                                                      height: 900,
                                                      child: Column(
                                                        children: [
                                                          Expanded(
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    12,
                                                                  ),
                                                              child: GoogleMap(
                                                                initialCameraPosition:
                                                                    CameraPosition(
                                                                      target:
                                                                          LatLng(
                                                                            lat,
                                                                            lng,
                                                                          ),
                                                                      zoom: 14,
                                                                    ),
                                                                markers: {
                                                                  Marker(
                                                                    markerId:
                                                                        MarkerId(
                                                                          'alert',
                                                                        ),
                                                                    position:
                                                                        LatLng(
                                                                          lat,
                                                                          lng,
                                                                        ),
                                                                  ),
                                                                },
                                                                onMapCreated:
                                                                    (
                                                                      GoogleMapController
                                                                      controller,
                                                                    ) {},
                                                                myLocationEnabled:
                                                                    false,
                                                                zoomControlsEnabled:
                                                                    true,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          Row(
                                                            children: [
                                                              TextButton.icon(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                  print(
                                                                    "👮‍♂️ Bouton 'Agent à proximité' cliqué",
                                                                  );
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .person_pin_circle,
                                                                  color:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                                label: Text(
                                                                  "Agent à proximité",
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              TextButton.icon(
                                                                onPressed: () {
                                                                  _showAgentDialog();
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .person_pin_circle,
                                                                  color:
                                                                      Colors
                                                                          .blue,
                                                                ),
                                                                label: Text(
                                                                  "Afficher Agent",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 10),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              print(
                                                "❌ Impossible de parser les coordonnées.",
                                              );
                                            }
                                          } else {
                                            print(
                                              "❌ Format de 'locations' non reconnu.",
                                            );
                                          }
                                        },

                                        child: Text(
                                          'Localisation : ${selectedAlerte!['locations']}',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      SizedBox(height: 10),
                                      Text(
                                        'Date et Heure : ${selectedAlerte!['created_at']}',
                                        style: TextStyle(fontSize: 16),
                                      ),

                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Text(
                                            'État : ${selectedAlerte!['etat']}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(width: 20),
                                          TextButton(
                                            onPressed: () {
                                              print("Voir plus cliqué");
                                              setState(
                                                () => showJson = !showJson,
                                              );
                                            },
                                            child: Text(
                                              'Voir plus',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      if (showJson && selectedUserData != null)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Divider(),
                                            Text(
                                              '👤 Infos utilisateur:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Card(
                                              margin: EdgeInsets.symmetric(
                                                vertical: 10,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 4,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 30,
                                                          backgroundColor:
                                                              Colors
                                                                  .grey
                                                                  .shade300,
                                                          backgroundImage:
                                                              selectedUserData!['utilisateur']['image_path'] !=
                                                                      null
                                                                  ? NetworkImage(
                                                                    '${AppConstants.baseUrl}${selectedUserData!['utilisateur']['image_path']}',
                                                                  )
                                                                  : null,
                                                          child:
                                                              selectedUserData!['utilisateur']['image_path'] ==
                                                                      null
                                                                  ? Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 30,
                                                                    color:
                                                                        Colors
                                                                            .teal,
                                                                  )
                                                                  : null,
                                                        ),
                                                        SizedBox(width: 16),
                                                        Expanded(
                                                          child: Text(
                                                            "Informations personnelles",
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 16),
                                                    Text(
                                                      "🧍 Noms: ${selectedUserData!['utilisateur']['noms']}",
                                                    ),
                                                    Text(
                                                      "🚻 Sexe: ${selectedUserData!['utilisateur']['sexe']}",
                                                    ),
                                                    Text(
                                                      "📧 Email: ${selectedUserData!['utilisateur']['email']}",
                                                    ),
                                                    Text(
                                                      "📞 Téléphone: ${selectedUserData!['utilisateur']['telephone']}",
                                                    ),
                                                    Text(
                                                      "🎂 Date de naissance: ${selectedUserData!['utilisateur']['date_naissance']}",
                                                    ),
                                                    Text(
                                                      "🏠 Adresse: ${selectedUserData!['utilisateur']['adresse']}",
                                                    ),
                                                    Text(
                                                      "💍 État civil: ${selectedUserData!['utilisateur']['etat_civil']}",
                                                    ),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      "🩺 Informations médicales",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "🩸 Groupe sanguin: ${selectedUserData!['utilisateur']['groupe_sanguin']}",
                                                    ),
                                                    Text(
                                                      "🌿 Allergies: ${selectedUserData!['utilisateur']['allergies']}",
                                                    ),
                                                    Text(
                                                      "🦠 Maladies: ${selectedUserData!['utilisateur']['maladies']}",
                                                    ),
                                                    Text(
                                                      "💊 Médicaments: ${selectedUserData!['utilisateur']['medicaments']}",
                                                    ),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      "📞 Contact d'urgence",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      "👤 Nom: ${selectedUserData!['utilisateur']['contact_urgence_nom']}",
                                                    ),
                                                    Text(
                                                      "🤝 Lien: ${selectedUserData!['utilisateur']['contact_urgence_lien']}",
                                                    ),
                                                    Text(
                                                      "📱 Téléphone: ${selectedUserData!['utilisateur']['contact_urgence_tel']}",
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 12),
                                            Text(
                                              '👶 Enfants:',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            if ((selectedUserData!['enfants']
                                                    as List)
                                                .isNotEmpty)
                                              ...List<Widget>.from(
                                                (selectedUserData!['enfants']
                                                        as List)
                                                    .map((child) {
                                                      return Card(
                                                        margin:
                                                            EdgeInsets.symmetric(
                                                              vertical: 6,
                                                            ),
                                                        elevation: 1,
                                                        child: ListTile(
                                                          leading: Icon(
                                                            Icons.child_care,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                          title: Text(
                                                            child['noms'] ??
                                                                'Nom inconnu',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            'Âge: ${child['age'] ?? 'Non défini'}\nSexe: ${child['sexe'] ?? 'Non défini'}',
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              )
                                            else
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8.0,
                                                    ),
                                                child: Text(
                                                  'Aucun enfant enregistré.',
                                                ),
                                              ),
                                          ],
                                        ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
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

class MyMenuPage extends StatefulWidget {
  const MyMenuPage({super.key});

  @override
  State<MyMenuPage> createState() => _MyMenuPageState();
}

class _MyMenuPageState extends State<MyMenuPage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
