import 'package:berisheba/routes/salle/salle_state.dart';
import 'package:berisheba/routes/salle/widgets/salle_formulaire.dart';
import 'package:berisheba/states/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SalleDetail extends StatelessWidget {
  final int _idSalle;

  const SalleDetail(this._idSalle);

  @override
  Widget build(BuildContext context) {
    SalleState salleState = Provider.of<SalleState>(context);
    Map<String, dynamic> _salle = salleState
        .listSalleByIdSalle["$_idSalle"];
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Config.appBarBgColor,
        centerTitle: true,
        title: Text(
          _salle == null ? "Salle" : _salle["nomSalle"],
          style: TextStyle(color: Config.appBarTextColor),
        ),
        iconTheme: IconThemeData(color: Config.primaryBlue),
        actions: _salle == null
            ? null
            : <Widget>[
          IconButton(
            icon: const Icon(
              Icons.delete,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SalleFormulaire(
                      salle: _salle,
                    ),
              ));
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: _salle == null
            ? Center(
          child: Text("Ce salle vient d'etre supprimer"),
        )
            : Flex(
          direction: Axis.vertical,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: <Widget>[
                      ListTile(
                        leading: IconButton(
                          icon: const Icon(Icons.contact_phone),
                          onPressed: () {},
                        ),
                        title: Text(
                            "${_salle["nomSalle"]} ${_salle["prenomSalle"]}"),
                      ),
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.smartphone),
                          onPressed: () {},
                        ),
                        title: Text("${_salle["numTelSalle"]} "),
                        onTap: () {
                          if (canLaunch(
                              "tel:${_salle["numTelSalle"]}") !=
                              null)
                            launch("tel:${_salle["numTelSalle"]}");
                        },
                      ),
                      ListTile(
                        leading: IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () {},
                        ),
                        title: Text("${_salle["adresseSalle"]} "),
                      ),
                      Divider(),
                      Flex(
                        direction: Axis.horizontal,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.call),
                            onPressed: () {
                              if (canLaunch(
                                  "tel:${_salle["numTelSalle"]}") !=
                                  null)
                                launch("tel:${_salle["numTelSalle"]}");
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {},
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
