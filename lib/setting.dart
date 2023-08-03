import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';




class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  late bool _notificationsEnabled;
  late bool _isDarkMode;
  String message="Hey there! I recently discovered an amazing astronomy app that I think you'll love. It's packed with fascinating information about the universe, stunning images of galaxies, and even features a stargazing guide. I highly recommend giving it a try! You can download it from the site below. Happy exploring the cosmos!";


 @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveNotificationsSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    
  }

  Future<void> _saveThemeSetting(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notification'),
            trailing: Switch(
              value: settingsProvider.notificationsEnabled,
              onChanged: (bool value) {
               settingsProvider.setNotificationsEnabled(value);
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.lightbulb_outline),
            title: Text('Dark mode'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                _saveThemeSetting(value);
                themeProvider.toggleTheme();
              },
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Invite a Friend'),
            onTap: () {
              const link = 'https://dbalexis.online';  
               Share.share('$message: $link', subject: 'Invite');
          
            },
          ),
         ListTile(
          leading: Icon(Icons.star),
          title: Text('Rate the App'),
          onTap: () {
            final urlString = 'https://dbalexis.online';
            final url = Uri.parse(urlString); 
            launchUrl(url);
          },
        ), 
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('About the app'),
                    content: TextInfo(),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Terms and Conditions'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Terms and conditions'),
                    content: TermsAndConditions(),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Close', style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class TextInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This application is your gateway to exploring the fascinating world of astronomy. Whether you are a curious beginner or a seasoned enthusiast, we have everything you need to expand your knowledge and dive deeper into the cosmos.',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          '1. Courses:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Immerse yourself in our comprehensive courses, where you can delve into various astronomical concepts and expand your understanding of the universe. From celestial mechanics to stellar evolution, our courses cover a wide range of captivating topics.',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          '2. Quiz:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Test your knowledge with our interactive quizzes on astronomy. Challenge yourself and discover how much you have learned along the way. Sharpen your astronomical skills while having fun!',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          '3. Latest News:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Stay up to date with the latest discoveries and news in the field of astronomy. Explore groundbreaking research, cosmic events, and scientific advancements that shape our understanding of the universe.',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          '4. Photo Library:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Immerse yourself in a captivating collection of stunning astronomical photographs. Get ready to witness the breathtaking beauty of celestial objects, distant galaxies, and celestial phenomena. Let these awe-inspiring images ignite your sense of wonder and awe.',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          '5. Glossary:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Consult our comprehensive glossary to unravel the intricate terminology of astronomy. From astronomical objects to scientific terms, our glossary provides clear explanations, making complex concepts more accessible and understandable.',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          'In addition to these features, our app presents you with a new "Word of the Day" and a mesmerizing "Media of the Day" every day. Expand your astronomical vocabulary and indulge in visually stunning media that showcases the wonders of the universe.',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          'We hope our Astronomy App enriches your astronomical journey and ignites a lifelong passion for exploring the cosmos. Embark on an awe-inspiring adventure as you uncover the mysteries of the universe and gain a deeper appreciation for the wonders that surround us.',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          'Thank you for choosing our Astronomy App!',
        textAlign: TextAlign.end,),
      ],
    ),
    );
  }
}

class TermsAndConditions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Terms and Conditions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'By using this application, you agree to the following terms and conditions:',
        textAlign: TextAlign.justify,),
        SizedBox(height: 16),
        Text(
          '1. Content Usage:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'All the content provided in this application, including text, images, and media, is for informational and educational purposes only. It should not be considered as professional advice or a substitute for consultation with experts.',
       textAlign: TextAlign.justify ),
        SizedBox(height: 16),
        Text(
          '2. Accuracy and Completeness:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'While we strive to ensure the accuracy and completeness of the information presented in this application, we cannot guarantee that it is entirely error-free. Users are advised to verify the information and consult additional sources if needed.',
        textAlign: TextAlign.justify),
        SizedBox(height: 16),
        Text(
          '3. Third-Party Content:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'This application may include links to third-party websites or external content. We do not endorse or take responsibility for the accuracy, reliability, or availability of such content. Users are advised to review the terms and privacy policies of these third-party sources.',
       textAlign: TextAlign.justify ),
        SizedBox(height: 16),
        Text(
          '4. User Responsibilities:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Users are solely responsible for their actions and usage of this application. Any misuse or unauthorized activities that violate applicable laws or regulations are strictly prohibited.',
        textAlign: TextAlign.justify),
        SizedBox(height: 16),
        Text(
          'By continuing to use this application, you acknowledge that you have read, understood, and agreed to abide by these terms and conditions. If you do not agree with any part of these terms, please refrain from using this application.',
        textAlign: TextAlign.justify),
      ],
    )
    );
  }
}
