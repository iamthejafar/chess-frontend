import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';


// ─── Buttons ──────────────────────────────────────────────────────────────────
class CustomOutlinedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool wide;

  const CustomOutlinedButton({super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.wide = false,
  });

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton> {
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
            // gradient: LinearGradient(
            //   colors: _hovered
            //       ? [kGoldLight, kGold]
            //       : [kGold, const Color(0xFFAA8930)],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: kGold,
              width: 0.5,
            ),
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
              color: kGold,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}