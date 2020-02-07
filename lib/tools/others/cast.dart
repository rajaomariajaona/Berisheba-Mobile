class Cast {
  static Map<int, dynamic> stringToIntMap(Map<String, dynamic> data, CastCallback){
    return data.map<int, dynamic>(
          (key, value) => MapEntry<int, dynamic>(int.parse(key), CastCallback(value)));
  }
}
typedef CastCallback = dynamic Function(dynamic value);