import 'package:flutter/material.dart';

import '../../core/colors.dart';

// ─── Gold Divider ─────────────────────────────────────────────────────────────
class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, required this.width});

  final double width;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: width, height: 1, color: kGold.withOpacity(0.4)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
        ),
        Container(width: width, height: 1, color: kGold.withOpacity(0.4)),
      ],
    );
  }
}