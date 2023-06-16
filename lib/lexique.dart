import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';

class Lexique extends StatefulWidget {
  const Lexique({Key? key}) : super(key: key);

  @override
  LexiqueState createState() => LexiqueState();
}

class LexiqueState extends State<Lexique> {
  String jsonContent = '';
  TextEditingController searchController = TextEditingController();
  String? expandedLetter;

  @override
  void initState() {
    super.initState();
    loadJsonContent();
  }

  Future<void> loadJsonContent() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/lexique.json');
      setState(() {
        jsonContent = jsonString;
      });
    } catch (e) {
      print('Error loading JSON content: $e');
    }
  }

  List<ExpansionTile> getWordsStartingWithLetter(String letter) {
    final parsedJson = json.decode(jsonContent);
    final List<dynamic> terms = parsedJson['terms'];

    List<ExpansionTile> expansionTiles = [];
    for (var term in terms) {
      final String mot = term['mot'];
      if (mot.startsWith(letter) && getFilteredWords(searchController.text).contains(mot)) {
        final String definition = term['definition'];
        final String exemple = term['exemple'];

        final bool isExpanded = letter == expandedLetter && searchController.text.isNotEmpty; // Vérifier si l'ExpansionTile doit être déployé

        expansionTiles.add(
          ExpansionTile(
            title: Text(
              mot,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
            initiallyExpanded: isExpanded, // Utiliser la variable isExpanded pour déterminer si l'ExpansionTile doit être déployé
            children: [
              ListTile(
                title: Text(
                  'Definition: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  definition,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Exemple: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  exemple,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
    return expansionTiles;
  }

  final List<String> alphabet = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T',
    'U', 'V', 'W', 'X', 'Y', 'Z'
  ];

  List<String> getFilteredWords(String searchQuery) {
    final parsedJson = json.decode(jsonContent);
    final List<dynamic> terms = parsedJson['terms'];

    List<String> filteredWords = [];
    for (var term in terms) {
      final String mot = term['mot'];
      if (mot.toLowerCase().contains(searchQuery.toLowerCase())) {
        filteredWords.add(mot);
      }
    }
    return filteredWords;
  }

  @override
  Widget build(BuildContext context) {
    final filteredWords = getFilteredWords(searchController.text);
    if (filteredWords.isNotEmpty) {
      expandedLetter = filteredWords.first.substring(0, 1).toUpperCase();
    } else {
      expandedLetter = null;
    }

    return Scaffold(
      appBar: AppBar(
  centerTitle: true,
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.bookmark,
        color:  Colors.indigo[900],
        size: 30.0,
      ),
      SizedBox(width: 8.0),
      Text(
        'Lexique',
        style: TextStyle(
          color:  Colors.indigo[900],
          fontSize: 24.0,
          fontFamily: 'vivaldi', // Remplace 'JolieFont' par le nom de la police que tu souhaites utiliser
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
  backgroundColor: Colors.white,
  elevation: 4.0,
  brightness: Brightness.dark,
  toolbarHeight: 80.0,
  iconTheme: IconThemeData(color: Colors.white),
  textTheme: TextTheme(
    headline6: TextStyle(
      color: Colors.white,
      fontSize: 24.0,
      fontFamily: 'Courier New', // Remplace 'JolieFont' par le nom de la police que tu souhaites utiliser
      fontWeight: FontWeight.bold,
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.settings),
      onPressed: () {
        // Action du bouton des paramètres
      },
    ),
  ],
),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {}); // Réexécute le build lors de la modification du champ de recherche
              },
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                labelText: 'Recherche',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.blue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: alphabet.length,
              itemBuilder: (context, index) {
                final letter = alphabet[index];
                final expansionTiles = getWordsStartingWithLetter(letter);
                final filteredTiles = expansionTiles
                    .where((tile) =>
                        tile.title.toString().toLowerCase().contains(
                              searchController.text.toLowerCase(),
                            ))
                    .toList();

                return filteredTiles.isNotEmpty
                    ? ExpansionTile(
                        title: Text(
                          letter,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        children: filteredTiles,
                      )
                    : SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
