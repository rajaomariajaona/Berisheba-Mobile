import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/details/autres.dart';
import 'package:berisheba/routes/reservation/widget/details/demi_journee.dart';
import 'package:berisheba/routes/reservation/widget/details/globaldetails.dart';
import 'package:berisheba/routes/reservation/widget/details/jirama.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Actions { supprimer, jirama }

class ReservationDetails extends StatelessWidget {
  final int _idReservation;
  ReservationDetails(this._idReservation, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    return reservationState.reservationsById[_idReservation] == null
        ? Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text("La reservation a été supprimée"),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                  "${reservationState.reservationsById[_idReservation]["nomReservation"]}"),
              actions: <Widget>[
                PopupMenuButton(
                  onSelected: (value) async {
                    switch (value) {
                      case Actions.supprimer:
                        try {
                          await ReservationState.removeData(
                              idReservation: _idReservation);
                          Navigator.of(context).pop(true);
                          GlobalState().channel.sink.add("reservation");
                        } catch (error) {
                          print(error?.response?.data);
                        }
                        break;
                      default:
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("supprimer"),
                      value: Actions.supprimer,
                    ),
                    PopupMenuItem(
                      child: Text("jirama"),
                      value: Actions.jirama,
                    ),
                  ],
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ReservationGlobalDetails(_idReservation),
                  ReservationDemiJournee(_idReservation),
                  ReservationJirama(_idReservation),
                  ReservationAutres(_idReservation),
                ],
              ),
            ),
            // floatingActionButton: _customFloatButton(),
          );
  }
}

class _customFloatButton extends StatelessWidget {
  const _customFloatButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      overflow: Overflow.visible,
      children: <Widget>[
        FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {},
        ),
        //   Positioned(
        //     bottom: 65,
        //     child: Column(
        //       children: <Widget>[
        //         Padding(
        //           padding: const EdgeInsets.symmetric(vertical:4.0),
        //           child: FloatingActionButton(
        //             child: Icon(Icons.wb_incandescent),
        //             onPressed: () {},
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.symmetric(vertical:4.0),
        //           child: FloatingActionButton(
        //             child: Icon(Icons.location_city),
        //             onPressed: () {},
        //           ),
        //         ),
        //         Padding(
        //           padding: const EdgeInsets.symmetric(vertical:4.0),
        //           child: FloatingActionButton(
        //             child: Icon(Icons.dashboard),
        //             onPressed: () {},
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    );
  }
}
