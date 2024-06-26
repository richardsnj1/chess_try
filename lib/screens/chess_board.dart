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
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  Map<String, int> lastMove = {};
  bool whiteKingSideCastling = true;
  bool whiteQueenSideCastling = true;
  bool blackKingSideCastling = true;
  bool blackQueenSideCastling = true;
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
    newBoard[0][3] = ChessPiece(
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
    newBoard[0][4] = ChessPiece(
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
        calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
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
            board[row + direction][col - 1]!.isWhite != selectedPiece.isWhite) {
          possibleMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != selectedPiece.isWhite) {
          possibleMoves.add([row + direction, col + 1]);
        }

        //en passant
        // if (selectedPiece!.isWhite) {
        //   if (row == 3) {
        //     if (lastMove['row'] == row &&
        //         lastMove['col'] == col - 1 &&
        //         board[row][col - 1]?.type == ChessPieces.pawn &&
        //         !board[row][col - 1]!.isWhite) {
        //       possibleMoves.add([row - 1, col - 1]);
        //     }
        //     if (lastMove['row'] == row &&
        //         lastMove['col'] == col + 1 &&
        //         board[row][col + 1]?.type == ChessPieces.pawn &&
        //         !board[row][col + 1]!.isWhite) {
        //       possibleMoves.add([row - 1, col + 1]);
        //     }
        //   }
        // } else {
        //   if (row == 4) {
        //     if (lastMove['row'] == row &&
        //         lastMove['col'] == col - 1 &&
        //         board[row][col - 1]?.type == ChessPieces.pawn &&
        //         board[row][col - 1]!.isWhite) {
        //       possibleMoves.add([row + 1, col - 1]);
        //     }
        //     if (lastMove['row'] == row &&
        //         lastMove['col'] == col + 1 &&
        //         board[row][col + 1]?.type == ChessPieces.pawn &&
        //         board[row][col + 1]!.isWhite) {
        //       possibleMoves.add([row + 1, col + 1]);
        //     }
        //   }
        // }
        if (isInBoard(row + direction, col + 1) &&
            board[row][col + 1] != null &&
            board[row][col + 1]!.type == ChessPieces.pawn &&
            board[row][col + 1]!.isWhite != selectedPiece.isWhite &&
            board[row + direction][col + 1] == null) {
          possibleMoves.add([row + direction, col + 1]);
        }
        if (isInBoard(row + direction, col - 1) &&
            board[row][col - 1] != null &&
            board[row][col - 1]!.type == ChessPieces.pawn &&
            board[row][col - 1]!.isWhite != selectedPiece.isWhite &&
            board[row + direction][col - 1] == null) {
          possibleMoves.add([row + direction, col - 1]);
        }

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
        // Castling
        if (selectedPiece.isWhite) {
          if (whiteKingSideCastling &&
              board[7][5] == null &&
              board[7][6] == null &&
              !kingInCheck(true)) {
            possibleMoves.add([7, 6]);
          }
          if (whiteQueenSideCastling &&
              board[7][3] == null &&
              board[7][2] == null &&
              board[7][1] == null &&
              !kingInCheck(true)) {
            possibleMoves.add([7, 2]);
          }
        } else {
          if (blackKingSideCastling &&
              board[0][5] == null &&
              board[0][6] == null &&
              !kingInCheck(false)) {
            possibleMoves.add([0, 6]);
          }
          if (blackQueenSideCastling &&
              board[0][3] == null &&
              board[0][2] == null &&
              board[0][1] == null &&
              !kingInCheck(false)) {
            possibleMoves.add([0, 2]);
          }
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

  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? selectedPiece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> possibleMoves =
        calculateRawValidMoves(row, col, selectedPiece);

    if (checkSimulation) {
      for (var move in possibleMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(selectedPiece!, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = possibleMoves;
    }
    return realValidMoves;
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    //update king pos
    List<int>? originalKingPosition;
    if (piece.type == ChessPieces.king) {
      originalKingPosition =
          piece.isWhite ? whiteKingPosition : blackKingPosition;
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    //simulate move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool _kingInCheck = kingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if (piece.type == ChessPieces.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }

    return !_kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    print("asdasdasd");
    if (!kingInCheck(isWhiteKing)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }
    return true;
  }

  void movePiece(int newRow, int newCol) {
    // if (selectedPiece != null && selectedPiece!.type == ChessPieces.pawn) {
    //   if ((selectedPiece!.isWhite && selectedRow == 6 && newRow == 4) ||
    //       (!selectedPiece!.isWhite && selectedRow == 1 && newRow == 3)) {
    //     lastMove = {
    //       'row': newRow,
    //       'col': newCol,
    //     };
    //   } else {
    //     lastMove = {};
    //   }
    // } else {
    //   lastMove = {};
    // }

    if (selectedPiece != null) {
      // En passant
      if (selectedPiece!.type == ChessPieces.pawn &&
          ((selectedPiece!.isWhite && selectedRow == 3) ||
              (!selectedPiece!.isWhite && selectedRow == 4))) {
        if (board[newRow][newCol] == null && newCol != selectedCol) {
          setState(() {
            if (selectedPiece!.isWhite) {
              blackPiecesTaken.add(board[selectedRow][newCol]!);
            } else {
              whitePiecesTaken.add(board[selectedRow][newCol]!);
            }
            board[selectedRow][newCol] = null;
          });
        }
      }

      // Castling
      if (selectedPiece!.type == ChessPieces.king) {
        if (newCol == selectedCol + 2) {
          setState(() {
            board[selectedRow][selectedCol + 1] =
                board[selectedRow][selectedCol + 3];
            board[selectedRow][selectedCol + 3] = null;
          });
        } else if (newCol == selectedCol - 2) {
          setState(() {
            board[selectedRow][selectedCol - 1] =
                board[selectedRow][selectedCol - 4];
            board[selectedRow][selectedCol - 4] = null;
          });
        }
      }
    }

    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    if (selectedPiece!.type == ChessPieces.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    // Check if king moves
    if (selectedPiece != null && selectedPiece!.type == ChessPieces.king) {
      if (selectedPiece!.isWhite) {
        whiteKingSideCastling = false;
        whiteQueenSideCastling = false;
      } else {
        blackKingSideCastling = false;
        blackQueenSideCastling = false;
      }
    }

    // Check if rook moves
    if (selectedPiece != null && selectedPiece!.type == ChessPieces.rook) {
      if (selectedPiece!.isWhite) {
        if (selectedRow == 7 && selectedCol == 0) {
          whiteQueenSideCastling = false;
        } else if (selectedRow == 7 && selectedCol == 7) {
          whiteKingSideCastling = false;
        }
      } else {
        if (selectedRow == 0 && selectedCol == 0) {
          blackQueenSideCastling = false;
        } else if (selectedRow == 0 && selectedCol == 7) {
          blackKingSideCastling = false;
        }
      }
    }

    // Castling move
    if (selectedPiece != null && selectedPiece!.type == ChessPieces.king) {
      if (selectedPiece!.isWhite && selectedRow == 7 && newRow == 7) {
        if (newCol == 6) {
          // King-side castling
          board[7][5] = board[7][7];
          board[7][7] = null;
        } else if (newCol == 2) {
          // Queen-side castling
          board[7][3] = board[7][0];
          board[7][0] = null;
        }
      } else if (!selectedPiece!.isWhite && selectedRow == 0 && newRow == 0) {
        if (newCol == 6) {
          // King-side castling
          board[0][5] = board[0][7];
          board[0][7] = null;
        } else if (newCol == 2) {
          // Queen-side castling
          board[0][3] = board[0][0];
          board[0][0] = null;
        }
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    if (kingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Game Over, Check Mate!"),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text("Play Again"),
            ),
          ],
        ),
      );
    }

    isWhiteTurn = !isWhiteTurn;
  }

  bool kingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }
    return false;
  }

  void resetGame() {
    Navigator.pop(context);
    initializeBoard();
    checkStatus = false;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    isWhiteTurn = true;
    setState(() {
      whiteKingPosition = [7, 4];
      blackKingPosition = [0, 3];
    });
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
          Text(checkStatus ? "CHECK" : ""),
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
