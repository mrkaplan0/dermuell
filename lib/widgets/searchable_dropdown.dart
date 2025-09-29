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
  String currentQuery = '';

  @override
  void initState() {
    super.initState();
    _updateFilteredItems();

    // Controller'a listener ekleyerek arama sorgusunu takip et
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text;
    if (query != currentQuery) {
      setState(() {
        currentQuery = query;
        currentPage = 0; // Arama yapıldığında sayfayı sıfırla
        _updateFilteredItems(query);
      });
    }
  }

  void _updateFilteredItems([String? query]) {
    final searchQuery = query ?? currentQuery;

    // Önce filtreleme yap
    final filtered = widget.items
        .where(
          (item) => widget
              .labelBuilder(item)
              .toLowerCase()
              .contains(searchQuery.toLowerCase()),
        )
        .toList();

    // Sonra pagination uygula
    final startIndex = currentPage * itemsPerPage;
    final endIndex = ((currentPage + 1) * itemsPerPage).clamp(
      0,
      filtered.length,
    );

    setState(() {
      filteredItems = filtered.sublist(
        startIndex.clamp(0, filtered.length),
        endIndex,
      );
    });
  }

  void _loadMore() {
    final searchQuery = currentQuery;
    final totalFiltered = widget.items
        .where(
          (item) => widget
              .labelBuilder(item)
              .toLowerCase()
              .contains(searchQuery.toLowerCase()),
        )
        .length;

    if ((currentPage + 1) * itemsPerPage < totalFiltered) {
      setState(() {
        currentPage++;
        _updateFilteredItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownMenu<String>(
          controller: widget.controller,
          focusNode: widget.focusNode,
          requestFocusOnTap: true,
          width: MediaQuery.of(context).size.width - 40,
          enableFilter: true,
          hintText: widget.hintText,
          menuHeight: 200,
          inputDecorationTheme: XConst.dropdownMenuDecoration,
          leadingIcon: XConst.leadingIcon,
          dropdownMenuEntries: [
            ...filteredItems.map((item) {
              return DropdownMenuEntry<String>(
                value: widget.valueBuilder(item),
                label: widget.labelBuilder(item),
              );
            }),
            // Daha fazla yükleme seçeneği
            if (_hasMoreItems())
              DropdownMenuEntry<String>(
                value: 'load_more',
                label: 'Daha fazla yükle...',
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(Colors.grey),
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'load_more') {
              _loadMore();
              return;
            }

            if (value != null) {
              final selectedItem = widget.items.firstWhere(
                (item) => widget.valueBuilder(item) == value,
              );
              widget.onSelected(selectedItem);
            }
          },
        ),
      ],
    );
  }

  bool _hasMoreItems() {
    final searchQuery = currentQuery;
    final totalFiltered = widget.items
        .where(
          (item) => widget
              .labelBuilder(item)
              .toLowerCase()
              .contains(searchQuery.toLowerCase()),
        )
        .length;

    return (currentPage + 1) * itemsPerPage < totalFiltered;
  }
}
