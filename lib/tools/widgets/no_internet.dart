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
                          if (GlobalState()
                              .navigatorState
                              .currentState
                              .canPop()) {
                            GlobalState().navigatorState.currentState.pop();
                            if ((MyApp.splashScreen != null) ? MyApp.splashScreen.isCurrent : false) {
                              await AuthorizationState
                                      .checkAuthorizationAndInternet()
                                  .whenComplete(() {
                                if (AuthorizationState().isAuthorized)
                                  GlobalState()
                                      .navigatorState
                                      .currentState
                                      .pushReplacementNamed('/');
                                else {
                                  if ((MyApp.notAuthorized != null) ? !MyApp.notAuthorized.isCurrent : true )
                                    GlobalState()
                                        .navigatorState
                                        .currentState
                                        .pushReplacementNamed('not-authorized');
                                }
                              });
                            }
                            if ((MyApp.notAuthorized != null) ? MyApp.notAuthorized.isCurrent : false) {
                              AuthorizationState().fetchData();
                            }
                          } else {
                            if (AuthorizationState().isAuthorized)
                              GlobalState()
                                  .navigatorState
                                  .currentState
                                  .pushReplacementNamed('/');
                            else
                              GlobalState()
                                  .navigatorState
                                  .currentState
                                  .pushReplacementNamed('not-authorized');
                          }
                        }
                      });
                      if (this.mounted) {
                        setState(() {
                          isPressing = false;
                        });
                      }
                    },
            ),
          ),
        ),
      ),
    );
  }
}
