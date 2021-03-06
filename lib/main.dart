import 'package:berisheba/home_page/home_page.dart';
import 'package:berisheba/routes/client/client_state.dart';
import 'package:berisheba/routes/materiel/materiel_state.dart';
import 'package:berisheba/routes/reservation/states/autres_state.dart';
import 'package:berisheba/routes/reservation/states/concerner_state.dart';
import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/routes/reservation/states/constituer_state.dart';
import 'package:berisheba/routes/reservation/states/emprunter_state.dart';
import 'package:berisheba/routes/reservation/states/jirama_state.dart';
import 'package:berisheba/routes/reservation/states/louer_state.dart';
import 'package:berisheba/routes/reservation/states/payer_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/reservation_details.dart';
import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/routes/statistique/statistique_state.dart';
import 'package:berisheba/routes/ustensile/ustensile_state.dart';
import 'package:berisheba/states/authorization_state.dart';
import 'package:berisheba/states/config.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:berisheba/tools/widgets/conflit.dart';
import 'package:berisheba/tools/widgets/no_internet.dart';
import 'package:berisheba/tools/widgets/not_authorized.dart';
import 'package:berisheba/tools/widgets/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NOTE: if you want to find out if the app was launched via notification then you could use the following call and then do something like
  // change the default route of the app
  // var notificationAppLaunchDetails =
  //     await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await MyApp.flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    GlobalState().internalStreamController.sink.add(payload);
  });

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
      systemNavigationBarColor: Config.primaryBlue);
  SystemChrome.setSystemUIOverlayStyle(style);
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);
}

class MyApp extends StatelessWidget {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ThemeData t = ThemeData(
    primarySwatch: Colors.lightBlue,
    fontFamily: "Source Sans Pro"
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
    buttonColor: Config.primaryBlue,
  );
  final GlobalKey navigatorState = GlobalKey<NavigatorState>();

  MyApp() {
    GlobalState().navigatorState = navigatorState;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthorizationState()),
        ChangeNotifierProvider(create: (_) => GlobalState()),
        ChangeNotifierProvider(create: (_) => TabState()),
        ChangeNotifierProvider(create: (_) => ClientState()),
        ChangeNotifierProvider(create: (_) => ReservationState()),
        ChangeNotifierProvider(create: (_) => MaterielState()),
        ChangeNotifierProvider(create: (_) => ConstituerState()),
        ChangeNotifierProvider(create: (_) => JiramaState()),
        ChangeNotifierProvider(create: (_) => AutresState()),
        ChangeNotifierProvider(create: (_) => SalleState()),
        ChangeNotifierProvider(create: (_) => ConcernerState()),
        ChangeNotifierProvider(create: (_) => LouerState()),
        ChangeNotifierProvider(create: (_) => EmprunterState()),
        ChangeNotifierProvider(create: (_) => UstensileState()),
        ChangeNotifierProvider(create: (_) => ConflitState()),
        ChangeNotifierProvider(create: (_) => PayerState()),
        ChangeNotifierProvider(create: (_) => StatistiqueState()),
        ChangeNotifierProvider(
          create: (_) => AuthorizationState(),
        )
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
        initialRoute: "splash-screen",
        onGenerateRoute: _handleRoute,
      ),
    );
  }

  Route<dynamic> _handleRoute(RouteSettings settings) {
    String routeName = settings.name;
    // if(routeName.contains("pdf")){
    //   List<String> params =
    // }else
    if (routeName.contains("reservation")) {
      List<String> params = routeName.split(":");
      if (params.length == 2) {
        int idReservation = int.tryParse(params[1]);
        if (idReservation != null)
          return MaterialPageRoute(builder: (ctx) {
            return ReservationDetails(idReservation);
          });
      }
    } else if (routeName.contains("conflit")) {
      List<String> params = routeName.split(":");
      if (params.length == 2) {
        int idReservation = int.tryParse(params[1]);
        if (idReservation != null)
          return MaterialPageRoute(
              builder: (ctx) => ConflitResolver(
                    idReservation: idReservation,
                  ));
      }
    } else {
      switch (routeName) {
        case "no-internet":
          MyApp.noInternet =
              (() => MaterialPageRoute(builder: (ctx) => NoInternet()))();
          return MyApp.noInternet;
          break;
        case "not-authorized":
          MyApp.notAuthorized =
              (() => MaterialPageRoute(builder: (ctx) => NotAuthorized()))();
          return MyApp.notAuthorized;

          break;
        case "splash-screen":
          MyApp.splashScreen =
              (() => MaterialPageRoute(builder: (ctx) => SplashScreen()))();
          return MyApp.splashScreen;
        case "/":
          MyApp.home = (() => MaterialPageRoute(builder: (ctx) => Squellete()))();
          return MyApp.home;
        default:
          return null;
      }
    }
    return null;
  }

  static Route home;
  static Route splashScreen;
  static Route noInternet;
  static Route notAuthorized;
}
