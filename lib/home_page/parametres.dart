import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Parametres extends StatefulWidget {
  const Parametres({
    Key key,
  }) : super(key: key);

  @override
  State createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  String _apiUri;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiUri = Config.apiURI;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Flexible(
              flex: 2,
              child: TextFormField(
                initialValue: Config.apiURI,
                decoration: InputDecoration(
                  labelText: "API URI",
                ),
                onChanged: (val) {
                  setState(() {
                    _apiUri = val;
                  });
                },
              ),
            ),
            Flexible(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.save),
                      onPressed: () {
                        Config.apiURI = _apiUri;
                        SharedPreferences.getInstance()
                            .then((sharedPreferences) {
                          sharedPreferences.setString("api", _apiUri);
                        });
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
