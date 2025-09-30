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

    // Add listener to controller to track search query
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text;

    // Ignore "Load more..." text
    if (query == 'Mehr laden...') {
      return;
    }

    if (query != currentQuery) {
      setState(() {
        currentQuery = query;
        currentPage = 0; // Reset page only when actual search is performed
        _updateFilteredItems(query);
      });
    }
  }

  void _updateFilteredItems([String? query]) {
    final searchQuery = query ?? currentQuery;

    // First, filter the items
    final filtered = widget.items
        .where(
          (item) => widget
              .labelBuilder(item)
              .toLowerCase()
              .contains(searchQuery.toLowerCase()),
        )
        .toList();

    // Add alphabetical sorting
    filtered.sort(
      (a, b) => widget
          .labelBuilder(a)
          .toLowerCase()
          .compareTo(widget.labelBuilder(b).toLowerCase()),
    );

    // Then apply pagination
    final startIndex = currentPage * itemsPerPage;
    final endIndex = ((currentPage + 1) * itemsPerPage).clamp(
      0,
      filtered.length,
    );

    setState(() {
      if (currentPage == 0) {
        // First page or new search - completely replace the list
        filteredItems = filtered.sublist(
          startIndex.clamp(0, filtered.length),
          endIndex,
        );
      } else {
        // Load more - add to existing list
        final newItems = filtered.sublist(
          startIndex.clamp(0, filtered.length),
          endIndex,
        );
        filteredItems.addAll(newItems);
      }
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
      });
      _updateFilteredItems();
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
            if (_hasMoreItems())
              DropdownMenuEntry<String>(
                value: 'load_more',
                label: 'Mehr laden...',
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.grey),
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'load_more') {
              _loadMore();

              // Clear "Load more..." text from controller
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.controller.text = currentQuery;
              });

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
