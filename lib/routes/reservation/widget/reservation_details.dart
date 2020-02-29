import 'package:berisheba/routes/reservation/states/autres_state.dart';
import 'package:berisheba/routes/reservation/states/concerner_state.dart';
import 'package:berisheba/routes/reservation/states/conflit_state.dart';
import 'package:berisheba/routes/reservation/states/constituer_state.dart';
import 'package:berisheba/routes/reservation/states/emprunter_state.dart';
import 'package:berisheba/routes/reservation/states/jirama_state.dart';
import 'package:berisheba/routes/reservation/states/louer_state.dart';
import 'package:berisheba/routes/reservation/states/payer_state.dart';
import 'package:berisheba/routes/reservation/states/reservation_state.dart';
import 'package:berisheba/routes/reservation/widget/details/autres.dart';
import 'package:berisheba/routes/reservation/widget/details/demi_journee.dart';
import 'package:berisheba/routes/reservation/widget/details/globaldetails.dart';
import 'package:berisheba/routes/reservation/widget/details/jirama.dart';
import 'package:berisheba/routes/reservation/widget/details/materiels.dart';
import 'package:berisheba/routes/reservation/widget/details/paiement.dart';
import 'package:berisheba/routes/reservation/widget/details/salles.dart';
import 'package:berisheba/routes/reservation/widget/details/ustensiles.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/printing/pdf_generator.dart';
import 'package:berisheba/tools/printing/pdf_screen.dart';
import 'package:berisheba/tools/widgets/confirm.dart';
import 'package:berisheba/tools/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum Actions { salle, materiel, ustensile, jirama, autres, payer }

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
  bool isReadOnly = true;
  @override
  void initState() {
    final ConflitState _conflitState =
        Provider.of<ConflitState>(context, listen: false);
    _conflitState
        .fetchConflit(widget._idReservation)
        .then((bool containConflit) {
      var temp = Provider.of<ConflitState>(context, listen: false)
          .conflictByIdReservation[widget._idReservation];
      if (temp != null && temp.isNotEmpty) {
        Navigator.of(context).pushNamed("conflit/:${widget._idReservation}");
      }
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    refresh();
  }

  Future refresh({bool force = false}) async {
    final ConstituerState _constituerState =
        Provider.of<ConstituerState>(context, listen: false);
    final JiramaState _jiramaState =
        Provider.of<JiramaState>(context, listen: false);
    final AutresState _autresState =
        Provider.of<AutresState>(context, listen: false);
    final ConcernerState _concernerState =
        Provider.of<ConcernerState>(context, listen: false);
    final LouerState _louerState =
        Provider.of<LouerState>(context, listen: false);
    final EmprunterState _emprunterState =
        Provider.of<EmprunterState>(context, listen: false);
    final PayerState _payerState =
        Provider.of<PayerState>(context, listen: false);
    if (!_constituerState.demiJourneesByReservation
            .containsKey(widget._idReservation) ||
        force) await _constituerState.fetchData(widget._idReservation);
    if (!_jiramaState.jiramaByIdReservation
            .containsKey(widget._idReservation) ||
        force) await _jiramaState.fetchData(widget._idReservation);
    if (!_autresState.autresByIdReservation
            .containsKey(widget._idReservation) ||
        force) await _autresState.fetchData(widget._idReservation);
    if (!_concernerState.sallesByIdReservation
            .containsKey(widget._idReservation) ||
        force) _concernerState.fetchData(widget._idReservation);
    if (!_louerState.materielsLoueeByIdReservation
            .containsKey(widget._idReservation) ||
        force) await _louerState.fetchData(widget._idReservation);
    if (!_emprunterState.ustensilesEmprunteByIdReservation
            .containsKey(widget._idReservation) ||
        force) await _emprunterState.fetchData(widget._idReservation);
    if (!_payerState.statsByIdReservation.containsKey(widget._idReservation) ||
        force) await _payerState.fetchData(widget._idReservation);
  }

  @override
  Widget build(BuildContext context) {
    final ReservationState reservationState =
        Provider.of<ReservationState>(context);
    final ConflitState conflitState = Provider.of<ConflitState>(context);
    return reservationState.reservationsById[widget._idReservation] == null
        ? Scaffold(
            appBar: AppBar(),
            body: Center(
              child: (reservationState.isLoading ||
                      (conflitState.isLoading == widget._idReservation))
                  ? Loading()
                  : Text("La reservation a été supprimée"),
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
                  ReservationGlobalDetails(widget._idReservation,
                      readOnly: isReadOnly),
                  ReservationDemiJournee(widget._idReservation,
                      readOnly: isReadOnly),
                  Consumer<ConcernerState>(
                      builder: (ctx, concernerState, __) =>
                          concernerState.sallesByIdReservation[
                                          widget._idReservation] !=
                                      null &&
                                  concernerState
                                          .sallesByIdReservation[
                                              widget._idReservation]
                                          .length >
                                      0
                              ? ReservationSalle(widget._idReservation,
                                  readOnly: isReadOnly)
                              : Container()),
                  Consumer<EmprunterState>(
                      builder: (ctx, emprunterState, __) =>
                          emprunterState.ustensilesEmprunteByIdReservation[
                                          widget._idReservation] !=
                                      null &&
                                  emprunterState
                                          .ustensilesEmprunteByIdReservation[
                                              widget._idReservation]
                                          .length >
                                      0
                              ? ReservationUstensile(widget._idReservation,
                                  readOnly: isReadOnly)
                              : Container()),
                  Consumer<LouerState>(
                      builder: (ctx, louerState, __) =>
                          louerState.materielsLoueeByIdReservation[
                                          widget._idReservation] !=
                                      null &&
                                  louerState
                                          .materielsLoueeByIdReservation[
                                              widget._idReservation]
                                          .length >
                                      0
                              ? ReservationMateriel(widget._idReservation,
                                  readOnly: isReadOnly)
                              : Container()),
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
                              ? ReservationJirama(widget._idReservation,
                                  readOnly: isReadOnly)
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
                              ? ReservationAutres(widget._idReservation,
                                  readOnly: isReadOnly)
                              : Container()),
                  ReservationPayer(widget._idReservation, readOnly: isReadOnly)
                ],
              ),
            ),
          );
  }

  List<Widget> _actionsAppBar(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.picture_as_pdf),
        onPressed: () async {
          PdfGenerator pdf = PdfGenerator();
          var path = await pdf.saveFacture(widget._idReservation);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => PDFScreen(
                pathPDF: path,
              ),
            ),
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.refresh),
        onPressed: () async {
          await refresh(force: true);
        },
      ),
      if (isReadOnly)
        IconButton(
          icon: Icon(Icons.lock_outline),
          onPressed: () {
            setState(() {
              isReadOnly = false;
            });
          },
        )
      else ...[
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () async {
            try {
              if (await Confirm.showDeleteConfirm(context: context)) {
                await ReservationState.removeData(
                    idReservation: widget._idReservation);
                Navigator.of(context).pop(true);
                GlobalState().channel.sink.add("reservation");
              }
            } catch (error) {
              print(error?.response?.data);
            }
          },
        ),
        PopupMenuButton(
          onSelected: (value) async {
            switch (value) {
              case Actions.ustensile:
                var res = await showDialog(
                  context: context,
                  builder: (BuildContext context) => UstensileDialog(
                    idReservation: widget._idReservation,
                  ),
                );
                if (res != null) {
                  await EmprunterState.saveData({"idUstensile": res},
                          idReservation: widget._idReservation)
                      .whenComplete(() {
                    Provider.of<ConflitState>(context, listen: false)
                        .fetchConflit(widget._idReservation)
                        .then((bool containConflit) {
                      if (containConflit) {
                        Navigator.of(context)
                            .pushNamed("conflit/:${widget._idReservation}");
                      }
                    });
                  });
                }
                break;
              case Actions.materiel:
                var res = await showDialog(
                  context: context,
                  builder: (BuildContext context) =>
                      MaterielDialog(idReservation: widget._idReservation),
                );
                if (res != null) {
                  await LouerState.saveData({"idMateriel": res},
                          idReservation: widget._idReservation)
                      .whenComplete(() {
                    Provider.of<ConflitState>(context, listen: false)
                        .fetchConflit(widget._idReservation)
                        .then((bool containConflit) {
                      if (containConflit) {
                        Navigator.of(context)
                            .pushNamed("conflit/:${widget._idReservation}");
                      }
                    });
                  });
                }
                break;
              case Actions.salle:
                var res = await showDialog(
                  context: context,
                  builder: (BuildContext context) => SalleDialog(
                    idReservation: widget._idReservation,
                  ),
                );
                if (res != null) {
                  await ConcernerState.saveData({"idSalle": res},
                          idReservation: widget._idReservation)
                      .whenComplete(() {
                    Provider.of<ConflitState>(context, listen: false)
                        .fetchConflit(widget._idReservation)
                        .then((bool containConflit) {
                      if (containConflit) {
                        Navigator.of(context)
                            .pushNamed("conflit/:${widget._idReservation}");
                      }
                    });
                  });
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
                        return AutresDialog(
                            idReservation: widget._idReservation);
                      },
                      context: context);
                } catch (error) {}
                break;
              case Actions.payer:
                try {
                  showDialog(
                      builder: (BuildContext context) {
                        return PayerDialog(
                            idReservation: widget._idReservation);
                      },
                      context: context);
                } catch (error) {}
                break;
              default:
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text("Salle"),
              value: Actions.salle,
            ),
            PopupMenuItem(
              child: const Text("Ustensile"),
              value: Actions.ustensile,
            ),
            PopupMenuItem(
              child: const Text("Materiels"),
              value: Actions.materiel,
            ),
            PopupMenuItem(
              child: const Text("Ustensile"),
              value: Actions.ustensile,
            ),
            PopupMenuItem(
              child: const Text("Jirama"),
              value: Actions.jirama,
            ),
            PopupMenuItem(
              child: const Text("Autres"),
              value: Actions.autres,
            ),
            PopupMenuItem(
              child: const Text("Payer"),
              value: Actions.payer,
            ),
          ],
        )
      ]
    ];
  }
}
