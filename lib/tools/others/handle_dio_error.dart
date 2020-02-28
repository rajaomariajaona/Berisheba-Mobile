import 'package:berisheba/states/global_state.dart';
import 'package:dio/dio.dart';

class HandleDioError {
  HandleDioError(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.RECEIVE_TIMEOUT:
        case DioErrorType.CONNECT_TIMEOUT:
          GlobalState().isConnected = false;
          break;
        case DioErrorType.DEFAULT:
          if (error.message.contains("SocketException")) {
            GlobalState().isConnected = false;
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
