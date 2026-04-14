import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';


// ─── Buttons ──────────────────────────────────────────────────────────────────
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool wide;

  const PrimaryButton({super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.wide = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isLoading ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.wide ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [kGoldLight, kGold]
                  : [kGold, const Color(0xFFAA8930)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? [BoxShadow(color: kGold.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))]
                : [BoxShadow(color: kGold.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: widget.isLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: kBg),
          )
              : Text(
            widget.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: kBg,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}