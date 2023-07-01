import 'package:astronomy_app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' show get;
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:cached_network_image/cached_network_image.dart';



String page_gallery='',url='',selectedCategory='',img='';

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

  static Future<String> fetchFirstImage(String keyword) async {
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
    return imageUrl;
  } else {
    throw Exception('Failed to fetch images');
  }
}
}

class NasaApiScreen extends StatefulWidget {
  @override
  _NasaApiScreenState createState() => _NasaApiScreenState();
}

class _NasaApiScreenState extends State<NasaApiScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarWidget(icon: Icons.photo_library, text: 'Photo library'),
      body: FutureBuilder<List<ImageData>>(
        future: ApiService.fetchImages(selectedCategory),
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Verify your internet connection',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.indigo,
                ),
              ),
            );
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
                    child: CachedNetworkImage(
                      imageUrl:image.imageUrl,
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

 Future<void> loadItems() async {
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
    appBar: AppbarWidget(icon: Icons.photo_library, text: 'Photo library'),
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
        img=item['image'];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NasaApiScreen()),
            );
            page_gallery = item['title'];
            selectedCategory=item['url'];
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(item['image'],
                      fit: BoxFit.cover,)
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

class _FullScreenImageState extends State<FullScreenImage> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  String imageData = '';
  bool dataLoaded = false;
  bool downloading = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> downloadImage(String imageUrl) async {
  setState(() {
    downloading = true;
  });

  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final documentDirectory = await getApplicationDocumentsDirectory();
      final firstPath = documentDirectory.path + "/images";
      final filePathAndName = documentDirectory.path + '/images/pic.jpg';

      await Directory(firstPath).create(recursive: true);
      final file = File(filePathAndName);
      await file.writeAsBytes(response.bodyBytes);

      await ImageGallerySaver.saveFile(filePathAndName); // Enregistrement de l'image dans la galerie

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
  } finally {
    setState(() {
      downloading = false;
    });
  }
}

  void _startAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('', 
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),

       backgroundColor: Colors.indigo,
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
                      bottom: 160.0,
                      right: 16.0,
                      child: GestureDetector(
                        onTap: () {
                          final imageUrl = widget.imageUrls[index];
                          downloadImage(imageUrl);
                          _startAnimation();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.indigo,
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (downloading)
                                RotationTransition(
                                  turns: _animation,
                                  child: Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                  ),
                                ),
                              if (!downloading)
                                Icon(
                                  Icons.download,
                                  color: Colors.white,
                                ),
                              SizedBox(width: 8.0),
                              Text(
                                downloading ? 'Downloading...' : 'Download',
                                style: TextStyle(
                                  color: Colors.white,
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
            },
          ),
        ),
      ),
    );
  }
}

