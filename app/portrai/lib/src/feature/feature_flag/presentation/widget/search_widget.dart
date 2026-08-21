import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({
    required this.searchController,
    required this.searchQuery,
    required this.onSearch,
    this.isEnabled = true,
    this.focusNode,
    super.key,
  });

  final TextEditingController searchController;
  final String searchQuery;
  final void Function(String) onSearch;
  final FocusNode? focusNode;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: searchController,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: 'Search Feature Flags',
        //context.l10n.searchFeatureFlags,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => onSearch(''),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: onSearch,
      enabled: isEnabled,
    );
  }
}
