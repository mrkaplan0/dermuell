import 'package:dermuell/model/event.dart';
import 'package:dermuell/service/address_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addressServiceProvider = Provider((ref) => AddressService());

final citiesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final addressService = ref.read(addressServiceProvider);
  return await addressService.fetchCities();
});

final collectionDatesProvider =
    FutureProvider.family<List<Event>, Map<String, dynamic>>((
      ref,
      address,
    ) async {
      final addressService = ref.read(addressServiceProvider);
      return await addressService.fetchAllCollectionDates(
        address['city'],
        address['houseNumberID'],
        address['collectionTypes'],
      );
    });
