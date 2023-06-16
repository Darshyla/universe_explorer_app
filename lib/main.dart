import 'package:astronomy_app/quizz.dart';
import 'package:flutter/material.dart';
import 'actualite.dart';
import 'galerie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'dart:async';
import 'cours.dart';
import 'lexique.dart';
import 'home.dart';
import 'dashboard.dart';
import 'today.dart';
import 'setting.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/actualites': (context) => ArticleListScreen(), // Définition de la route vers l'écran Actualite
        '/cours': (context) => AstronomyTopics(), // Définition de la route vers l'écran Cours
        '/quizz': (context) => CategoryList(), // Définition de la route vers l'écran Quizz
        '/phototheque': (context) => Galerie(), // Définition de la route vers l'écran Phototheque
        //'/forum': (context) => Forum(), // Définition de la route vers l'écran Forum
        '/lexique': (context) => Lexique(), // Définition de la route vers l'écran Lexique
        // Autres routes...
      },
      theme: ThemeData(
        primaryColor: Colors.black,
        //scaffoldBackgroundColor: Colors.grey,
        colorScheme: ThemeData().colorScheme.copyWith(
          primary: Colors.black,
          secondary: Colors.indigo[900],
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigo[900],
        ),
      ),
      home: AnimationScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

Future<bool> isFirstLaunch() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
  if (isFirstLaunch) {
    await prefs.setBool('isFirstLaunch', false);
  }
  return isFirstLaunch;
}

class IntroductionScreen extends StatefulWidget {
  @override
  _IntroductionScreenState createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  bool _isLastPage = false;

 final List<Map<String, String>> _introData = [
  {
    'title': 'Vous êtes au bon endroit pour l\'exploration spatiale',
    'description': 'Découvrez les fonctionnalités passionnantes que nous avons à offrir.',
    'image': 'assets/images/Intro_screen/bienvenue.png',
  },
  {
    'title': 'Cours',
    'description': 'Explorez nos cours approfondis sur les différentes notions astronomiques.',
    'image': 'assets/images/Intro_screen/cours.webp',
  },
  {
    'title': 'Quizz',
    'description': 'Testez vos connaissances avec nos quizz interactifs sur l\'astronomie.',
    'image': 'assets/images/Intro_screen/quizz.webp',
  },
  {
    'title': 'Photothèque',
    'description': 'Plongez dans notre collection de superbes photos astronomiques captivantes.',
    'image': 'assets/images/Intro_screen/galerie.webp',
  },
  {
    'title': 'Forum',
    'description': 'Partagez vos questions, découvertes et échangez avec d\'autres passionnés d\'astronomie.',
    'image': 'assets/images/Intro_screen/forum.webp',
  },
  {
    'title': 'Lexique',
    'description': 'Consultez notre lexique complet pour comprendre les termes astronomiques.',
    'image': 'assets/images/Intro_screen/lexique.webp',
  },
  {
    'title': 'Actualités',
    'description': 'Restez à jour avec les dernières nouvelles et découvertes dans le domaine de l\'astronomie.',
    'image': 'assets/images/Intro_screen/actualites.png',
  },
];


  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
        _isLastPage = _currentPage == _introData.length - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_isLastPage) {
      // C'est la dernière page d'introduction, vous pouvez effectuer une action supplémentaire ou naviguer vers une autre page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _introData.length,
            itemBuilder: (context, index) {
              return IntroPage(
                title: _introData[index]['title']!,
                description: _introData[index]['description']!,
                image: _introData[index]['image']!,
              );
            },
          ),
          Positioned(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _introData.length,
                    (index) => buildDot(index),
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _goToPreviousPage,
                      ),
                    IconButton(
                      icon: _isLastPage ? Icon(Icons.check) : Icon(Icons.arrow_forward),
                      onPressed: _goToNextPage,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      width: _currentPage == index ? 12.0 : 8.0,
      height: 8.0,
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const IntroPage({
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 200,
            height: 200,
          ),
          SizedBox(height: 32.0),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class AnimationScreen extends StatefulWidget {
  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _animation;
  bool _showGreetings = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController!);

    _animationController!.forward();

    _animationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showGreetings = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/ciel_etoile_background.jpeg'),
          fit: BoxFit.cover,
          opacity: 0.9
        ),
      ),
      child: Center(
        child: _showGreetings
            ? FutureBuilder<bool>(
        future: isFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return IntroductionScreen();
          } else {
            return HomePage();
          }
        },
      )
            : FadeTransition(
                opacity: _animation!,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/fusee_bouge.gif',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'The universe, an exploration of infinity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
      ),
    ),
  );
}

}

class HomePage extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage> {

  Widget? _child;

  @override
  void initState() {
    _child = TodayPage();
    super.initState();
  }

  final List<Widget> _pages = [
    TodayPage(),
    Accueil(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              color:  Colors.indigo[900],
              size: 30.0,
            ),
            SizedBox(width: 8.0),
            Text(
              'Universe Explorer',
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
      drawer: AppDrawer(),
      body: _child,
       bottomNavigationBar: FluidNavBar(
          icons: [
            FluidNavBarIcon(
                icon: Icons.calendar_today,
                backgroundColor: Colors.indigo,
                extras: {"label": "Today"}),
            FluidNavBarIcon(
                icon: Icons.home,
                backgroundColor: Colors.indigo,
                extras: {"label": "Home"}),
            FluidNavBarIcon(
                icon: Icons.dashboard,
                backgroundColor: Colors.indigo,
                extras: {"label": "Dashboard"}),
          ],
          onChange: _handleNavigationChange,
          style: FluidNavBarStyle(
            iconSelectedForegroundColor: Colors.white,
              iconUnselectedForegroundColor: Colors.white60),
          scaleFactor: 1.5,
          defaultIndex: 0,
          itemBuilder: (icon, item) => Semantics(
            label: icon.extras!["label"],
            child: item,
          ),
        ),
    );
  }

    void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          _child = TodayPage();
          break;
        case 1:
          _child = Accueil();
          break;
        case 2:
          _child = SettingsPage();
          break;
      }
      _child = AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        duration: Duration(milliseconds: 500),
        child: _child,
      );
    });
  }
}

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Text('Mon application'),
            decoration: BoxDecoration(
              //color: Colors.black,
            ),
          ),
          ListTile(
            leading: Icon(Icons.book),
            title: Text('Cours'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              Navigator.push(context, MaterialPageRoute(builder:(context) =>AstronomyTopics()));
            },
          ),
          ListTile(
            leading: Icon(Icons.quiz),
            title: Text('Quizz'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              Navigator.push(context, MaterialPageRoute(builder:(context) =>CategoryList()));
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library),
            title: Text('Phototèque'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
               Navigator.push(context, MaterialPageRoute(builder:(context) =>Galerie()));
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Lexique'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              Navigator.push(context, MaterialPageRoute(builder:(context) =>Lexique()));
            },
          ),
          ListTile(
            leading: Icon(Icons.article),
            title: Text('Actualités'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              Navigator.push(context, MaterialPageRoute(builder:(context) =>ArticleListScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.forum),
            title: Text('Forum'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              // Action à effectuer lorsque l'élément est cliqué
            },
          ),
          Divider(), // Séparateur
          ListTile(
            leading: Icon(Icons.login),
            title: Text('Se connecter'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              // Action à effectuer lorsque l'élément est cliqué
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Se déconnecter'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              // Action à effectuer lorsque l'élément est cliqué
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Paramètres'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
             Navigator.push(context, MaterialPageRoute(builder:(context) =>SettingsScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Tableau de bord'),
            onTap: () {
              Navigator.pop(context); // Ferme le Drawer
              // Action à effectuer lorsque l'élément est cliqué
            },
          ),
        ],
      ),
    );
  }
}




