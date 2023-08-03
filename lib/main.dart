import 'package:astronomy_app/quizz.dart';
import 'package:astronomy_app/setting.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'actualite.dart';
import 'galerie.dart';
import 'dart:async';
import 'cours.dart';
import 'lexique.dart';
import 'home.dart';
import 'auj.dart';
import 'onboarding.dart';

 bool _notificationsEnabled = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(_notificationsEnabled){
      NotificationPlan notificationPlan = NotificationPlan();
     await notificationPlan._initializeNotifications();
  }
  

  runApp(
    FutureBuilder(
      future: initializeSharedPreferences(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) {
                  ThemeProvider themeProvider = ThemeProvider();
                  themeProvider.initialize(); // Appel de la méthode initialize()
                  return themeProvider;
                },
              ),
              ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
            ],
            child: MyApp(),
          ); 
        }
      },
    ),
  );
}

class NotificationPlan {

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
  
  Future<void> _requestPermissions() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'default_channel',
          'Default Channel',
        ),
      );
}


  Future<void> _initializeNotifications() async {
  // Request permissions
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'default_channel',
        'Default Channel',
      ),
    );

  // Schedule daily notification at 00:00
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'default_channel',
    'Default Channel',
    icon: 'ic_notification'
  );
  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Create the time for the daily notification
  final time = Time(00,00); // 00:00 (Minuit)

  // Schedule the daily notification
  await flutterLocalNotificationsPlugin.showDailyAtTime(
    0,
    'Media/Word of the day',
    'Your daily media and word are ready, go learn',
    time,
    platformChannelSpecifics,
  );
}
}

Future<void> initializeSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('isDarkMode')) {
    await prefs.setBool('isDarkMode', false);
  }
}

class SettingsProvider with ChangeNotifier {
  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    _notificationsEnabled = value;
    notifyListeners();
  }
}

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  static const Color indigoLight = Color(0xFF3F51B5);
  static const Color indigoDark = Color(0xFF5C6BC0);

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners(); // Notifier les auditeurs après la récupération de la valeur
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        Color mainColor = themeProvider.isDarkMode ? Colors.indigo.shade200 : Colors.indigo;
        return MaterialApp(
          routes: {
            '/actualites': (context) => ArticleListScreen(),
            '/cours': (context) => AstronomyTopics(),
            '/quizz': (context) => CategoryList(),
            '/phototheque': (context) => const Galerie(),
            '/lexique': (context) =>  LexiquePage(),
            '/CategoryList': (context) =>CategoryList()
          },
          theme: themeProvider.isDarkMode
              ? ThemeData(
                  brightness: Brightness.dark,
                  primaryColor: ThemeProvider.indigoDark,
                )
              : ThemeData(
                  brightness: Brightness.light,
                  primaryColor: ThemeProvider.indigoLight,
                ),
          home: AnimationScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
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
      duration: Duration(seconds: 5),
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
          image: AssetImage('assets/images/onboarding/cielEtoile.jpg'),
          fit: BoxFit.cover,
          opacity: 0.9
        ),
        color: Colors.black87
      ),
      child: Center(
        child: _showGreetings
            ? FutureBuilder<bool>(
        future: isFirstLaunch(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == true) {
            return OnboardingScreen();
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
                      'assets/images/onboarding/fusee_bouge.gif',
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 40),
                    Text(
                      'The universe, an exploration of infinity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo.shade300
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
    SettingsScreen(),
  ];

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppbarWidget(icon: Icons.explore, text: 'Universe Explorer'),
    body: _child,
    bottomNavigationBar: Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        Color backgroundColor = themeProvider.isDarkMode ? Colors.indigo.shade300 : Colors.indigo;
        Color iconSelectedForegroundColor = themeProvider.isDarkMode ? Colors.white : Colors.white;
        Color iconUnselectedForegroundColor = themeProvider.isDarkMode ? Colors.white60 : Colors.white60;

        return FluidNavBar(
          icons: [
            FluidNavBarIcon(
              icon: Icons.calendar_today,
              backgroundColor: backgroundColor,
              extras: {"label": "Today"},
            ),
            FluidNavBarIcon(
              icon: Icons.home,
              backgroundColor: backgroundColor,
              extras: {"label": "Home"},
            ),
            FluidNavBarIcon(
              icon: Icons.settings,
              backgroundColor: backgroundColor,
              extras: {"label": "Settings"},
            ),
          ],
          onChange: _handleNavigationChange,
          style: FluidNavBarStyle(
            iconSelectedForegroundColor: Theme.of(context).scaffoldBackgroundColor,
            iconUnselectedForegroundColor: iconUnselectedForegroundColor,
            barBackgroundColor: backgroundColor,
          ),
          scaleFactor: 1.5,
          defaultIndex: 0,
          itemBuilder: (icon, item) => Semantics(
            label: icon.extras!["label"],
            child: item,
          ),
        );
      },
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
          _child = SettingsScreen();
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

class AppbarWidget extends StatelessWidget implements PreferredSizeWidget {
  final IconData icon;
  final String text;

  AppbarWidget({required this.icon, required this.text});

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Obtenez l'instance du ThemeProvider

    bool implyLeading = (text == 'Universe Explorer') ? false : true;

    Color iconColor = themeProvider.isDarkMode ? Colors.indigo.shade300 : Colors.indigo;

    return AppBar(
      automaticallyImplyLeading: implyLeading,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 30.0,
          ),
          SizedBox(width: 8.0),
          Text(
            text,
            style: TextStyle(
              color: iconColor,
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 4.0,
      toolbarHeight: 80.0,
      iconTheme: IconThemeData(color: iconColor),
    );
  }
}
