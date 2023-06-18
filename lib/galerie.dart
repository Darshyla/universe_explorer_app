import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'dart:io';

String page_gallery='',url='';

class ApiService{

  static Future<List<ImageData>> fetchImages(String keyword) async {
    final response = await http.get(
        Uri.parse("https://images-api.nasa.gov/search?q=${keyword}&media_type=image"));
    // Include the 'media_type=image' parameter in the API URL

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final items = jsonData['collection']['items'];

      List<ImageData> images = [];

      for (var item in items) {
        final links = item['links'];
        final data = item['data'][0];
        final description = data['description'];

        // Recherche du lien de l'image en format JPG
        String imageUrl = '';
        if (links != null && links.isNotEmpty) {
          for (var link in links) {
            if (link['render'] == 'image' && link['href'].endsWith('.jpg')) {
              imageUrl = link['href'];
              break; // Sortir de la boucle dès que le lien est trouvé
            }
          }
        }

        images.add(ImageData(
          imageUrl: imageUrl,
          description: description,
        ));
      }

      return images;
    } else {
      throw Exception('Failed to fetch images');
    }
  }

  static   Future<String> fetchFirstImage(String keyword) async {
  final response = await http.get(Uri.parse("https://images-api.nasa.gov/search?q=${keyword}&media_type=image"));
  // Include the 'media_type=image' parameter in the API URL

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    final items = jsonData['collection']['items'];

    final item = items[1];
    final links = item['links'];
    final data = item['data'][0];

    // Recherche du lien de l'image en format JPG
    String imageUrl = '';
    if (links != null && links.isNotEmpty) {
      for (var link in links) {
        if (link['render'] == 'image' && link['href'].endsWith('.jpg')) {
          imageUrl = link['href'];
          break; // Sortir de la boucle dès que le lien est trouvé
        }
      }
    }

    print(imageUrl);
    return imageUrl;
  } else {
    throw Exception('Failed to fetch images');
  }
}
}

class GalleryPage {
  final String page;
  final List<Picture> images;

  GalleryPage({required this.page, required this.images});

  factory GalleryPage.fromJson(Map<String, dynamic> json) {
    final String page = json['page'];
    final List<dynamic> imagesData = json['images'];
    final List<Picture> pictures = imagesData.map((imageData) => Picture.fromJson(imageData)).toList();
    return GalleryPage(page: page, images: pictures);
  }
}

class Picture {
  final String path;
  final String description;

  Picture({required this.path, required this.description});

  factory Picture.fromJson(Map<String, dynamic> json) {
    final String path = json['path'];
    final String description = json['description'];
    return Picture(path: path, description: description);
  }
}

class ImageData {
  final String imageUrl;
  final String description;

  ImageData({required this.imageUrl, required this.description});
}

class NasaApiScreen extends StatefulWidget {
  @override
  _NasaApiScreenState createState() => _NasaApiScreenState();
}

class _NasaApiScreenState extends State<NasaApiScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(page_gallery),
      ),
      body: FutureBuilder<List<ImageData>>(
        future: ApiService.fetchImages(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final images = snapshot.data;

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns in the grid
                crossAxisSpacing: 10.0, // Spacing between columns
                mainAxisSpacing: 10.0, // Spacing between rows
              ),
              itemCount: images!.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return FullScreenImage(
                        imageUrls: images.map((image) => image.imageUrl).toList(),
                        imageDescriptions:
                            images.map((image) => image.description).toList(),
                        initialIndex: index,
                      );
                    }));
                  },
                  child: Card(
                    elevation: 2.0,
                    child: Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Galerie extends StatefulWidget {
  const Galerie({Key? key}) : super(key: key);

  @override
  GalerieState createState() => GalerieState();
}

class GalerieState extends State<Galerie> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    // Charger le fichier JSON
    String jsonContent = await DefaultAssetBundle.of(context).loadString('assets/galerie.json');
    List<dynamic> jsonList = json.decode(jsonContent);

    // Convertir le JSON en liste de Maps
    List<Map<String, dynamic>> itemList = jsonList.cast<Map<String, dynamic>>();

    setState(() {
      items = itemList;
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      // ... le reste de votre code d'appBar
    ),
    body: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Nombre de colonnes dans la grille
        crossAxisSpacing: 8.0, // Espacement horizontal entre les éléments
        mainAxisSpacing: 8.0, // Espacement vertical entre les éléments
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        url = item['url'];
        print(url);
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NasaApiScreen()),
            );
            page_gallery = item['title'];
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: FutureBuilder<String>(
                      future: ApiService.fetchFirstImage(url),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          // Afficher une image de chargement pendant le chargement de l'URL
                          return CircularProgressIndicator();
                        } else {
                          // Afficher l'image une fois que l'URL est disponible
                          return Image.network(
                            snapshot.data!,
                            fit: BoxFit.cover, // Appliquer le mode de redimensionnement de l'image
                          );
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    item['title'],
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}



}

class FullScreenImage extends StatefulWidget {
  final List<String> imageUrls;
  final List<String> imageDescriptions;
  final int initialIndex;

  FullScreenImage({
    required this.imageUrls,
    required this.imageDescriptions,
    required this.initialIndex,
  });

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late PageController _pageController;
  int _currentIndex = 0;

 String imageData='';
  bool dataLoaded = false;

Future<void> downloadImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final documentDirectory = await getApplicationDocumentsDirectory();
      print(documentDirectory);
      final firstPath = documentDirectory.path + "/images";
      final filePathAndName = documentDirectory.path + '/images/pic.jpg';
      
      await Directory(firstPath).create(recursive: true);
      final file = File(filePathAndName);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        imageData = filePathAndName;
        dataLoaded = true;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image downloaded')),
      );
    } else {
      throw Exception('Failed to download image');
    }
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to download image')),
    );
  }
}

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phototeque'),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
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
                              widget.imageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.height / 7, // 1/7 of the screen height
                          child: SingleChildScrollView(
                            child: Text(
                              widget.imageDescriptions[index],
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
                    Positioned(
                      bottom: 16.0,
                      right: 16.0,
                      child: FloatingActionButton(
                        onPressed: () {
                          final imageUrl = widget.imageUrls[index];
                          downloadImage(imageUrl);
                        },

                        child: Icon(Icons.download),
                      ),
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
