import 'package:dermuell/const/constants.dart';
import 'package:dermuell/provider/address_provider.dart';
import 'package:dermuell/widgets/bin_with_eyes.dart';
import 'package:dermuell/widgets/my_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            title: "Wählen Sie Ihre Stadt:",
            imagePath: "assets/images/bg1.png",
            focusNode: cityFocusNode,
            mainWidget: citiesList.when(
              data: (cities) {
                return Column(
                  spacing: 20,
                  children: [
                    DropdownMenu<String>(
                      controller: cityEditingController,
                      focusNode: cityFocusNode,
                      requestFocusOnTap: true,
                      width: size.width - 40,
                      menuHeight: 200,
                      enableFilter: true,
                      hintText: "Stadte",
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      leadingIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/images/logo.png",
                          width: 10,
                          height: 10,
                        ),
                      ),
                      dropdownMenuEntries: cities.map((city) {
                        return DropdownMenuEntry<String>(
                          value: city['id'].toString(),
                          label: city['name'],
                        );
                      }).toList(),
                      onSelected: (value) {
                        city = cities.firstWhere(
                          (city) => city['id'].toString() == value,
                        );
                        cityEditingController.text = cities.firstWhere(
                          (city) => city['id'].toString() == value,
                        )['name'];
                        cityFocusNode.unfocus();
                      },
                    ),

                    PrimaryButton(
                      text: "Weiter",
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
                      child: Text("Deine Stadt nicht gefunden?"),
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
            title: "Wählen Sie Ihre Straße.",
            imagePath: "assets/images/bg2.png",
            focusNode: streetFocusNode,
            focusNode2: hNumberFocusNode,
            mainWidget: Column(
              spacing: 20,
              children: [
                // DROPDOWN FOR STREETS
                DropdownMenu<String>(
                  controller: streetEditingController,
                  focusNode: streetFocusNode,

                  requestFocusOnTap: true,
                  width: size.width - 40,
                  enableFilter: true,
                  hintText: "Straße",
                  menuHeight: 200,
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  leadingIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 10,
                      height: 10,
                    ),
                  ),
                  dropdownMenuEntries: streets.map((street) {
                    return DropdownMenuEntry<String>(
                      value: street['id'].toString(),
                      label: street['name'],
                    );
                  }).toList(),
                  onSelected: (value) async {
                    streetID = value;
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
                  },
                ),
                //DROPDOWN FOR HOUSE NUMBERS
                DropdownMenu<String>(
                  controller: hNumberEditingController,
                  focusNode: hNumberFocusNode,
                  requestFocusOnTap: true,
                  width: size.width - 40,
                  enableFilter: true,
                  hintText: "Hausnummer",
                  menuHeight: 200,
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  leadingIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 10,
                      height: 10,
                    ),
                  ),
                  dropdownMenuEntries: houseNr.map((hNumber) {
                    return DropdownMenuEntry<String>(
                      value: hNumber['id'].toString(),
                      label: hNumber['nr'].toString(),
                    );
                  }).toList(),
                  onSelected: (value) async {
                    houseNumberID = value;
                    hNumberEditingController.text = houseNr
                        .firstWhere(
                          (hNumber) => hNumber['id'].toString() == value,
                        )['nr']
                        .toString();
                    hNumberFocusNode.unfocus();
                  },
                ),

                PrimaryButton(
                  text: "Weiter",
                  onPressed: () {
                    isLoading = true;
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Ist Ihre Adresse richtig?"),
                        content: Text(
                          "${streetEditingController.text} ${hNumberEditingController.text}, ${cityEditingController.text}",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("Abbrechen"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                    isLoading = false;
                    // Navigator.of(context).pop();
                    controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddressSelectionTemplate extends StatefulWidget {
  final int activePage;
  final String imagePath;
  final String title;
  final Widget mainWidget;
  final FocusNode focusNode;
  final FocusNode? focusNode2;

  const AddressSelectionTemplate({
    super.key,
    required this.activePage,
    required this.imagePath,
    required this.title,
    required this.mainWidget,
    required this.focusNode,
    this.focusNode2,
  });

  @override
  State<AddressSelectionTemplate> createState() =>
      _AddressSelectionTemplateState();
}

class _AddressSelectionTemplateState extends State<AddressSelectionTemplate> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 150,
            left: 20,
            right: 20,
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26.0,
                height: 1.5,
                color: Color.fromRGBO(33, 45, 82, 1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Positioned(top: 200, left: 20, right: 20, child: widget.mainWidget),

          Positioned(
            bottom: 20,
            left: size.width * 0.5 - 25,
            child: PageIndicator(activePage: widget.activePage),
          ),
          Positioned(
            bottom:
                widget.focusNode.hasFocus ||
                    (widget.focusNode2 != null && widget.focusNode2!.hasFocus)
                ? -200
                : 70,
            right: 20,
            child: BinWithEyes(size: 150),
          ),
        ],
      ),
    );
  }
}

class PageIndicator extends StatelessWidget {
  final int activePage;
  const PageIndicator({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        2,
        (index) => Container(
          width: index == activePage ? 22.0 : 10.0,
          height: 10.0,
          margin: EdgeInsets.only(right: 10.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              index == activePage ? 10.0 : 50.0,
            ),
            color: index == activePage
                ? XConst.primaryColor
                : XConst.primaryColor.withAlpha(50),
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const PrimaryButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: XConst.sixthColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(169, 176, 185, 0.42),
              spreadRadius: 0,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
