import 'package:flutter/material.dart';
import 'package:image/image.dart' as images;

enum ErrorType { internet, authorization, none }

class Config {
  static images.Image img;
  //api
  static String get baseURI => apiURI.replaceFirst("/api/", "");
  static String apiURI = "http://10.0.2.2:3000/api/";

  static String get wsURI =>
      apiURI.replaceFirst("http", "ws").replaceFirst("/api/", "");

  static Color get primaryBlue => Color.fromARGB(255, 55, 171, 200);
  static Color get secondaryBlue => Color.fromARGB(255, 241, 249, 255);

  // Accueil Nav

  static Color get acceuilNavItemColor => Config.primaryBlue;

  static Map<String, IconData> get navIcons => <String, IconData>{
        "acceuil": Icons.home,
        "client": Icons.supervised_user_circle,
        "reservation": Icons.calendar_today,
        "salle": Icons.location_city,
        "materiel": Icons.dashboard,
        "ustensile": Icons.local_dining,
        "statistique": Icons.show_chart
      };

  static List<String> get routesName => <String>[
        "Acceuil",
        "Client",
        "Reservation",
        "Salle",
        "Materiel",
        "Ustensile",
        "Statistique"
      ];

  //App bar
  static Color get appBarBgColor => Config.secondaryBlue;
  static Color get appBarTextColor => Config.primaryBlue;

  // Bottom nav bar

  static Color get bottomNavIconsColor => Config.primaryBlue;
  static Color get bottomNavTextColor => Config.primaryBlue;
  static Color get bottomNavBgColor => Config.secondaryBlue;
}
