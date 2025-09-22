import 'package:dermuell/const/cities.dart';
import 'package:dermuell/service/api_service.dart';
import 'package:dio/dio.dart';

class AddressService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> fetchCities() async {
    List<Map<String, dynamic>> cities = [];
    var myList = [
      "aachen",
      "zew2",
      "aw-bgl2",
      "bav",
      "din",
      "dorsten",
      "gt2",
      "hlv",
      "coe",
      "krhs",
      "pi",
      "krwaf",
      "lindlar",
      "stl",
      "nds",
      "nuernberg",
      "roe",
      "solingen",
      "wml2",
    ];

    for (var element in myList) {
      var response = await _api.dio.get(
        "https://$element-abfallapp.regioit.de/abfall-app-$element/rest/orte",
        options: Options(headers: {"content-type": "application/json"}),
      );
      print(response.data);
      cities.addAll(
        (response.data as List).map((e) => e as Map<String, dynamic>).toList(),
      );
    }
    print(cities);
    // Return a list of cities (this would normally come from an API)
    return cities;
  }
}
