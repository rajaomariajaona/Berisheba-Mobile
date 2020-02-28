import 'package:berisheba/states/connected_state.dart';
import 'package:berisheba/states/global_state.dart';
import 'package:dio/dio.dart';

class HandleDioError {
  HandleDioError(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.RECEIVE_TIMEOUT:
        case DioErrorType.CONNECT_TIMEOUT:
          ConnectedState().setIsConnected(false);
          break;
        case DioErrorType.DEFAULT:
          if (error.toString().contains("SocketException")) {
            ConnectedState().setIsConnected(false);
          } else {
            print(error.toString());
          }
          break;
        default:
          print(error.toString());
      }
    }else{
      print(error);
    }
  }
}
