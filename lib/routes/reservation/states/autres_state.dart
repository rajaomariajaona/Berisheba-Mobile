import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

class AutresState extends ChangeNotifier {
  int __isLoading = 0;
  int get isLoading => __isLoading;
  set _isLoading(int val) {
    __isLoading = val;
    notifyListeners();
  }

  Map<int, Map<String, dynamic>> _stats = {};
  Map<int, Map<Appareil, int>> _autres = {};
  Map<int, Map<String, dynamic>> get statsByIdReservation => _stats;
  Map<int, Map<Appareil, int>> get autresByIdReservation => _autres;
  Future fetchData(int idReservation) async {

    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = idReservation;
      var response = await _dio.get("/autres/$idReservation");
      _stats[idReservation] = response.data["stats"];
      _autres[idReservation] = {};
       (response.data["data"] as List<dynamic>).forEach((dynamic item) {
           _autres[idReservation][Appareil(
              id: item["appareilIdAppareil"]["idAppareil"],
              nom: item["appareilIdAppareil"]["nomAppareil"],
              puissance: item["appareilIdAppareil"]["puissance"] + 0.0,
          )] = 
            item["duree"];
         print(_autres[idReservation]);
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
      await _dio.post("/autres/$idReservation", data: data);
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
      await _dio.put("/autres/$idReservation", data: data);
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }

  static Future<bool> removeData({@required idAppareil,@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.delete("/autres/$idAppareil");
      _refresh(idReservation);
      return true;
    } catch (error) {
      print(error?.response?.data);
      return false;
    }
  }
  static void _refresh(int idReservation){
    GlobalState().channel.sink.add("autres $idReservation");
  }

  AutresState() {
    GlobalState().externalStreamController.stream.listen((msg) async {
      if (msg.contains("autres")) {
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
