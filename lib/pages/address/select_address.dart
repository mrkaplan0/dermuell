import 'package:dermuell/const/constants.dart';
import 'package:dermuell/widgets/bin_with_eyes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectAddress extends ConsumerStatefulWidget {
  const SelectAddress({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SelectAddressState();
}

class _SelectAddressState extends ConsumerState<SelectAddress> {
  PageController controller = PageController();
  int currentPage = 0;

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        children: [
          AddressSelectionTemplate(
            activePage: currentPage,
            title: "Wählen Sie Ihre Stadt.",
            imagePath: "assets/images/bg1.png",
          ),
          AddressSelectionTemplate(
            activePage: currentPage,
            title: "Wählen Sie Ihre Straße.",
            imagePath: "assets/images/bg2.png",
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

  AddressSelectionTemplate({
    super.key,
    required this.activePage,
    required this.imagePath,
    required this.title,
  });

  @override
  State<AddressSelectionTemplate> createState() =>
      _AddressSelectionTemplateState();
}

class _AddressSelectionTemplateState extends State<AddressSelectionTemplate> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();

  String? _selectedValue;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
          Positioned(
            top: 200,
            left: 20,
            right: 20,
            child: DropdownMenu<String>(
              controller: controller,
              requestFocusOnTap: true,
              width: size.width - 40,
              enableFilter: true,
              leadingIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 10,
                  height: 10,
                ),
              ),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 'Nürnberg', label: 'Nürnberg'),
                DropdownMenuEntry(value: 'Coesfeld', label: 'Coesfeld'),
                DropdownMenuEntry(value: 'Aachen', label: 'Aachen'),
              ],
              onSelected: (value) {
                print("Seçilen: $value");
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: size.width * 0.5 - 25,
            child: PageIndicator(activePage: widget.activePage),
          ),
          Positioned(
            top: 270,
            left: 20,
            right: 20,
            child: PrimaryButton(
              text: "Weiter",
              onPressed: () {
                // Navigate to next page or perform action
              },
            ),
          ),
          Positioned(bottom: 70, right: 20, child: BinWithEyes(size: 150)),
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
