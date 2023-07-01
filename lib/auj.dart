import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:cached_network_image/cached_network_image.dart';



class APOD {
  final String date;
  final String explanation;
  final String mediaType;
  final String title;
  final String url;

  APOD({
    required this.date,
    required this.explanation,
    required this.mediaType,
    required this.title,
    required this.url,
  });
}

class APODService {
  static Future<APOD> fetchAPODData() async {
    final response = await http.get(Uri.parse('https://api.nasa.gov/planetary/apod?api_key=LCciuJUXeWLHsLSwjtxvr0eQUT2pKYdBTUWizgYL'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return APOD(
        date: jsonData['date'],
        explanation: jsonData['explanation'],
        mediaType: jsonData['media_type'],
        title: jsonData['title'],
        url: jsonData['url'],
      );
    } else {
      throw Exception('Failed to fetch APOD data');
    }
  }
}

class TodayPage extends StatefulWidget {
  @override
  TodayState createState() => TodayState();
}

class TodayState extends State<TodayPage> {

  late Future<Map<String, dynamic>> _randomTermFuture;
  bool isImageExpanded = false;
  late Future<APOD> apodFuture;
  

  @override
  void initState() {
    super.initState();
    _randomTermFuture = getRandomTerm();
    apodFuture = APODService.fetchAPODData();
  }

  Future<Map<String, dynamic>> getRandomTerm() async {
  final jsonString = await rootBundle.loadString('assets/lexique.json');
  final List<dynamic> terms = json.decode(jsonString);

  final currentDate = DateTime.now().toIso8601String().split('T')[0];

  for (final term in terms) {
    final String termDate = term['date'];
    if (termDate == currentDate) {
      return term;
    }
  }

  // Si aucun terme ne correspond à la date actuelle, vous pouvez renvoyer un terme par défaut ou générer un message d'erreur.
  return {
    'mot': 'Aucun terme trouvé',
    'definition': 'Aucune définition disponible pour aujourd\'hui',
    'exemple': 'Aucun exemple disponible pour aujourd\'hui',
  };
}



  Future<Uint8List> getThumbnail(String url) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      maxWidth: 200,
      quality: 50,
    );
    return thumbnail!;
  }

@override
Widget build(BuildContext context) {

  return Scaffold(
    body: SingleChildScrollView(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _randomTermFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            String mot = snapshot.data!['mot'];
            String definition = snapshot.data!['definition'];
            String exemple = snapshot.data!['exemple'];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isImageExpanded = !isImageExpanded;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(16),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.indigo.shade100,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 30),
                              Text(
                                '$mot',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Definition',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$definition',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Example',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '$exemple',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: MediaQuery.of(context).size.width * 0.1 - 24,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.7),
                          ),
                          child: Text(
                            'Word of the Day',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.4,
                        margin: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: FutureBuilder<APOD>(
                            future: apodFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text(
                                        'Verify your internet connection'));
                              } else {
                                final apod = snapshot.data!;

                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (apod.mediaType == 'image')
                                        GestureDetector(
                                          onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ImageFullscreenPage(
                                                          apod.url,
                                                          apod.explanation),
                                                ),
                                              );
                                          },
                                          child: Hero(
                                            tag: apod.url,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: Stack(
                                                children: [
                                                  CachedNetworkImage(
                                                    imageUrl:apod.url,
                                                    fit: BoxFit.cover,
                                                    width: MediaQuery.of(context).size.width * 0.85,
                                                    height: MediaQuery.of(context).size.height * 0.35,
                                                  ),
                                                    Container(
                                                      color: Colors.black
                                                          .withOpacity(0.7),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            apod.title,
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (apod.mediaType == 'video')
                                        AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: InkWell(
                                            onTap: () {
                                              final urlString = apod.url;
                                              final url = Uri.parse(urlString);
                                              launchVideoUrl(url);
                                            },
                                            child: FutureBuilder<Uint8List>(
                                              future:
                                                  getThumbnail(apod.url),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Center(
                                                    child: Text(
                                                        'Failed to load video thumbnail\nClick to watch the video'),
                                                  );
                                                } else {
                                                  final thumbnailData =
                                                      snapshot.data!;
                                                  return Image.memory(
                                                    thumbnailData,
                                                    fit: BoxFit.cover,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.7),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Media of the Day',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    ),
  );
}




  void launchVideoUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ImageFullscreenPage extends StatelessWidget {
  final String imageUrl;
  final String explanation;

  ImageFullscreenPage(this.imageUrl, this.explanation);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Media of the day',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black,
          child: PageView.builder(
            physics: NeverScrollableScrollPhysics(), // Désactiver le défilement horizontal
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.height / 7, // 1/7 of the screen height
                          child: SingleChildScrollView(
                            child: Text(
                              explanation,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
