import 'package:berisheba/states/global_state.dart';
import 'package:berisheba/tools/http/request.dart';
import 'package:berisheba/tools/others/handle_dio_error.dart';
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
  Map<int, Map<Autre, double>> _autres = {};
  Map<int, Map<String, dynamic>> get statsByIdReservation => _stats;
  Map<int, Map<Autre, double>> get autresByIdReservation => _autres;
  Future fetchData(int idReservation) async {

    Dio _dio = await RestRequest().getDioInstance();
    try {
      _isLoading = idReservation;
      var response = await _dio.get("/autres/$idReservation");
      _stats[idReservation] = response.data["stats"];
      _autres[idReservation] = {};
       (response.data["data"] as List<dynamic>).forEach((dynamic item) {
           _autres[idReservation][Autre(
              id: item["autreIdAutre"]["idAutre"],
              motif: item["autreIdAutre"]["motif"],
          )] = 
            item["prixAutre"] + 0.0;
      });
      notifyListeners();
      _isLoading = 0;
      return true;
    } catch (error) {
      HandleDioError(error);
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
      HandleDioError(error);
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
      HandleDioError(error);
      return false;
    }
  }

  static Future<bool> removeData({@required idAutre,@required idReservation}) async {
    Dio _dio = await RestRequest().getDioInstance();
    try {
      await _dio.delete("/autres/$idAutre");
      _refresh(idReservation);
      return true;
    } catch (error) {
     HandleDioError(error);
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

class Autre {
  final String motif;
  final int id;
  const Autre(
      {@required this.motif, @required this.id});

  bool operator ==(autre) =>
      autre is Autre &&
      autre.id == id &&
      autre.motif == motif;
  int get hashCode => id.hashCode ^ motif.hashCode;
}
