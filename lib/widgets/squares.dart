import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  const Square({
    super.key,
    required this.isWhite,
  });
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isWhite? Colors.grey[100] : Colors.grey[800],
    );
  }
}
