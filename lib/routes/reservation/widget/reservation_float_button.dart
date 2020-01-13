import 'package:berisheba/routes/reservation/reservation_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationFloatButton extends StatelessWidget {
  Future<dynamic> _showForm(BuildContext context) async {
    return await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(),
        body: Container(),
      ),
    ));
  }

  Icon _buttonIcon = const Icon(Icons.calendar_today);

  FloatingActionButton _buildButton(BuildContext context) {
    return FloatingActionButton(
      child: _buttonIcon,
      onPressed: () async {
//        var t = await this._showForm(context);
        Provider.of<ReservationState>(context).fetchData("1-53");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<ReservationState>(context).isDeletingReservation
        ? Container()
        : _buildButton(context);
  }
}
