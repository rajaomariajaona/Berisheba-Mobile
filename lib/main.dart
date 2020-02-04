import 'package:berisheba/home_page/home_page.dart';
import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/routes/reservation/states/constituer_state.dart';
import 'package:berisheba/routes/reservation/states/jirama_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
  SharedPreferences.getInstance().then((sharedPreference) {
    if (!sharedPreference.containsKey("api")) {
      sharedPreference.setString("api", Config.apiURI);
    } else {
      Config.apiURI = sharedPreference.getString("api");
    }
  });
  final SystemUiOverlayStyle style = SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Config.primaryBlue,
      systemNavigationBarColor: Config.secondaryBlue);
  SystemChrome.setSystemUIOverlayStyle(style);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final ThemeData t = ThemeData(
    primarySwatch: Colors.green,
  ).copyWith(
    appBarTheme: AppBarTheme(
      textTheme: TextTheme(
        title: TextStyle(
          color: Config.appBarTextColor,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      color: Config.secondaryBlue,
      iconTheme: IconThemeData(
        color: Config.primaryBlue,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Config.primaryBlue,
      foregroundColor: Colors.white,
    ),
    cursorColor: Config.primaryBlue,
    primaryColor: Config.primaryBlue,
    indicatorColor: Config.primaryBlue,
    textSelectionColor: Config.primaryBlue,
    textSelectionHandleColor: Config.primaryBlue,
    splashColor: Config.primaryBlue,
    toggleableActiveColor: Config.primaryBlue,
    iconTheme: IconThemeData(
      color: Config.primaryBlue,
    ),
    primaryIconTheme: IconThemeData(
      color: Config.primaryBlue,
    ),
    accentIconTheme: IconThemeData(
      color: Config.primaryBlue,
    ),
    sliderTheme: SliderThemeData(
      thumbColor: Config.primaryBlue,
      activeTickMarkColor: Config.primaryBlue,
    ),
    accentColor: Config.primaryBlue,
    highlightColor: Config.secondaryBlue,
    focusColor: Config.primaryBlue,
  );
  final GlobalKey navigatorState = GlobalKey<NavigatorState>();

  MyApp() {
    GlobalState().navigatorState = navigatorState;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalState()),
        ChangeNotifierProvider(create: (_) => TabState()),
        ChangeNotifierProvider(create: (_) => ClientState()),
        ChangeNotifierProvider(create: (_) => ReservationState()),
        ChangeNotifierProvider(create: (_) => MaterielState()),
        ChangeNotifierProvider(create: (_) => ConstituerState()),
        ChangeNotifierProvider(create: (_) => JiramaState()),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale("fr"),
        ],
        navigatorKey: navigatorState,
        title: 'Berisheba',
        debugShowCheckedModeBanner: false,
        theme: t,
        home: Squellete(),
      ),
    );
  }
}
