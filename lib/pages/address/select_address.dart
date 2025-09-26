// ignore_for_file: use_build_context_synchronously

import 'package:dermuell/const/constants.dart';
import 'package:dermuell/provider/address_provider.dart';
import 'package:dermuell/widgets/address_selection_template.dart';
import 'package:dermuell/widgets/my_progress_indicator.dart';
import 'package:dermuell/widgets/primary_button.dart';
import 'package:dermuell/widgets/searchable_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

class SelectAddress extends ConsumerStatefulWidget {
  const SelectAddress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectAddressState();
}

class _SelectAddressState extends ConsumerState<SelectAddress> {
  PageController controller = PageController();
  TextEditingController cityEditingController = TextEditingController();
  TextEditingController streetEditingController = TextEditingController();
  TextEditingController hNumberEditingController = TextEditingController();
  FocusNode cityFocusNode = FocusNode();
  FocusNode streetFocusNode = FocusNode();
  FocusNode hNumberFocusNode = FocusNode();
  int currentPage = 0;
  String? streetID, houseNumberID;
  Map<String, dynamic>? city;
  List<Map<String, dynamic>> streets = [];
  List<Map<String, dynamic>> houseNr = [];
  List<Map<String, dynamic>> collectionTypes = [];
  bool isLoading = false;

  @override
  void initState() {
    controller.addListener(() {
      setState(() {
        currentPage = controller.page?.round() ?? 0;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    cityEditingController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var citiesList = ref.watch(citiesProvider);

    return Scaffold(
      body: PageView(
        controller: controller,
        children: [
          // First Page
          AddressSelectionTemplate(
            activePage: currentPage,
            title: "Wählen Sie Ihre Stadt:".tr(),
            imagePath: "assets/images/bg1.png",
            focusNode: cityFocusNode,
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
                          cityEditingController.text = selectedCity['name'];
                          cityFocusNode.unfocus();
                        }
                      },
                      hintText: "Städte".tr(),
                      controller: cityEditingController,
                      focusNode: cityFocusNode,
                    ),

                    PrimaryButton(
                      text: "Weiter".tr(),
                      onPressed: city != null
                          ? () async {
                              isLoading = true;
                              showDialog(
                                context: context,
                                builder: (context) => MyProgressIndicator(),
                              );
                              streets = await ref
                                  .watch(addressServiceProvider)
                                  .fetchStreets(city!)
                                  .whenComplete(() => setState(() {}));
                              isLoading = false;
                              Navigator.of(context).pop();
                              controller.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          : () {},
                    ),

                    TextButton(
                      onPressed: () {},
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
            focusNode: streetFocusNode,
            focusNode2: hNumberFocusNode,
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
                      streetEditingController.text = selectedStreet['name']
                          .toString();
                      houseNr.clear();
                      isLoading = true;
                      showDialog(
                        context: context,
                        builder: (context) => MyProgressIndicator(),
                      );
                      houseNr = await ref
                          .watch(addressServiceProvider)
                          .fetchHouseNumbers(city!, streetID!)
                          .whenComplete(() => setState(() {}));
                      isLoading = false;
                      Navigator.of(context).pop();
                      streetFocusNode.unfocus();
                      hNumberFocusNode.requestFocus();
                    }
                  },
                  hintText: "Straße".tr(),
                  controller: streetEditingController,
                  focusNode: streetFocusNode,
                ),

                //DROPDOWN FOR HOUSE NUMBERS
                SearchableDropdown<Map<String, dynamic>>(
                  items: houseNr,
                  labelBuilder: (hNumber) => hNumber['nr'].toString(),
                  valueBuilder: (hNumber) => hNumber['id'].toString(),
                  onSelected: (selectedHouseNumber) {
                    if (selectedHouseNumber != null) {
                      houseNumberID = selectedHouseNumber['id'].toString();
                      hNumberEditingController.text = selectedHouseNumber['nr']
                          .toString();
                      hNumberFocusNode.unfocus();
                    }
                  },
                  hintText: "Hausnummer".tr(),
                  controller: hNumberEditingController,
                  focusNode: hNumberFocusNode,
                ),

                PrimaryButton(
                  text: "Weiter".tr(),
                  onPressed: () {
                    isLoading = true;
                    confirmAddress(context);
                    isLoading = false;
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
            focusNode: cityFocusNode,
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
                          isLoading = true;
                          showDialog(
                            context: context,
                            builder: (context) => MyProgressIndicator(),
                          );
                          var list = collectionTypes
                              .where((element) => element["isChecked"] == true)
                              .toList();
                          print(list);
                          Map<String, dynamic> selectedAddress = {
                            "city": city,
                            "streetID": streetID,
                            "houseNumberID": houseNumberID,
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

                          isLoading = false;
                          Navigator.of(context).pop();
                          Navigator.of(context).pushReplacementNamed('/home');
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

  Future<dynamic> confirmAddress(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Ist Ihre Adresse richtig?".tr()),
        content: Text(
          "${streetEditingController.text} ${hNumberEditingController.text}, ${cityEditingController.text}",
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

              collectionTypes = await ref
                  .read(addressServiceProvider)
                  .fetchCollectionData(city!, houseNumberID!);
              // setState(() {});
              controller.nextPage(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
}
