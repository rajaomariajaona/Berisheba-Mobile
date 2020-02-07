import 'package:berisheba/routes/reservation/states/autres_state.dart';
import 'package:berisheba/routes/reservation/states/concerner_state.dart';
import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/routes/reservation/states/constituer_state.dart';
import 'package:berisheba/routes/reservation/states/jirama_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/details/autres.dart';
import 'package:berisheba/routes/reservation/widget/details/demi_journee.dart';
import 'package:berisheba/routes/reservation/widget/details/globaldetails.dart';
import 'package:berisheba/routes/reservation/widget/details/jirama.dart';
import 'package:berisheba/routes/reservation/widget/details/salles.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Actions { supprimer, jirama, autres }

class ReservationDetails extends StatelessWidget {
  final int _idReservation;
  ReservationDetails(this._idReservation, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReservationDetailsBody(_idReservation);
  }
}

class ReservationDetailsBody extends StatefulWidget {
  final int _idReservation;
  ReservationDetailsBody(this._idReservation, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ReservationDetailsState();
}

class _ReservationDetailsState extends State<ReservationDetailsBody> {
  @override
  void initState() {
    final ConflitState _conflitState =
        Provider.of<ConflitState>(context, listen: false);
    _conflitState
        .fetchConflit(widget._idReservation)
        .then((bool containConflit) {
      var temp = Provider.of<ConflitState>(context, listen: false)
          .conflictByIdReservation[widget._idReservation];
      if (temp != null) {
        Navigator.of(context).pushNamed("conflit/:${widget._idReservation}");
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ConstituerState _constituerState =
        Provider.of<ConstituerState>(context, listen: false);
    final JiramaState _jiramaState =
        Provider.of<JiramaState>(context, listen: false);
    final AutresState _autresState =
        Provider.of<AutresState>(context, listen: false);
    final ConcernerState _concernerState =
        Provider.of<ConcernerState>(context, listen: false);
    _fetchData(_constituerState, _jiramaState, _autresState, _concernerState);
  }

  void _fetchData(ConstituerState _constituerState, JiramaState _jiramaState,
      AutresState _autresState, ConcernerState _concernerState) {
    if (!_constituerState.demiJourneesByReservation
        .containsKey(widget._idReservation))
      _constituerState.fetchData(widget._idReservation);
    if (!_jiramaState.jiramaByIdReservation.containsKey(widget._idReservation))
      _jiramaState.fetchData(widget._idReservation);
    if (!_autresState.autresByIdReservation.containsKey(widget._idReservation))
      _autresState.fetchData(widget._idReservation);
    if (!_concernerState.sallesByIdReservation
        .containsKey(widget._idReservation))
      _concernerState.fetchData(widget._idReservation);
  }

  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    return reservationState.reservationsById[widget._idReservation] == null
        ? Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text("La reservation a été supprimée"),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(
                  "${reservationState.reservationsById[widget._idReservation]["nomReservation"]}"),
              actions: _actionsAppBar(context),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ReservationGlobalDetails(widget._idReservation),
                  ReservationDemiJournee(widget._idReservation),
                  ReservationSalle(widget._idReservation),
                  Consumer<JiramaState>(
                      builder: (ctx, jiramaState, __) =>
                          jiramaState.jiramaByIdReservation[
                                          widget._idReservation] !=
                                      null &&
                                  jiramaState
                                          .jiramaByIdReservation[
                                              widget._idReservation]
                                          .length >
                                      0
                              ? ReservationJirama(widget._idReservation)
                              : Container()),
                  Consumer<AutresState>(
                      builder: (ctx, autresState, __) =>
                          autresState.autresByIdReservation[
                                          widget._idReservation] !=
                                      null &&
                                  autresState
                                          .autresByIdReservation[
                                              widget._idReservation]
                                          .length >
                                      0
                              ? ReservationAutres(widget._idReservation)
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
                    idReservation: widget._idReservation);
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
                      return JiramaPriceDialog(
                          idReservation: widget._idReservation);
                    },
                    context: context);
              } catch (error) {}
              break;
            case Actions.autres:
              try {
                showDialog(
                    builder: (BuildContext context) {
                      return AutresDialog(idReservation: widget._idReservation);
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
