import 'package:berisheba/config.dart';
import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:provider/provider.dart';

class AcceuilLandscape extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final tabState = Provider.of<TabState>(context);
    return Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints){
                        return AspectRatio(
                            aspectRatio: 1.0,
                            child :Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Icon(Icons.supervised_user_circle,
                                      color: Colors.white,
                                      size: constraints.maxHeight * 0.5,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: const Text("Clients",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints){
                        return AspectRatio(
                            aspectRatio: 1.0,
                            child :Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Icon(Icons.supervised_user_circle,
                                      color: Colors.white,
                                      size: constraints.maxHeight * 0.5,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: const Text("Clients",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints){
                        return AspectRatio(
                            aspectRatio: 1.0,
                            child :Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Icon(Icons.supervised_user_circle,
                                      color: Colors.white,
                                      size: constraints.maxHeight * 0.5,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: const Text("Clients",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints){
                        return AspectRatio(
                            aspectRatio: 1.0,
                            child :Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Icon(Icons.supervised_user_circle,
                                      color: Colors.white,
                                      size: constraints.maxHeight * 0.5,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: const Text("Clients",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints){
                        return AspectRatio(
                            aspectRatio: 1.0,
                            child :Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Icon(Icons.supervised_user_circle,
                                      color: Colors.white,
                                      size: constraints.maxHeight * 0.5,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: const Text("Clients",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 20,),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: LayoutBuilder(
                      builder: (BuildContext ctx, BoxConstraints constraints){
                        return AspectRatio(
                            aspectRatio: 1.0,
                            child :Container(
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Icon(Icons.supervised_user_circle,
                                      color: Colors.white,
                                      size: constraints.maxHeight * 0.5,
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: const Text("Clients",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}
