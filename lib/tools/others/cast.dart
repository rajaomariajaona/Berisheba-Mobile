class Cast {
  static Map<int, dynamic> stringToIntMap(Map<String, dynamic> data, CastCallback castCallback){
    return data.map<int, dynamic>(
          (key, value) => MapEntry<int, dynamic>(int.parse(key), castCallback(value)));
  }
}
typedef CastCallback = dynamic Function(dynamic value);