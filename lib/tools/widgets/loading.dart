import 'package:berisheba/states/config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  const Loading({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SpinKitDualRing(
          color: Config.primaryBlue,
          size: 20,
          lineWidth: 3,
        ),
      ),
    );
  }
}