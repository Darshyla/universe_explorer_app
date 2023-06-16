import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService{

static Future<List<Article>> fetchArticles() async {
  final response = await http.get(
    Uri.parse('https://api.spaceflightnewsapi.net/v4/articles/?limit=50'),
  );

  if (response.statusCode == 200) {
    final List<Article> articles = [];
    final data = jsonDecode(response.body);

    for (var articleData in data['results']) {
      final article = Article(
        id: articleData['id'],
        title: articleData['title'],
        url: articleData['url'],
        imageUrl: articleData['image_url'],
        newsSite: articleData['news_site'],
        summary: articleData['summary'],
        publishedAt: articleData['published_at'],
        updatedAt: articleData['updated_at'],
      );
      articles.add(article);
    }

    return articles;
  } else {
    throw Exception('Failed to fetch articles');
  }
}


}

class Article {

  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String updatedAt;

  Article({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.updatedAt
  });
}

class ArticleListScreen extends StatelessWidget {
  String defaultImageUrl = 'assets/images/astronaute/voyager-2-espace-interstellaire.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  centerTitle: true,
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.article,
        color:  Colors.indigo[900],
        size: 30.0,
      ),
      SizedBox(width: 8.0),
      Text(
        'Actualités',
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
      body: FutureBuilder<List<Article>>(
        future: ApiService.fetchArticles(),
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
                  color: Colors.red,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final articles = snapshot.data!;
            return ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  elevation: 4.0,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.0),
                    title: Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            article.imageUrl,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Image.asset(defaultImageUrl);
                            },
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          article.summary,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.justify,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    onTap: () async {
                      final urlString = article.url;
                      final url = Uri.parse(urlString);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                );
              },
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}

