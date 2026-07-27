import 'package:flutter/material.dart';

/// Centralized color palette for PecoNote.
///
/// Every color used across the app should be referenced from here instead
/// of being redefined as a private per-file constant or inline literal —
/// several colors used to drift into near-duplicate hex values (e.g. two
/// different "gray text" shades) simply because each screen declared its
/// own copy.
abstract final class AppColors {
  // Base surfaces
  static const white = Colors.white;
  static const transparent = Colors.transparent;

  // Text
  static const textDark = Color(0xFF3B4358);
  static const grayText = Color(0xFF7A8296);
  static const grayTextLight = Color(0xFF8A93A8);
  static const labelGray = Color(0xFF98A0B5);
  static const placeholderGray = Color(0xFF9AA2B5);

  // Brand / accent blues
  static const accentBlue = Color(0xFF3D6FE5);
  static const accentBlueMuted = Color(0xFF5B7FB9);
  static const accentBlueSoft = Color(0xFF6C7BE0);
  static const accentBlueBg = Color(0xFFD6E6FF);
  static const progressBlue = Color(0xFF8FA8D6);

  // Shadows
  static const shadowBlue = Color(0xFF6E87B4);
  static const iconShadow = Color(0xFF788FBE);

  // Status
  static const error = Color(0xFFB3261E);
  static const income = Color(0xFF2FA36B);
  static const incomeAlt = Color(0xFF3E9E7C);
  static const expense = Color(0xFFD1445B);
  static const notificationDot = Color(0xFFE0525F);
  static const success = Color(0xFF2E8B57);

  // Surfaces / fields
  static const scaffoldVivid = Color(0xFFF7FAFD);
  static const scaffoldSoft = Color(0xFFFCFDFE);
  static const searchFieldBg = Color(0xFFF3F4F8);
  static const dotInactive = Color(0xFFD8DEEA);
  static const subChipBorder = Color(0xFFE7EAF2);
  static const chipSelectedBg = Color(0xFFC9F0DA);

  // Gradient blobs (GradientBackground)
  static const blobBlue = Color(0xFFAED4FA);
  static const blobOrange = Color(0xFFFFD3BC);
  static const blobGreen = Color(0xFFB4E8CE);
  static const blobPink = Color(0xFFF6C7DE);

  // Balance card
  static const balanceGradientStart = Color(0xFFEAF2FF);
  static const balanceGradientMid = Color(0xFFFCEFE6);
  static const balanceGradientEnd = Color(0xFFF6F8FC);
  static const balanceCentsText = Color(0xFF6B7690);

  // Category / icon backgrounds
  static const iconBgGreen = Color(0xFFE0F3E6);
  static const iconFgGreen = Color(0xFF3F9463);
  static const iconBgRed = Color(0xFFF7E1E4);
  static const iconFgRed = Color(0xFF9C3B49);
  static const iconBgYellow = Color(0xFFFBEFD9);
  static const iconFgYellow = Color(0xFFB9862E);
  static const iconBgBrown = Color(0xFFEFE2D8);
  static const iconFgBrown = Color(0xFF8C6A4E);
  static const iconBgOrange = Color(0xFFFFE7CE);
  static const iconFgOrange = Color(0xFFC17A2E);
  static const iconBgOrangeAlt = Color(0xFFFFE0D6);
  static const iconFgOrangeAlt = Color(0xFFC1602E);
  static const iconBgOrangeSoft = Color(0xFFFFE1CC);
  static const iconFgOrangeSoft = Color(0xFFB5651D);
  static const iconBgMintLight = Color(0xFFD9F2E3);
}
