import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


String page_gallery='';


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
    appBar:AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library,
              color:  Colors.indigo[900],
              size: 30.0,
            ),
            SizedBox(width: 8.0),
            Text(
              'Photothèque',
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
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ScrollableImageList()),
            );
            page_gallery = item['title'];
            print(page_gallery);
          },
          child: Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.4),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  item['title'],
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: 16.0),
                 ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    item['image'],
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
          ),
        );
      },
    ),
  );
}

}

class ScrollableImageList extends StatefulWidget {
  @override
  _ScrollableImageListState createState() => _ScrollableImageListState();
}

class _ScrollableImageListState extends State<ScrollableImageList> {
  List<Picture> imageUrls = [];
  List<GalleryPage> galleryPages = [];
  int? selectedImageIndex;

  Future<void> loadGalleryPages() async {
    final String jsonData = await rootBundle.loadString('assets/galerie_page.json');
    final List<dynamic> data = json.decode(jsonData);
    galleryPages = List<GalleryPage>.from(data.map((pageData) => GalleryPage.fromJson(pageData)));
    setState(() {});
  }

  void getImagesForPage(String pageName) {
    final page = galleryPages.firstWhere((galleryPage) => galleryPage.page == pageName,);

    if (page != null) {
      imageUrls = page.images;
      for (Picture image in imageUrls) {
        print(image.path);
        print(image.description);
      }
    } else {
      print("La page $pageName n'existe pas.");
    }
  }

  @override
  void initState() {
    super.initState();
    loadGalleryPages().then((_) {
      getImagesForPage(page_gallery);
    });
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(page_gallery),
    ),
    body: GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) {
              return FullScreenImage(
                imageUrls: imageUrls.map((picture) => picture.path).toList(),
                imageDescriptions: imageUrls.map((picture) => picture.description).toList(),
                initialIndex: index,
              );
            }));
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.asset(
              imageUrls[index].path,
              fit: BoxFit.cover,
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
      title: Text(page_gallery),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        widget.imageUrls[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.imageDescriptions[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.justify,
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