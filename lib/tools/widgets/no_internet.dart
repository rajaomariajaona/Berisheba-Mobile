import 'package:berisheba/main.dart';
import 'package:berisheba/states/authorization_state.dart';
import 'package:berisheba/states/connected_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  static String route;
  const NoInternet({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _NoInternetBody();
  }
}

class _NoInternetBody extends StatefulWidget {
  const _NoInternetBody({
    Key key,
  }) : super(key: key);

  @override
  __NoInternetBodyState createState() => __NoInternetBodyState();
}

class __NoInternetBodyState extends State<_NoInternetBody> {
  bool isPressing = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          return Future.value(false);
        },
        child: Center(
          child: Container(
            child: RaisedButton(
              child: Text("Actualiser"),
              onPressed: isPressing
                  ? null
                  : () async {
                      setState(() {
                        isPressing = true;
                      });
                      await GlobalState().connect();
                      await Future.delayed(Duration(seconds: 1))
                          .then((_) async {
                        if (ConnectedState().isConnected) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                            if (MyApp.splashScreen.isCurrent) {
                              await AuthorizationState
                                      .checkAuthorizationAndInternet()
                                  .whenComplete(() {
                                if (AuthorizationState().isAuthorized)
                                  Navigator.of(context)
                                      .pushReplacementNamed('/');
                                else
                                  Navigator.of(context)
                                      .pushReplacementNamed('not-authorized');
                              });
                            }
                          } else {
                            if (AuthorizationState().isAuthorized)
                              Navigator.of(context).pushReplacementNamed('/');
                            else
                              Navigator.of(context)
                                  .pushReplacementNamed('not-authorized');
                          }
                        }
                      });
                      setState(() {
                        isPressing = false;
                      });
                    },
            ),
          ),
        ),
      ),
    );
  }
}
