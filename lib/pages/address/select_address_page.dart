// ignore_for_file: use_build_context_synchronously
import 'dart:io';

import 'package:dermuell/provider/address_provider.dart';
import 'package:dermuell/service/file_picker_service.dart';
import 'package:dermuell/widgets/address_selection_template.dart';
import 'package:dermuell/widgets/my_progress_indicator.dart';
import 'package:dermuell/widgets/primary_button.dart';
import 'package:dermuell/widgets/searchable_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SelectAddressPage extends ConsumerStatefulWidget {
  const SelectAddressPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectAddressState();
}

class _SelectAddressState extends ConsumerState<SelectAddressPage> {
  final PageController _controller = PageController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _hNumberController = TextEditingController();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _streetFocusNode = FocusNode();
  final FocusNode _hNumberFocusNode = FocusNode();
  int currentPage = 0;
  String? streetID, houseNumberID;
  Map<String, dynamic>? city;
  List<Map<String, dynamic>> streets = [];
  List<Map<String, dynamic>> houseNr = [];
  List<Map<String, dynamic>> collectionTypes = [];
  bool isLoading = false;

  @override
  void initState() {
    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page?.round() ?? 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _hNumberController.dispose();
    _cityFocusNode.dispose();
    _streetFocusNode.dispose();
    _hNumberFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var citiesList = ref.watch(citiesProvider);

    return Scaffold(
      body: PageView(
        controller: _controller,
        children: [
          // First Page
          AddressSelectionTemplate(
            activePage: currentPage,
            title: "Wählen Sie Ihre Stadt:".tr(),
            imagePath: "assets/images/bg1.png",
            focusNode: _cityFocusNode,
            mainWidget: citiesList.when(
              data: (cities) {
                return Column(
                  spacing: 20,
                  children: [
                    SearchableDropdown<Map<String, dynamic>>(
                      items: cities,
                      labelBuilder: (city) => city['name'],
                      valueBuilder: (city) => city['id'].toString(),
                      onSelected: (selectedCity) {
                        if (selectedCity != null) {
                          city = selectedCity;
                          _cityController.text = selectedCity['name'];
                          _cityFocusNode.unfocus();
                        }
                      },
                      hintText: "Städte".tr(),
                      controller: _cityController,
                      focusNode: _cityFocusNode,
                    ),

                    PrimaryButton(
                      text: "Weiter".tr(),
                      onPressed: () async {
                        try {
                          city != null
                              ? await confirmCityAndFetchStreets(context)
                              : _showErrorDialog(
                                  "Bitte wählen Sie eine Stadt.".tr(),
                                );
                        } on Exception catch (e) {
                          _showErrorDialog(e.toString());
                        }
                      },
                    ),

                    TextButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Stadt nicht gefunden?".tr()),
                            content: Text(
                              "Importieren Sie Ihre Termin im ics format.".tr(),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("Abbrechen".tr()),
                              ),
                              TextButton(
                                onPressed: () async {
                                  bool result =
                                      await FilePickerService.pickFile();
                                  if (result) {
                                    Navigator.of(
                                      context,
                                    ).pushNamedAndRemoveUntil(
                                      '/home',
                                      (route) => false,
                                    );
                                  } else {
                                    Navigator.of(context).pop();
                                    _showErrorDialog(
                                      "Fehler beim Importieren der Datei.".tr(),
                                    );
                                  }
                                },
                                child: Text("Importieren".tr()),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text("Deine Stadt nicht gefunden?".tr()),
                    ),
                  ],
                );
              },
              error: (err, stack) => Text('Error: $err'),
              loading: () => MyProgressIndicator(),
            ),
          ),

          // SECOND PAGE
          AddressSelectionTemplate(
            activePage: currentPage,
            title: "Wählen Sie Ihre Straße.".tr(),
            imagePath: "assets/images/bg2.png",
            focusNode: _streetFocusNode,
            focusNode2: _hNumberFocusNode,
            mainWidget: Column(
              spacing: 20,
              children: [
                // DROPDOWN FOR STREETS
                SearchableDropdown<Map<String, dynamic>>(
                  items: streets,
                  labelBuilder: (street) => street['name'],
                  valueBuilder: (street) => street['id'].toString(),
                  onSelected: (selectedStreet) async {
                    if (selectedStreet != null) {
                      streetID = selectedStreet['id'].toString();
                      _streetController.text = selectedStreet['name']
                          .toString();
                      houseNr.clear();
                      isLoading = true;
                      showDialog(
                        context: context,
                        builder: (context) => MyProgressIndicator(),
                      );
                      city?['streetID'] = streetID;
                      try {
                        houseNr = await ref
                            .watch(addressServiceProvider)
                            .fetchHouseNumbers(city!, streetID!)
                            .whenComplete(() => setState(() {}));
                      } catch (e) {
                        _showErrorDialog(e.toString());
                      } finally {
                        Navigator.of(context).pop();
                      }
                      print(houseNr);
                      isLoading = false;

                      _streetFocusNode.unfocus();
                      _hNumberFocusNode.requestFocus();
                    }
                  },
                  hintText: "Straße".tr(),
                  controller: _streetController,
                  focusNode: _streetFocusNode,
                ),

                //DROPDOWN FOR HOUSE NUMBERS
                if (houseNr.isNotEmpty)
                  ...[
                    SearchableDropdown<Map<String, dynamic>>(
                      items: houseNr,
                      labelBuilder: (hNumber) => hNumber['nr'].toString(),
                      valueBuilder: (hNumber) => hNumber['id'].toString(),
                      onSelected: (selectedHouseNumber) {
                        if (selectedHouseNumber != null) {
                          houseNumberID = selectedHouseNumber['id'].toString();
                          _hNumberController.text = selectedHouseNumber['nr']
                              .toString();
                        }
                        _hNumberFocusNode.unfocus();
                      },
                      hintText: "Hausnummer".tr(),
                      controller: _hNumberController,
                      focusNode: _hNumberFocusNode,
                    ),
                  ].animate().fadeIn(duration: 700.ms),
                PrimaryButton(
                  text: "Weiter".tr(),
                  onPressed: () {
                    if (streetID == null) {
                      _showErrorDialog("Bitte wählen Sie Straße".tr());
                      return;
                    }
                    confirmAddress(context);
                  },
                ),
              ],
            ),
          ),

          // THIRD PAGE
          AddressSelectionTemplate(
            activePage: currentPage,
            title: "Wählen Sie Ihre Müllarten:".tr(),
            imagePath: "assets/images/bg3.png",
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
                    itemCount: collectionTypes.length,
                    itemBuilder: (context, index) {
                      return CheckboxListTile(
                        value: collectionTypes[index]["isChecked"],
                        onChanged: (value) {
                          setState(() {
                            collectionTypes[index]["isChecked"] = value!;
                          });
                        },
                        title: Text(
                          collectionTypes[index]["name"],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      );
                    },
                  ),
                ),
                PrimaryButton(
                  text: "Bestätigen".tr(),
                  onPressed: city != null
                      ? () async {
                          showDialog(
                            context: context,
                            builder: (context) => MyProgressIndicator(),
                          );

                          try {
                            var list = collectionTypes
                                .where(
                                  (element) => element["isChecked"] == true,
                                )
                                .toList();

                            Map<String, dynamic> selectedAddress = {
                              "city": city,
                              "streetID": streetID,
                              "houseNumberID": houseNumberID,
                              "collectionTypes": list,
                            };
                            var myBox = Hive.box('dataBox');
                            await myBox.put('address', selectedAddress);
                            if (list.isEmpty) {
                              Navigator.of(context).pop();
                              _showErrorDialog(
                                "Bitte wählen Sie mindestens eine Müllart."
                                    .tr(),
                              );
                              return;
                            }

                            var events = ref
                                .read(collectionEventsProvider(selectedAddress))
                                .value;

                            if (events != null) {
                              await myBox.put('collectionEvents', events);
                            }

                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/home',
                              (route) => false,
                            );
                          } on Exception catch (e) {
                            Navigator.of(context).pop();
                            _showErrorDialog(e.toString());
                          }
                        }
                      : () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> confirmCityAndFetchStreets(BuildContext context) async {
    showDialog(context: context, builder: (context) => MyProgressIndicator());
    try {
      streets = await ref
          .watch(addressServiceProvider)
          .fetchStreets(city!)
          .whenComplete(() => setState(() {}));

      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } on Exception catch (e) {
      _showErrorDialog(e.toString());
      Navigator.of(context).pop();
    } finally {
      Navigator.of(context).pop();
    }
  }

  Future<dynamic> confirmAddress(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ist Ihre Adresse richtig?".tr()),
        content: Text(
          "${_streetController.text} ${_hNumberController.text}, ${_cityController.text}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Abbrechen".tr()),
          ),

          //Confirmation of the address
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              await fetchCollectionTypes();
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> fetchCollectionTypes() async {
    try {
      collectionTypes = await ref
          .read(addressServiceProvider)
          .fetchCollectionTypesForStreet(city!, houseNumberID);

      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } on Exception catch (e) {
      _showErrorDialog(e.toString());
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
}
