import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBar();
}

class _SearchBar extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
          hintText: "Search property, agents, etc...",
          contentPadding: const EdgeInsets.all(10.9),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0)
          ),
          suffixIcon: IconButton(
              onPressed: () {
                _searchController.clear();
              },
              icon: const Icon(Icons.clear))
      ),
      onChanged: (value) {

      },
    );
  }
}
