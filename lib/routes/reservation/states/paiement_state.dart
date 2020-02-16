import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class PaiementState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    __isLoading = val;
    notifyListeners();
  }

  Map<int, Map<String, dynamic>> _stats = {};
  Map<int, Map<Appareil, int>> _paiement = {};
  Map<int, Map<String, dynamic>> get statsByIdReservation => _stats;
  Map<int, Map<Appareil, int>> get paiementByIdReservation => _paiement;
  Future fetchData(int idReservation) async {

    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = idReservation;
      var response = await _dio.get("/paiement/$idReservation");
      _stats[idReservation] = response.data["stats"];
      _paiement[idReservation] = {};
       (response.data["data"] as List<dynamic>).forEach((dynamic item) {
           _paiement[idReservation][Appareil(
              id: item["appareilIdAppareil"]["idAppareil"],
              nom: item["appareilIdAppareil"]["nomAppareil"],
              puissance: item["appareilIdAppareil"]["puissance"] + 0.0,
          )] = 
            item["duree"];
      });
      notifyListeners();
      _isLoading = 0;
      return true;
    } catch (error) {
      print(error);
      _isLoading = 0;
      return false;
    }
  }

  static Future<bool> saveData(dynamic data, {@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.post("/paiement/$idReservation", data: data);
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> modifyData(dynamic data,
      {@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.put("/paiement/$idReservation", data: data);
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }
  static Future<bool> patchPrixKW(dynamic data,
      {@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.patch("/reservations/$idReservation", data: data);
      GlobalState().channel.sink.add("reservation $idReservation");
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> removeData({@required idAppareil,@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.delete("/paiement/$idAppareil");
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }
  static void _refresh(int idReservation){
    GlobalState().channel.sink.add("paiement $idReservation");
  }

  PaiementState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg.contains("paiement")) {
        await this.fetchData(int.parse(msg.split(" ")[1]));
      }
    });
  }
}

class Appareil {
  final String nom;
  final double puissance;
  final int id;
  const Appareil(
      {@required this.nom, @required this.puissance, @required this.id});

  bool operator ==(appareil) =>
      appareil is Appareil &&
      appareil.id == id &&
      appareil.nom == nom &&
      appareil.puissance == puissance;
  int get hashCode => nom.hashCode ^ puissance.hashCode ^ id.hashCode;
}