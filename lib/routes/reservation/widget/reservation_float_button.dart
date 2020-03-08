import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/reservation_formulaire.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReservationFloatButton extends StatelessWidget {
  Future<dynamic> _showForm(BuildContext context) async {
    return await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => ReservationFormulaire(),
    ));
  }

  final Icon _buttonIcon = const Icon(Icons.calendar_today);

  FloatingActionButton _buildButton(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    return FloatingActionButton(
      child: _buttonIcon,
      onPressed: () async {
        this._showForm(context).then((result) {
          if (result != null) {
            reservationState.selectedDay = DateTime.parse(result);
          }
        });
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
