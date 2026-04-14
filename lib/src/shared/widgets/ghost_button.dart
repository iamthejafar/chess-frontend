import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';


class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool wide;

  const GhostButton({super.key, required this.label, required this.onTap, this.wide = false});

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.wide ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? kCream.withOpacity(0.06) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered ? kCream.withOpacity(0.4) : kBorder,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _hovered ? kCream : kMuted,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}