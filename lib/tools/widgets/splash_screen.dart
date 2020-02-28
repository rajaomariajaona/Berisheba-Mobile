import 'package:berisheba/main.dart';
import 'package:berisheba/states/authorization_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _StatefulWrapper(
      onInit: () async {
        await AuthorizationState.checkAuthorizationAndInternet()
            .whenComplete(() async {
          await Future.delayed(Duration(seconds: 1)).whenComplete(() async {
            var route = "/";
            if (!AuthorizationState().isAuthorized) route = "not-authorized";
            if (!MyApp.noInternet.isCurrent) {
              if (!MyApp.notAuthorized.isCurrent)
                await GlobalState()
                    .navigatorState
                    .currentState
                    .pushReplacementNamed(route);
            }
          });
        });
      },
    );
  }
}

class _StatefulWrapper extends StatefulWidget {
  final VoidCallback onInit;
  const _StatefulWrapper({
    this.onInit,
    Key key,
  }) : super(key: key);

  @override
  __StatefulWrapperState createState() => __StatefulWrapperState();
}

class __StatefulWrapperState extends State<_StatefulWrapper> {
  @override
  void initState() {
    super.initState();
  }

  bool first = true;
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (first) {
        widget.onInit();
        first = false;
      }
    });
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Image.asset("assets/logo.png"),
          ),
          Flexible(
            child: Loading(),
          ),
        ],
      ),
    );
  }
}
