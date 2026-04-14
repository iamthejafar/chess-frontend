import 'package:flutter/material.dart';

// ─── Brand ────────────────────────────────────────────────────────────────────
const Color kAppBg         = Color(0xFF0B0B0D);
const Color kAppSurface    = Color(0xFF16161A);
const Color kAppSurface2   = Color(0xFF1E1C24);
const Color kAppBorder     = Color(0xFF252530);
const Color kAppBorderSoft = Color(0xFF1E1E2A);

// ─── Gold Palette ─────────────────────────────────────────────────────────────
const Color kGold          = Color(0xFFC9A84C);
const Color kGoldLight     = Color(0xFFE8C97A);
const Color kGoldDark      = Color(0xFF9A7230);
const Color kGoldSubtle    = Color(0x1AC9A84C);   // ~10% opacity

// ─── Text ─────────────────────────────────────────────────────────────────────
const Color kTextPrimary   = Color(0xFFF0EAE0);   // warm cream
const Color kTextSecondary = Color(0xFFADA8B6);
const Color kTextMuted     = Color(0xFF706C78);

// ─── Chess Board ──────────────────────────────────────────────────────────────
const Color kSquareLight   = Color(0xFFEEDFBF);   // parchment
const Color kSquareDark    = Color(0xFF8B6343);   // walnut brown
const Color kSquareSelectedBorder = Color(0xFFC9A84C);
const Color kPossibleMoveDot      = Color(0x8C000000);
const Color kCaptureBorder        = Color(0xCC8B2020);

// ─── Semantic ─────────────────────────────────────────────────────────────────
const Color kSuccess  = Color(0xFF4CAF7D);
const Color kError    = Color(0xFF8B2020);
const Color kWarning  = Color(0xFFBF8C30);

// ─── Gradients ────────────────────────────────────────────────────────────────
const LinearGradient kGoldGradient = LinearGradient(
  colors: [kGoldLight, kGold, kGoldDark],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kSurfaceGradient = LinearGradient(
  colors: [kAppSurface2, kAppSurface],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

// ─── Design Tokens ────────────────────────────────────────────────────────────
const Color kBg         = Color(0xFF0B0B0D);
const Color kSurface    = Color(0xFF16161A);
const Color kCream      = Color(0xFFF0EAE0);
const Color kMuted      = Color(0xFF706C78);
const Color kBorder     = Color(0xFF252530);