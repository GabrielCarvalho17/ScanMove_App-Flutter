import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClose;
  final ValueChanged<String> onSearchChanged;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onClose,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16, right: 16),
      height: 40,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF303137),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onClose,
          ),
          Expanded(
            child: Center(
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Pesquisar...',
                  hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 7),
                ),
                style: TextStyle(color: Colors.white, fontSize: 20),
                onChanged: onSearchChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
