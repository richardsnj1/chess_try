import 'package:chess_try/functions/iswhite.dart';
import 'package:chess_try/widgets/squares.dart';
import 'package:flutter/material.dart';

class ChessBoardScreen extends StatefulWidget {
  const ChessBoardScreen({super.key});

  @override
  State<ChessBoardScreen> createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chess Board"),
      ),
      body: GridView.builder(
          itemCount: 64,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8),
          itemBuilder: (ctx, index) {
            return Center(
              child: Square(
                isWhite: isWhite(index),
              ),
            );
          }),
    );
  }
}
