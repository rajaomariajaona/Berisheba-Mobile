import 'package:berisheba/config.dart';
import 'package:berisheba/squellete.dart';
import 'package:berisheba/states/client_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Berisheba',
      debugShowCheckedModeBanner: false,
      theme: t,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<GlobalState>.value(value: GlobalState()),
          ChangeNotifierProvider<TabState>.value(value: TabState()),
          ChangeNotifierProvider<ClientState>.value(value: ClientState())
        ],
        child: Squellete(),
      ),
    );
  }
}
