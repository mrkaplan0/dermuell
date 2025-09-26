import 'package:dermuell/const/constants.dart';
import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) labelBuilder;
  final String Function(T) valueBuilder;
  final void Function(T?) onSelected;
  final String hintText;
  final TextEditingController controller;
  final FocusNode focusNode;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.valueBuilder,
    required this.onSelected,
    required this.hintText,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  List<T> filteredItems = [];
  final int itemsPerPage = 50;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _updateFilteredItems();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _updateFilteredItems(widget.controller.text);
  }

  @override
  void didUpdateWidget(SearchableDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _updateFilteredItems(widget.controller.text);
    }
  }

  void _updateFilteredItems([String query = '']) {
    setState(() {
      final filtered = widget.items
          .where(
            (item) => widget
                .labelBuilder(item)
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();

      final endIndex = ((currentPage + 1) * itemsPerPage).clamp(
        0,
        filtered.length,
      );
      filteredItems = filtered.sublist(0, endIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      controller: widget.controller,
      focusNode: widget.focusNode,
      requestFocusOnTap: true,
      width: MediaQuery.of(context).size.width - 40,
      enableFilter: true,
      hintText: widget.hintText,
      menuHeight: 200,
      inputDecorationTheme: XConst.dropdownMenuDecoration,
      leadingIcon: XConst.leadingIcon,
      dropdownMenuEntries: filteredItems.map((item) {
        return DropdownMenuEntry<String>(
          value: widget.valueBuilder(item),
          label: widget.labelBuilder(item),
        );
      }).toList(),
      onSelected: (value) {
        if (value != null) {
          final selectedItem = widget.items.firstWhere(
            (item) => widget.valueBuilder(item) == value,
          );
          widget.onSelected(selectedItem);
        }
      },
    );
  }
}
