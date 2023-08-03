import 'dart:convert';
import 'package:astronomy_app/main.dart';
import 'package:flutter/material.dart';

class LexiquePage extends StatefulWidget {
  @override
  _LexiquePageState createState() => _LexiquePageState();
}

class _LexiquePageState extends State<LexiquePage> {
  List<dynamic> lexiqueData = [];
  List<dynamic> filteredData = [];

  TextEditingController searchController = TextEditingController();

  Future<void> loadLexiqueData() async {
    // Charger les données depuis le fichier JSON (assumant que le fichier est dans le répertoire assets)
    String jsonString = await DefaultAssetBundle.of(context).loadString('assets/lexique.json');
    setState(() {
      lexiqueData = jsonDecode(jsonString);
      filteredData = lexiqueData;
    });
  }

  void filterData(String query) {
    List<dynamic> tempList = [];
    tempList.addAll(lexiqueData);
    if (query.isNotEmpty) {
      tempList = tempList.where((term) => term['mot'].toLowerCase().contains(query.toLowerCase())).toList();
    }
    setState(() {
      filteredData = tempList;
    });
  }

  @override
  void initState() {
    super.initState();
    loadLexiqueData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(icon: Icons.book, text: 'Glossary'),
      body: Column(
        children: [
         Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TextField(
              controller: searchController,
              onChanged: filterData,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Colors.indigo),
                prefixIcon: Icon(Icons.search,color: Colors.indigo,),
                iconColor: Colors.indigo,
                border: InputBorder.none, // Supprime la bordure du TextField
              ),
            ),
          ),
        ),


          Expanded(
            child: ListView.builder(
              itemCount: 26,
              itemBuilder: (context, index) {
                String letter = String.fromCharCode(65 + index);
                List<dynamic> termsStartingWithLetter = filteredData.where((term) => term['mot'].startsWith(letter)).toList();

                return termsStartingWithLetter.isNotEmpty
                    ? ExpansionTile(
                        title: Text(letter),
                        textColor: Colors.indigo,
                        children: termsStartingWithLetter.map<Widget>((term) {
                          return ExpansionTile(
                            title: Text(term['mot']),
                            textColor: Colors.indigo,
                            children: [
                              ListTile(
                                title: Text('Définition'),
                                subtitle: Text(term['definition'],textAlign: TextAlign.justify),
                              ),
                              ListTile(
                                title: Text('Exemple'),
                                subtitle: Text(term['exemple'],textAlign: TextAlign.justify,),
                              ),
                            ],
                          );
                        }).toList(),
                      )
                    : Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}









