import 'package:chess_try/models/pieces.dart';
import 'package:flutter/material.dart';

class Square extends StatelessWidget {
  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  final bool isValidMove;

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.grey[600];
    } 
    else if(isValidMove){
      squareColor = Colors.grey[800];
    }
    else {
      squareColor = isWhite ? Colors.green[200] : Colors.green[800];
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        margin: EdgeInsets.all(isValidMove ? 8 : 0),
        child: piece != null
            ? Image.asset(piece!.image)
            : null,
      ),
    );
  }
}
