import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:astronomy_app/main.dart';
import 'package:provider/provider.dart';

class Topic {
  String title;
  List<SubTopic> subTopics;

  Topic({required this.title, required this.subTopics});

  factory Topic.fromJson(Map<String, dynamic> json) {
    List<dynamic> subTopicList = json['subTopics'];
    List<SubTopic> subTopics = subTopicList.map((subTopicJson) => SubTopic.fromJson(subTopicJson)).toList();

    return Topic(
      title: json['title'],
      subTopics: subTopics,
    );
  }
}

class SubTopic {
  String title;
  String image;
  String intro;
  List<Point> points;

  SubTopic({
    required this.title,
    required this.image,
    required this.points,
    required this.intro
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    List<dynamic> pointList = json['points'];
    List<Point> points =
        pointList.map((pointJson) => Point.fromJson(pointJson)).toList();

    return SubTopic(
      title: json['title'],
      image: json['image'],
      intro: json['intro'],
      points: points,
    );
  }
}

class Point {
  String title;
  String content;
  String image;

  Point({required this.title, required this.content, required this.image});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      title: json['title'],
      content: json['content'],
      image: json['image']
    );
  }
}

class AstronomyTopics extends StatefulWidget {
  @override
  _AstronomyTopicsState createState() => _AstronomyTopicsState();
}

class _AstronomyTopicsState extends State<AstronomyTopics> {
  List<Topic> topics = [];

  @override
  void initState() {
    super.initState();
    loadTopics();
  }

  Future<void> loadTopics() async {
    try {
      String jsonString = await rootBundle.loadString('assets/topics.json');
      List<dynamic> jsonList = jsonDecode(jsonString);
      List<Topic> loadedTopics = jsonList
          .map((json) => Topic.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        topics = loadedTopics;
      });
    } catch (e) {
      print('Error loading topics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(icon:Icons.book, text:'Courses'),
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          print(topics.length);
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            color: Colors.indigo, // Propriété 1: Couleur de fond
            shadowColor: Colors.black, // Propriété 2: Couleur de l'ombre
            borderOnForeground: true, // Propriété 3: Afficher la bordure au-dessus du contenu
            semanticContainer: false, // Propriété 4: Définit si le widget est un conteneur sémantique
            clipBehavior: Clip.antiAlias, // Propriété 5: Comportement de clipping
            child: ExpansionTile(
              title: Text(
                topics[index].title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Propriété 6: Couleur du texte
                ),
              ),
              collapsedTextColor: Colors.red, // Propriété 7: Couleur du texte lorsqu'il est réduit
              backgroundColor: Colors.white60, // Propriété 8: Couleur de fond lorsqu'il est réduit
              initiallyExpanded: false, // Propriété 9: Définit si le widget est initialement étendu
              maintainState: true, // Propriété 10: Maintenir l'état de l'expansion
              tilePadding: EdgeInsets.all(16.0), // Propriété 11: Padding du titre
              childrenPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0), // Propriété 12: Padding des enfants
              expandedAlignment: Alignment.centerLeft, // Propriété 13: Alignement du contenu étendu
              expandedCrossAxisAlignment: CrossAxisAlignment.start, // Propriété 14: Alignement des enfants étendus
              trailing: Icon(Icons.expand_more), // Propriété 15: Widget à afficher après le titre lorsqu'il est réduit
              onExpansionChanged: (value) {}, // Propriété 16: Callback lorsque l'état d'expansion change
              children: _buildSubTopics(topics[index].subTopics),
            ),
          );

        },
      ),
    );
  }

  List<Widget> _buildSubTopics(List<SubTopic> subTopics) {
    return subTopics.map((subTopic) {
      return ListTile(
        title: Text(
          subTopic.title,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AstronomyLessonPage(subTopic: subTopic),
            ),
          );
        },
      );
    }).toList();
  }
}

class AstronomyLessonPage extends StatelessWidget {
  final SubTopic subTopic;

  AstronomyLessonPage({required this.subTopic});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtenez l'instance du ThemeProvider
    Color iconColor = themeProvider.isDarkMode ? Colors.indigo.shade300 : Colors.indigo;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          subTopic.title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  subTopic.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  color: Colors.blue,
                  colorBlendMode: BlendMode.multiply,
                ),
                Positioned(
                  child: Text(
                    subTopic.title,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    subTopic.intro,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildPoints(subTopic.points),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPoints(List<Point> points) {
    return points.map((point) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            point.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.indigo.shade300,
            ),
          ),
          SizedBox(height: 8),
          if (point.image != null && point.image.isNotEmpty)
           Image.asset(
            point.image,
            // width: double.infinity,
            // height: 200,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            repeat: ImageRepeat.repeat,
            filterQuality: FilterQuality.high,
            semanticLabel: 'Image',
            excludeFromSemantics: true,
          )
          ,
          SizedBox(height: 8),
          Text(
            point.content,
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}
