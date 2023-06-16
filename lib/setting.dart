import 'package:flutter/material.dart';


class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkThemeEnabled = false;
  bool _isNotificationEnabled = true;
  String _selectedLanguage = 'Français';

  List<String> _languages = ['Français', 'English', 'Español', 'Deutsch'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text('Langue'),
            subtitle: Text(_selectedLanguage),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              _showLanguageDialog();
            },
          ),
          ListTile(
            title: Text('Aide'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Naviguer vers l'écran d'aide
            },
          ),
          ListTile(
            title: Text('À propos'),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Naviguer vers l'écran À propos
            },
          ),
          SwitchListTile(
            title: Text('Thème sombre'),
            value: _isDarkThemeEnabled,
            onChanged: (value) {
              setState(() {
                _isDarkThemeEnabled = value;
              });
              // Changer le thème de l'application
            },
          ),
          SwitchListTile(
            title: Text('Notifications'),
            value: _isNotificationEnabled,
            onChanged: (value) {
              setState(() {
                _isNotificationEnabled = value;
              });
              // Gérer les paramètres de notifications
            },
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sélectionner une langue'),
          content: SingleChildScrollView(
            child: ListBody(
              children: _languages.map((language) {
                return GestureDetector(
                  child: Text(language),
                  onTap: () {
                    setState(() {
                      _selectedLanguage = language;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Paramètres'),
    );
  }
}