enum ChessPieces {
  pawn,
  rook,
  knight,
  bishop,
  queen,
  king,
}

class ChessPiece{
  ChessPiece({
    required this.type,
    required this.isWhite,
    required this.image,
  });

  final ChessPieces type;
  final bool isWhite;
  final String image;
}
