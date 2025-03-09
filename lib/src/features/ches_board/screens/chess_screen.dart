import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chess_bloc.dart';
import '../bloc/game_bloc.dart';
import '../widgets/chess_board.dart';
import 'package:logger/logger.dart';

import '../widgets/chess_data.dart';

class ChessScreen extends StatelessWidget {
  final Logger _logger = Logger();

  ChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chess Game'),
            ),
            body: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: state is GameInProgress
                          ? ChessBoard(
                              boardState: _fenToBoard(state.fen),
                              onMovePiece: (fromIndex, toIndex) {
                                final from = _indexToSquare(fromIndex);
                                final to = _indexToSquare(toIndex);
                                context
                                    .read<GameBloc>()
                                    .add(MovePiece(from, to));
                              },
                              turnColor: state.sideToMove.toLowerCase(),
                              getPossibleMoves: (index) {
                                // TODO: Implement getting possible moves
                                return [];
                              },
                              isGameStarted: true,
                              onGameStart: () {
                                context.read<GameBloc>().add(StartGame());
                              },
                            )
                          : ChessBoard(
                              boardState: _getInitialBoard(),
                              onMovePiece: (_, __) {},
                              turnColor: 'white',
                              getPossibleMoves: (_) => [],
                              isGameStarted: false,
                              onGameStart: () {
                                context.read<GameBloc>().add(StartGame());
                              },
                            ),
                    ),
                  ],
                ),
                if (state is GameWaitingForOpponent)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Text(
                        'Waiting for opponent...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // BlocProvider(
                //   create: (context) => ChessBloc()..add(InitGame()),
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: BlocConsumer<ChessBloc, ChessState>(
                //       listener: (context, state) {},
                //       builder: (context, state) {
                //         final chessBloc = BlocProvider.of<ChessBloc>(context);
                //         if (state is ChessUpdatedState) {
                //           return Expanded(child: const ChessData());
                //         }
                //         return const CircularProgressIndicator();
                //       },
                //     ),
                //   ),
                // )
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _getInitialBoard() {
    return [
      'r',
      'n',
      'b',
      'q',
      'k',
      'b',
      'n',
      'r',
      'p',
      'p',
      'p',
      'p',
      'p',
      'p',
      'p',
      'p',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      '.',
      'P',
      'P',
      'P',
      'P',
      'P',
      'P',
      'P',
      'P',
      'R',
      'N',
      'B',
      'Q',
      'K',
      'B',
      'N',
      'R',
    ];
  }

  List<String> _fenToBoard(String fen) {
    final board = List<String>.filled(64, '.');
    final parts = fen.split(' ');
    final rows = parts[0].split('/');

    for (int row = 0; row < 8; row++) {
      int col = 0;
      for (int i = 0; i < rows[row].length; i++) {
        final char = rows[row][i];
        if (char.contains(RegExp(r'[1-8]'))) {
          col += int.parse(char);
        } else {
          board[row * 8 + col] = char;
          col++;
        }
      }
    }

    return board;
  }

  String _indexToSquare(int index) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + (index % 8));
    final rank = 8 - (index ~/ 8);
    return '$file$rank';
  }
}
