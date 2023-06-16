import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;



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
      appBar:  AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book,
              color:  Colors.indigo[900],
              size: 30.0,
            ),
            SizedBox(width: 8.0),
            Text(
              'Cours',
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
      body: ListView.builder(
        itemCount: topics.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: ExpansionTile(
              title: Text(
                topics[index].title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
              builder: (context) => AstronomyLessonPage(subTopic),
            ),
          );
        },
      );
    }).toList();
  }
}


class AstronomyLessonPage extends StatelessWidget {
  final SubTopic subTopic;

  AstronomyLessonPage(this.subTopic);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subTopic.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              subTopic.image,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subTopic.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    subTopic.title,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            point.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            point.content,
          ),
          SizedBox(height: 16),
        ],
      );
    }).toList();
  }
}

class Topic {
  String title;
  List<SubTopic> subTopics;

  Topic({required this.title, required this.subTopics});

  factory Topic.fromJson(Map<String, dynamic> json) {
    List<dynamic> subTopicList = json['subTopics'];
    List<SubTopic> subTopics = subTopicList
        .map((subTopicJson) => SubTopic.fromJson(subTopicJson))
        .toList();

    return Topic(
      title: json['title'],
      subTopics: subTopics,
    );
  }
}

class SubTopic {
  String title;
  String image;
  List<Point> points;

  SubTopic({
    required this.title,
    required this.image,
    required this.points,
  });

  factory SubTopic.fromJson(Map<String, dynamic> json) {
    List<dynamic> pointList = json['points'];
    List<Point> points =
        pointList.map((pointJson) => Point.fromJson(pointJson)).toList();

    return SubTopic(
      title: json['title'],
      image: json['image'],
      points: points,
    );
  }
}

class Point {
  String title;
  String content;

  Point({required this.title, required this.content});

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      title: json['title'],
      content: json['content'],
    );
  }
}


