// ignore_for_file: use_build_context_synchronously

import 'package:dermuell/const/constants.dart';
import 'package:dermuell/widgets/bin_with_eyes.dart';
import 'package:flutter/material.dart';

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
        3,
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
