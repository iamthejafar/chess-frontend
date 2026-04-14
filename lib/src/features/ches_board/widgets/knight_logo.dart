import 'package:flutter/material.dart';

import '../../../core/colors.dart';

class KnightLogo extends StatelessWidget {
  final double size;
  const KnightLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        'assets/images/logo.png',
        width: size ,
        height: size ,
        fit: BoxFit.contain,
      ),
    );
  }
}