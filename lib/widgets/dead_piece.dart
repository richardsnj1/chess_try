import 'package:flutter/material.dart';

class DeadPiece extends StatelessWidget {
  const DeadPiece({
    super.key,
    required this.image,
    required this.isWhite,
  });

  final String image;
  final bool isWhite;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      child: Image.asset(
        
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}
