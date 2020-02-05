import 'package:berisheba/routes/reservation/states/autres_state.dart';
import 'package:berisheba/routes/reservation/states/jirama_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/details/autres.dart';
import 'package:berisheba/routes/reservation/widget/details/demi_journee.dart';
import 'package:berisheba/routes/reservation/widget/details/globaldetails.dart';
import 'package:berisheba/routes/reservation/widget/details/jirama.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Actions { supprimer, jirama, autres}

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
              actions: _actionsAppBar(context),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ReservationGlobalDetails(_idReservation),
                  ReservationDemiJournee(_idReservation),
                  Consumer<JiramaState>(
                      builder: (ctx, jiramaState, __) => jiramaState
                                  .jiramaByIdReservation[_idReservation]
                                  .length >
                              0
                          ? ReservationJirama(_idReservation)
                          : Container()),
                  Consumer<AutresState>(
                      builder: (ctx, autresState, __) => autresState
                                  .autresByIdReservation[_idReservation]
                                  .length >
                              0
                          ? ReservationAutres(_idReservation)
                          : Container()),
                ],
              ),
            ),
            // floatingActionButton: _customFloatButton(),
          );
  }

  List<Widget> _actionsAppBar(BuildContext context) {
    return <Widget>[
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
            case Actions.jirama:
              try {
                showDialog(
                    builder: (BuildContext context) {
                      return JiramaPriceDialog(idReservation: _idReservation);
                    },
                    context: context);
              } catch (error) {}
              break;
            case Actions.autres:
              try {
                showDialog(
                    builder: (BuildContext context) {
                      return AutresDialog(idReservation: _idReservation);
                    },
                    context: context);
              } catch (error) {}
              break;
            default:
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            child: const Text("supprimer"),
            value: Actions.supprimer,
          ),
          PopupMenuItem(
            child: const Text("jirama"),
            value: Actions.jirama,
          ),
          PopupMenuItem(
            child: const Text("autres"),
            value: Actions.autres,
          ),
        ],
      )
    ];
  }
}
