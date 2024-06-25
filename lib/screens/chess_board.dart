import 'package:chess_try/functions/global_methods.dart';
import 'package:chess_try/models/pieces.dart';
import 'package:chess_try/widgets/dead_piece.dart';
import 'package:chess_try/widgets/squares.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChessBoardScreen extends StatefulWidget {
  const ChessBoardScreen({super.key});

  @override
  State<ChessBoardScreen> createState() => _ChessBoardScreenState();
}

class _ChessBoardScreenState extends State<ChessBoardScreen> {
  List<List<ChessPiece?>> board = [[]];

  ChessPiece? selectedPiece;

  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];

  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  bool isWhiteTurn = true;

  @override
  void initState() {
    super.initState();
    initializeBoard();
  }

  void initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));
    //[[12345678],[],...]

    //pawn
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieces.pawn,
        isWhite: false,
        image: "assets/black-pawn.png",
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieces.pawn,
        isWhite: true,
        image: "assets/white-pawn.png",
      );
    }

    //rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieces.rook,
      isWhite: false,
      image: "assets/black-rook.png",
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieces.rook,
      isWhite: false,
      image: "assets/black-rook.png",
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieces.rook,
      isWhite: true,
      image: "assets/white-rook.png",
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieces.rook,
      isWhite: true,
      image: "assets/white-rook.png",
    );

    //knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieces.knight,
      isWhite: false,
      image: "assets/black-knight.png",
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieces.knight,
      isWhite: false,
      image: "assets/black-knight.png",
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieces.knight,
      isWhite: true,
      image: "assets/white-knight.png",
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieces.knight,
      isWhite: true,
      image: "assets/white-knight.png",
    );

    //bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieces.bishop,
      isWhite: false,
      image: "assets/black-bishop.png",
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieces.bishop,
      isWhite: false,
      image: "assets/black-bishop.png",
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieces.bishop,
      isWhite: true,
      image: "assets/white-bishop.png",
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieces.bishop,
      isWhite: true,
      image: "assets/white-bishop.png",
    );

    //queen
    newBoard[0][4] = ChessPiece(
      type: ChessPieces.queen,
      isWhite: false,
      image: "assets/black-queen.png",
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieces.queen,
      isWhite: true,
      image: "assets/white-queen.png",
    );

    //kings
    newBoard[0][3] = ChessPiece(
      type: ChessPieces.king,
      isWhite: false,
      image: "assets/black-king.png",
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieces.king,
      isWhite: true,
      image: "assets/white-king.png",
    );
    setState(() {
      board = newBoard;
    });
  }

  void pieceSelected(int row, int col) {
    if (selectedPiece == null && board[row][col] != null) {
      setState(() {
        // if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedPiece = board[row][col];
          selectedRow = row;
          selectedCol = col;
        // }
      });
    } else if (board[row][col] == selectedPiece &&
        board[row][col]!.isWhite == selectedPiece!.isWhite) {
      setState(() {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
      });
    } else if (board[row][col] != null &&
        board[row][col]!.isWhite == selectedPiece!.isWhite) {
      setState(() {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedCol = col;
      });
    } else if (selectedPiece != null &&
        validMoves.any((element) => element[0] == row && element[1] == col)) {
      movePiece(row, col);
    }

    validMoves =
        calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);
  }

  List<List<int>> calculateRawValidMoves(
      int row, int col, ChessPiece? selectedPiece) {
    List<List<int>> possibleMoves = [];

    if (selectedPiece == null) {
      return [];
    }

    int direction = selectedPiece.isWhite ? -1 : 1;

    switch (selectedPiece.type) {
      case ChessPieces.pawn:
        //move forward
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          possibleMoves.add([row + direction, col]);
        }
        //move 2
        if ((row == 1 && !selectedPiece.isWhite) ||
            (row == 6 && selectedPiece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            possibleMoves.add([row + 2 * direction, col]);
          }
        }

        //kill diagonal
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite) {
          possibleMoves.add([row + direction, col + 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            !board[row + direction][col + 1]!.isWhite) {
          possibleMoves.add([row + direction, col + 1]);
        }
        //  if (isInBoard(row + direction, col - 1) &&
        //     board[row + direction][col + 1] != null &&
        //     board[row + direction][col - 1]!.isWhite) {
        //   possibleMoves.add([row + direction, col - 1]);
        // }
        // if (isInBoard(row + direction, col + 1) &&
        //     board[row + direction][col - 1] != null &&
        //     !board[row + direction][col + 1]!.isWhite) {
        //   possibleMoves.add([row + direction, col - 1]);
        // }
        break;
      case ChessPieces.rook:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != selectedPiece.isWhite) {
                possibleMoves.add([newRow, newCol]); //capture
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieces.knight:
        var lMoves = [
          [-2, -1],
          [-2, 1],
          [2, -1],
          [2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
        ];

        for (var move in lMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != selectedPiece.isWhite) {
              possibleMoves.add([newRow, newCol]); //capture
            }
            continue;
          }
          possibleMoves.add([newRow, newCol]);
        }

        break;
      case ChessPieces.bishop:
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != selectedPiece.isWhite) {
                possibleMoves.add([newRow, newCol]); //capture
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;

      case ChessPieces.queen:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != selectedPiece.isWhite) {
                possibleMoves.add([newRow, newCol]); //capture
              }
              break;
            }
            possibleMoves.add([newRow, newCol]);
            i++;
          }
        }

        break;
      case ChessPieces.king:
        var directions = [
          [-1, 0], //up
          [1, 0], //down
          [0, -1], //left
          [0, 1], //right
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != selectedPiece.isWhite) {
              possibleMoves.add([newRow, newCol]); //capture
            }
            continue;
          }
          possibleMoves.add([newRow, newCol]);
        }
        break;
      default:
    }

    return possibleMoves;
  }
  // ChessPiece pawnPiece = ChessPiece(
  //   type: ChessPieces.pawn,
  //   isWhite: true,
  //   image: "assets/black-pawn.png",
  // );

  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    isWhiteTurn = !isWhiteTurn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chess Board"),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: whitePiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                return DeadPiece(
                    image: whitePiecesTaken[index].image,
                    isWhite: whitePiecesTaken[index].isWhite);
              },
            ),
          ),
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 64,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (ctx, index) {
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedRow == row && selectedCol == col;

                bool isValidMove = false;
                for (var position in validMoves) {
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }
                return Center(
                  child: Square(
                    isWhite: isWhite(index),
                    piece: board[row][col],
                    isSelected: isSelected,
                    isValidMove: isValidMove,
                    onTap: () {
                      pieceSelected(row, col);
                    },
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: blackPiecesTaken.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) {
                return DeadPiece(
                    image: blackPiecesTaken[index].image,
                    isWhite: blackPiecesTaken[index].isWhite);
              },
            ),
          ),
        ],
      ),
    );
  }
}
