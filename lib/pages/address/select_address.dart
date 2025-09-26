// ignore_for_file: use_build_context_synchronously

import 'package:dermuell/const/constants.dart';
import 'package:dermuell/model/address_selection_state.dart';
import 'package:dermuell/provider/address_provider.dart';
import 'package:dermuell/widgets/address_selection_template.dart';
import 'package:dermuell/widgets/my_progress_indicator.dart';
import 'package:dermuell/widgets/primary_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dermuell/widgets/searchable_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SelectAddress extends ConsumerStatefulWidget {
  const SelectAddress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectAddressState();
}

class _SelectAddressState extends ConsumerState<SelectAddress> {
  final PageController _controller = PageController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _hNumberController = TextEditingController();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _hNumberFocusNode = FocusNode();

  int _currentPage = 0;
  AddressSelectionState _state = const AddressSelectionState();
  bool _pageControllerReady =
      false; // PageController hazır mı kontrol etmek için

  @override
  void initState() {
    super.initState();
    // PageView oluşturulduktan sonra listener eklemek için
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.addListener(_onPageChanged);
        _pageControllerReady = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageChanged); // Listener'ı temizle
    _cityController.dispose();
    _streetController.dispose();
    _hNumberController.dispose();
    _cityFocusNode.dispose();
    _streetFocusNode.dispose();
    _hNumberFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    // PageController hazır olmadıysa işlem yapma
    if (!_pageControllerReady || !_controller.hasClients) return;

    final currentPage = _controller.page?.round() ?? 0;
    if (_currentPage != currentPage) {
      setState(() {
        _currentPage = currentPage;
      });
    }
  }

  void _updateState(AddressSelectionState newState) {
    setState(() {
      _state = newState;
    });
  }

  Future<void> _handleCitySelection(Map<String, dynamic> city) async {
    try {
      _updateState(_state.copyWith(isLoading: true, error: null));

      final streets = await ref.read(addressServiceProvider).fetchStreets(city);

      _updateState(
        _state.copyWith(city: city, streets: streets, isLoading: false),
      );

      _cityController.text = city['name'];
      _cityFocusNode.unfocus();
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          error: 'Fehler beim Laden der Straßen: $e',
        ),
      );
      _showErrorDialog('Fehler beim Laden der Straßen: $e');
    }
  }

  Future<void> _handleStreetSelection(String streetID) async {
    if (_state.city == null) return;

    try {
      _updateState(_state.copyWith(isLoading: true, error: null));

      final houseNumbers = await ref
          .read(addressServiceProvider)
          .fetchHouseNumbers(_state.city!, streetID);

      _updateState(
        _state.copyWith(
          streetID: streetID,
          houseNumbers: houseNumbers,
          isLoading: false,
        ),
      );

      final selectedStreet = _state.streets.firstWhere(
        (street) => street['id'].toString() == streetID,
      );
      _streetController.text = selectedStreet['name'];
      _streetFocusNode.unfocus();
      _hNumberFocusNode.requestFocus();
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          error: 'Fehler beim Laden der Hausnummern: $e',
        ),
      );
      _showErrorDialog('Fehler beim Laden der Hausnummern: $e');
    }
  }

  void _handleHouseNumberSelection(String houseNumberID) {
    _updateState(_state.copyWith(houseNumberID: houseNumberID));

    final selectedHouseNumber = _state.houseNumbers.firstWhere(
      (hNumber) => hNumber['id'].toString() == houseNumberID,
    );
    _hNumberController.text = selectedHouseNumber['nr'].toString();
    _hNumberFocusNode.unfocus();
  }

  Future<void> _navigateToNextPage() async {
    if (_state.isLoading || !_pageControllerReady || !_controller.hasClients) {
      return;
    }

    try {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      debugPrint('Navigation error: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fehler'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final citiesList = ref.watch(citiesProvider);

    if (_state.isLoading) {
      return const Scaffold(body: Center(child: MyProgressIndicator()));
    }

    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          _buildCitySelectionPage(citiesList),
          _buildStreetSelectionPage(),
          _buildCollectionTypeSelectionPage(),
        ],
      ),
    );
  }

  Widget _buildCitySelectionPage(
    AsyncValue<List<Map<String, dynamic>>> citiesList,
  ) {
    return AddressSelectionTemplate(
      activePage: _currentPage,
      title: "Wählen Sie Ihre Stadt:",
      imagePath: "assets/images/bg1.png",
      focusNode: _cityFocusNode,
      mainWidget: citiesList.when(
        data: (cities) => Column(
          spacing: 20,
          children: [
            SearchableDropdown<Map<String, dynamic>>(
              items: cities,
              labelBuilder: (city) => city['name'],
              valueBuilder: (city) => city['id'].toString(),
              onSelected: (city) =>
                  city != null ? _handleCitySelection(city) : null,
              hintText: "Stadt",
              controller: _cityController,
              focusNode: _cityFocusNode,
            ),
            PrimaryButton(
              text: "Weiter",
              onPressed: _state.city != null ? _navigateToNextPage : () {},
            ),
            TextButton(
              onPressed: () => _showCityNotFoundDialog(),
              child: const Text("Deine Stadt nicht gefunden?"),
            ),
          ],
        ),
        error: (err, stack) => Text('Error: $err'),
        loading: () => const MyProgressIndicator(),
      ),
    );
  }

  Widget _buildStreetSelectionPage() {
    return AddressSelectionTemplate(
      activePage: _currentPage,
      title: "Wählen Sie Ihre Straße.",
      imagePath: "assets/images/bg2.png",
      focusNode: _streetFocusNode,
      focusNode2: _hNumberFocusNode,
      mainWidget: Column(
        spacing: 20,
        children: [
          SearchableDropdown<Map<String, dynamic>>(
            items: _state.streets,
            labelBuilder: (street) => street['name'],
            valueBuilder: (street) => street['id'].toString(),
            onSelected: (street) => street != null
                ? _handleStreetSelection(street['id'].toString())
                : null,
            hintText: "Straße",
            controller: _streetController,
            focusNode: _streetFocusNode,
          ),
          SearchableDropdown<Map<String, dynamic>>(
            items: _state.houseNumbers,
            labelBuilder: (hNumber) => hNumber['nr'].toString(),
            valueBuilder: (hNumber) => hNumber['id'].toString(),
            onSelected: (hNumber) => hNumber != null
                ? _handleHouseNumberSelection(hNumber['id'].toString())
                : null,
            hintText: "Hausnummer",
            controller: _hNumberController,
            focusNode: _hNumberFocusNode,
          ),
          PrimaryButton(
            text: "Weiter",
            onPressed: _state.houseNumberID != null
                ? () => _confirmAddress()
                : () {},
          ),
        ],
      ),
    );
  }

  // THIRD PAGE
  AddressSelectionTemplate _buildCollectionTypeSelectionPage() {
    return AddressSelectionTemplate(
      activePage: _currentPage,
      title: "Wählen Sie Ihre Müllarten:",
      imagePath: "assets/images/bg3.png",
      focusNode: _cityFocusNode,
      mainWidget: Column(
        spacing: 20,
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _state.collectionTypes.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  value: _state.collectionTypes[index]["isChecked"],
                  onChanged: (value) {
                    setState(() {
                      _state.collectionTypes[index]["isChecked"] = value!;
                    });
                  },
                  title: Text(
                    _state.collectionTypes[index]["name"],
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              },
            ),
          ),
          PrimaryButton(
            text: "Bestätigen",
            onPressed: _state.city != null
                ? () async {
                    try {
                      _updateState(_state.copyWith(isLoading: true));

                      final list = _state.collectionTypes
                          .where((element) => element["isChecked"] == true)
                          .toList();
                      print(list);
                      Map<String, dynamic> selectedAddress = {
                        "city": _state.city,
                        "streetID": _state.streetID,
                        "houseNumberID": _state.houseNumberID,
                        "collectionTypes": list,
                      };
                      var myBox = Hive.box('dataBox');
                      await myBox.put('address', selectedAddress);
                      var dates = ref
                          .read(collectionDatesProvider(selectedAddress))
                          .value;

                      if (dates != null) {
                        await myBox.put('collectionDates', dates);
                      }

                      _updateState(_state.copyWith(isLoading: false));
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/home');
                    } catch (e) {
                      _updateState(_state.copyWith(isLoading: false));
                      _showErrorDialog(
                        'Fehler beim Bestätigen der Adresse: $e',
                      );
                    }
                  }
                : () {},
          ),
        ],
      ),
    );
  }

  void _showCityNotFoundDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Stadt nicht gefunden"),
        content: const Text("Bitte kontaktieren Sie den Support."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAddress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Ist Ihre Adresse richtig?"),
        content: Text(
          "${_streetController.text} ${_hNumberController.text}, ${_cityController.text}",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Abbrechen"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        _updateState(_state.copyWith(isLoading: true));

        final collectionTypes = await ref
            .read(addressServiceProvider)
            .fetchCollectionData(_state.city!, _state.houseNumberID!);

        _updateState(
          _state.copyWith(collectionTypes: collectionTypes, isLoading: false),
        );

        await _navigateToNextPage();
      } catch (e) {
        _updateState(_state.copyWith(isLoading: false));
        _showErrorDialog('Fehler beim Laden der Müllarten: $e');
      }
    }
  }
}
