import 'package:flutter/material.dart';
import '../../../services/websocket_service.dart';

class ChessBoard extends StatefulWidget {
  final String? gameId;
  final bool isGameStarted;
  final Function() onGameStart;
  final List<String> boardState;
  final Function(int fromIndex, int toIndex) onMovePiece;
  final String turnColor;
  final List<int> Function(int fromIndex) getPossibleMoves;

  const ChessBoard({
    super.key,
    required this.boardState,
    required this.onMovePiece,
    required this.turnColor,
    required this.getPossibleMoves,
    this.gameId,
    this.isGameStarted = false,
    required this.onGameStart,
  });

  @override
  _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  int? _dragFromIndex;
  List<int> _highlightedSquares = [];

  int? fromIndex;

  void _onSquareTapped(int index) {
    setState(() {
      _highlightedSquares = widget.getPossibleMoves(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ 8;
              final col = index % 8;
              final isLightSquare = (row + col) % 2 == 0;

              if (index >= widget.boardState.length) {
                return Container();
              }
              final piece = widget.boardState[index];
              final isHighlighted = _highlightedSquares.contains(index);

              return GestureDetector(
                onTap: () {
                  _onSquareTapped(index);
                  if (fromIndex != null) {
                    if (fromIndex != index) {
                      setState(() {
                        widget.onMovePiece(fromIndex!, index);
                        _highlightedSquares = [];
                      });
                    }
                  }
                  fromIndex = index;
                },
                child: DragTarget<int>(
                  onAcceptWithDetails: (fromIndex) {
                    if (fromIndex.data != index) {
                      setState(() {
                        widget.onMovePiece(fromIndex.data, index);
                        _highlightedSquares = [];
                      });
                    }
                  },
                  builder: (context, candidateData, rejectedData) {
                    String assetUrl =
                        "assets/images/${piece == piece.toLowerCase() ? "b" : "w"}${piece.toLowerCase()}.png";
                    return Draggable<int>(
                      data: index,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Center(
                              child: piece == "."
                                  ? const SizedBox()
                                  : Image.asset(assetUrl)),
                        ),
                      ),
                      childWhenDragging: Container(
                        color: isLightSquare
                            ? const Color(0xffebecd0)
                            : Colors.grey,
                      ),
                      onDragStarted: () {
                        _dragFromIndex = index;
                      },
                      onDragEnd: (details) {
                        _dragFromIndex = null;
                      },
                      child: Container(
                        color: (isLightSquare
                            ? const Color(0xffebecd0)
                            : Colors.grey),
                        child: Center(
                            child: isHighlighted && piece == "."
                                ? Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: CircleAvatar(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.5),
                                    ),
                                  )
                                : isHighlighted && piece != "."
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor:
                                                Colors.black.withOpacity(0.5),
                                          ),
                                          Image.asset(assetUrl),
                                        ],
                                      )
                                    : piece == "." && !isHighlighted
                                        ? SizedBox()
                                        : Image.asset(assetUrl)),
                      ),
                    );
                  },
                ),
              );
            },
            itemCount: 64,
          ),
        ),
        if (!widget.isGameStarted)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  onPressed: () {
                    widget.onGameStart();
                  },
                  child: const Text(
                    'Start Game',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
