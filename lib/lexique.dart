import 'package:astronomy_app/main.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:provider/provider.dart';

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
  } catch (e, stackTrace) {
  }
}


  

 List<ExpansionTile> getWordsStartingWithLetter(String letter) {
  final parsedJson = json.decode(jsonContent);
  final List<dynamic> words = List.from(parsedJson);

  List<ExpansionTile> expansionTiles = [];
  for (var word in words) {
    final String mot = word['mot'];
    if (mot.startsWith(letter) && getFilteredWords(searchController.text).contains(mot)) {
      final String definition = word['definition'];
      final String exemple = word['exemple'];

      final bool isExpanded = letter == expandedLetter && searchController.text.isNotEmpty; // Check if the ExpansionTile should be expanded

      expansionTiles.add(
        ExpansionTile(
          title: Text(
            mot,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.indigo.shade300,
            ),
          ),
          initiallyExpanded: isExpanded, // Use the isExpanded variable to determine if the ExpansionTile should be expanded
          children: [
            ListTile(
              title: Text(
                'Definition:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              subtitle: Text(
                definition,
                style: TextStyle(
                  fontSize: 12,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            ListTile(
              title: Text(
                'Example:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              subtitle: Text(
                exemple,
                style: TextStyle(
                  fontSize: 12,
                ),
                textAlign: TextAlign.justify,
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

  List<String> filteredWords = [];
  for (var word in parsedJson) {
    final String mot = word['mot'];
    if (mot.toLowerCase().contains(searchQuery.toLowerCase())) {
      filteredWords.add(mot);
    }
  }
  return filteredWords;
}


  @override
  Widget build(BuildContext context) {
     final themeProvider = Provider.of<ThemeProvider>(context); // Obtenez l'instance du ThemeProvider
     Color iconColor = themeProvider.isDarkMode ? Colors.indigo.shade300 : Colors.indigo;

    final filteredWords = getFilteredWords(searchController.text);
    if (filteredWords.isNotEmpty) {
      expandedLetter = filteredWords.first.substring(0, 1).toUpperCase();
    } else {
      expandedLetter = null;
    }

    return Scaffold(
      appBar: AppbarWidget(icon: Icons.bookmark, text: 'Glossary'),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {}); 
              },
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              decoration: InputDecoration(
                labelText: 'Recherche',
                labelStyle: TextStyle(
                  fontSize: 16,
                  color: iconColor,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: iconColor,
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
                            color: Theme.of(context).textTheme.titleLarge?.color,
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
