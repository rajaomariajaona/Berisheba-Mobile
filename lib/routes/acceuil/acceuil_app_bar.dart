import 'package:berisheba/states/tab_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class AcceuilAppBar {
  AcceuilAppBar(this.context);
  BuildContext context;
  PreferredSize get appbar {
    return PreferredSize(
      preferredSize: Size(null, 100),
      child: SafeArea(
          child: Container(
        color: Theme.of(context).primaryColor,
        width: MediaQuery.of(context).size.width,
        // Set Appbar wave height
        child: Container(
          height: 80,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Container(
              color: Colors.white,
              child: Stack(
                children: <Widget>[
                  RotatedBox(
                      quarterTurns: 2,
                      child: WaveWidget(
                        config: CustomConfig(
                          colors: [Theme.of(context).primaryColor],
                          durations: [22000],
                          heightPercentages: [-0.1],
                        ),
                        size: Size(double.infinity, double.infinity),
                        waveAmplitude: 1,
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                          padding: EdgeInsets.only(left: 15),
                          child:
                              Consumer<TabState>(builder: (_, _tabState, __) {
                            return Text(
                              _tabState.titleAppBar,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
                            );
                          })),
                    ],
                  ),
                  Positioned(
                    top: 6.0,
                    right: 6.0,
                    child: Theme(
                        data: Theme.of(context).copyWith(
                          cardColor: Theme.of(context).primaryColor,
                        ),
                        child: Container()),
                  ),
                ],
              )),
        ),
      )),
    );
  }
}
