import 'package:flutter/material.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

class SearchBarWidget extends StatefulWidget {
  final String placeholder;
  final void Function()? onFilterTap;

  const SearchBarWidget({
    super.key,
    required this.placeholder,
    this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ✅ Search Input
        Expanded(
          child: TextField(
            focusNode: _focusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: widget.placeholder,
              prefixIcon: const Icon(
                BootstrapIcons.search,
                color: Colors.grey,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ✅ Filter Button
        InkWell(
          onTap: widget.onFilterTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  const Color.fromARGB(27, 255, 167, 255), // ungu opacity 30%
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              BootstrapIcons.filter,
              color: Color(0xFF2145BF), // biru tua
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
