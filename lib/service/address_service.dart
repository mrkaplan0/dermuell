import 'package:dermuell/service/api_service.dart';
import 'package:dio/dio.dart';

class AddressService {
  final ApiService _api = ApiService();

  Future<List<Map<String, dynamic>>> fetchCities() async {
    Set<Map<String, dynamic>> cities = {};
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
      cities.addAll(
        (response.data as List).map((e) {
          return {"id": e['id'], "name": e['name'], "region": element};
        }).toList(),
      );
    }
    // Return a list of cities from API
    return cities.toList();
  }

  Future<List<Map<String, dynamic>>> fetchStreets(
    Map<String, dynamic> city,
  ) async {
    var response = await _api.dio.get(
      "https://${city['region']}-abfallapp.regioit.de/abfall-app-${city['region']}/rest/orte/${city["id"]}/strassen",
      options: Options(headers: {"content-type": "application/json"}),
    );

    var streets = (response.data as List).map((e) {
      return {"id": e['id'], "name": e['name']};
    }).toList();
    // Return a list of streets based on the cityId from API
    return streets;
  }

  Future<List<Map<String, dynamic>>> fetchHouseNumbers(
    Map<String, dynamic> city,
    String streetId,
  ) async {
    // Parse streetId to int and handle potential null value
    int? parsedStreetId = int.tryParse(streetId);
    if (parsedStreetId == null) {
      print("Invalid street ID: $streetId");
    }

    var response = await _api.dio.get(
      "https://${city['region']}-abfallapp.regioit.de/abfall-app-${city['region']}/rest/strassen/$parsedStreetId",
      options: Options(headers: {"content-type": "application/json"}),
    );
    print(
      "https://${city['region']}-abfallapp.regioit.de/abfall-app-${city['region']}/rest/strassen/$parsedStreetId",
    );
    print("Hey" + response.data.toString());

    List<Map<String, dynamic>> houseNumbers =
        (response.data['hausNrList'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

    // Return a list of house numbers based on the streetId from API
    return houseNumbers;
  }
}
