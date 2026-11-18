import 'package:flutter/material.dart';

import 'tag_types.dart';

/// Visual styling and theme configuration for [TagWidget], [TagGroupWidget],
/// [TagInputWidget], and [TagCloudWidget].
///
/// Includes 6 ready-to-use theme presets:
/// - [TagStyle.modern]
/// - [TagStyle.glass]
/// - [TagStyle.neon]
/// - [TagStyle.gradient]
/// - [TagStyle.outlined]
/// - [TagStyle.soft]
@immutable
class TagStyle {
  /// Creates a custom [TagStyle].
  const TagStyle({
    this.shape = TagShape.pill,
    this.size = TagSize.medium,
    this.backgroundColor = const Color(0xFFF1F5F9),
    this.selectedBackgroundColor = const Color(0xFF6366F1),
    this.foregroundColor = const Color(0xFF1E293B),
    this.selectedForegroundColor = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFFCBD5E1),
    this.selectedBorderColor = const Color(0xFF4F46E5),
    this.accentColor = const Color(0xFF6366F1),
    this.badgeBackgroundColor,
    this.badgeForegroundColor,
    this.gradient,
    this.selectedGradient,
    this.borderWidth = 1.2,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.subtitleStyle,
    this.badgeTextStyle,
    this.iconSize,
    this.deleteIconSize,
    this.deleteIcon = Icons.close_rounded,
    this.selectedIcon = Icons.check_rounded,
    this.showSelectedCheckmark = true,
    this.showPriceTagHole = true,
    this.enableGlow = false,
    this.shadows,
    this.selectedShadows,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOutCubic,
  });

  /// Clean Material 3 inspired tonal tag style with crisp borders and
  /// elevated selection state.
  factory TagStyle.modern({
    Color accentColor = const Color(0xFF6366F1),
    TagShape shape = TagShape.pill,
    TagSize size = TagSize.medium,
    bool showSelectedCheckmark = true,
  }) {
    return TagStyle(
      shape: shape,
      size: size,
      accentColor: accentColor,
      backgroundColor: accentColor.withValues(alpha: 0.10),
      selectedBackgroundColor: accentColor,
      foregroundColor: const Color(0xFF1E293B),
      selectedForegroundColor: Colors.white,
      borderColor: accentColor.withValues(alpha: 0.28),
      selectedBorderColor: accentColor,
      badgeBackgroundColor: accentColor.withValues(alpha: 0.18),
      badgeForegroundColor: accentColor,
      borderWidth: 1.2,
      showSelectedCheckmark: showSelectedCheckmark,
      selectedShadows: <BoxShadow>[
        BoxShadow(
          color: accentColor.withValues(alpha: 0.30),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Translucent frosted glassmorphic tag style suitable for dark and vibrant
  /// backgrounds.
  factory TagStyle.glass({
    Color accentColor = const Color(0xFF818CF8),
    TagShape shape = TagShape.pill,
    TagSize size = TagSize.medium,
    bool showSelectedCheckmark = true,
  }) {
    return TagStyle(
      shape: shape,
      size: size,
      accentColor: accentColor,
      backgroundColor: accentColor.withValues(alpha: 0.14),
      selectedBackgroundColor: accentColor.withValues(alpha: 0.32),
      foregroundColor: const Color(0xFFE2E8F0),
      selectedForegroundColor: Colors.white,
      borderColor: accentColor.withValues(alpha: 0.38),
      selectedBorderColor: accentColor.withValues(alpha: 0.85),
      badgeBackgroundColor: accentColor.withValues(alpha: 0.25),
      badgeForegroundColor: Colors.white,
      borderWidth: 1.4,
      showSelectedCheckmark: showSelectedCheckmark,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          accentColor.withValues(alpha: 0.22),
          accentColor.withValues(alpha: 0.08),
        ],
      ),
      selectedGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          accentColor.withValues(alpha: 0.50),
          accentColor.withValues(alpha: 0.24),
        ],
      ),
      selectedShadows: <BoxShadow>[
        BoxShadow(
          color: accentColor.withValues(alpha: 0.35),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// High-contrast dark cyber style with glowing neon borders and labels.
  factory TagStyle.neon({
    Color accentColor = const Color(0xFF00F5D4),
    TagShape shape = TagShape.rounded,
    TagSize size = TagSize.medium,
    bool showSelectedCheckmark = true,
  }) {
    return TagStyle(
      shape: shape,
      size: size,
      accentColor: accentColor,
      backgroundColor: const Color(0xFF090D16),
      selectedBackgroundColor: const Color(0xFF0D1526),
      foregroundColor: accentColor.withValues(alpha: 0.88),
      selectedForegroundColor: accentColor,
      borderColor: accentColor.withValues(alpha: 0.45),
      selectedBorderColor: accentColor,
      badgeBackgroundColor: accentColor.withValues(alpha: 0.18),
      badgeForegroundColor: accentColor,
      borderWidth: 1.5,
      enableGlow: true,
      showSelectedCheckmark: showSelectedCheckmark,
      shadows: <BoxShadow>[
        BoxShadow(
          color: accentColor.withValues(alpha: 0.16),
          blurRadius: 8,
        ),
      ],
      selectedShadows: <BoxShadow>[
        BoxShadow(
          color: accentColor.withValues(alpha: 0.48),
          blurRadius: 14,
          spreadRadius: 0.5,
        ),
      ],
    );
  }

  /// Vibrant multi-stop linear gradient tag style.
  factory TagStyle.gradient({
    Color startColor = const Color(0xFF6366F1),
    Color endColor = const Color(0xFFEC4899),
    TagShape shape = TagShape.pill,
    TagSize size = TagSize.medium,
    bool showSelectedCheckmark = true,
  }) {
    return TagStyle(
      shape: shape,
      size: size,
      accentColor: startColor,
      backgroundColor: startColor,
      selectedBackgroundColor: endColor,
      foregroundColor: Colors.white,
      selectedForegroundColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.22),
      selectedBorderColor: Colors.white.withValues(alpha: 0.70),
      badgeBackgroundColor: Colors.black.withValues(alpha: 0.22),
      badgeForegroundColor: Colors.white,
      borderWidth: 1.2,
      showSelectedCheckmark: showSelectedCheckmark,
      gradient: LinearGradient(
        colors: <Color>[
          startColor.withValues(alpha: 0.85),
          endColor.withValues(alpha: 0.85),
        ],
      ),
      selectedGradient: LinearGradient(
        colors: <Color>[startColor, endColor],
      ),
      shadows: <BoxShadow>[
        BoxShadow(
          color: startColor.withValues(alpha: 0.25),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      selectedShadows: <BoxShadow>[
        BoxShadow(
          color: endColor.withValues(alpha: 0.42),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  /// Clean transparent outline badge style with bold accent stroke.
  factory TagStyle.outlined({
    Color accentColor = const Color(0xFF6366F1),
    TagShape shape = TagShape.pill,
    TagSize size = TagSize.medium,
    bool showSelectedCheckmark = true,
  }) {
    return TagStyle(
      shape: shape,
      size: size,
      accentColor: accentColor,
      backgroundColor: Colors.transparent,
      selectedBackgroundColor: accentColor.withValues(alpha: 0.14),
      foregroundColor: accentColor,
      selectedForegroundColor: accentColor,
      borderColor: accentColor.withValues(alpha: 0.55),
      selectedBorderColor: accentColor,
      badgeBackgroundColor: accentColor.withValues(alpha: 0.15),
      badgeForegroundColor: accentColor,
      borderWidth: 1.5,
      showSelectedCheckmark: showSelectedCheckmark,
    );
  }

  /// Tactile soft-UI / neumorphic inspired tag style with dual ambient shadows.
  factory TagStyle.soft({
    Color accentColor = const Color(0xFF4F46E5),
    Color surfaceColor = const Color(0xFFEEF2F6),
    TagShape shape = TagShape.rounded,
    TagSize size = TagSize.medium,
    bool showSelectedCheckmark = true,
  }) {
    return TagStyle(
      shape: shape,
      size: size,
      accentColor: accentColor,
      backgroundColor: surfaceColor,
      selectedBackgroundColor: accentColor,
      foregroundColor: const Color(0xFF334155),
      selectedForegroundColor: Colors.white,
      borderColor: Colors.white.withValues(alpha: 0.85),
      selectedBorderColor: accentColor,
      badgeBackgroundColor: accentColor.withValues(alpha: 0.14),
      badgeForegroundColor: accentColor,
      borderWidth: 1.0,
      showSelectedCheckmark: showSelectedCheckmark,
      shadows: const <BoxShadow>[
        BoxShadow(
          color: Color(0x1F64748B),
          blurRadius: 6,
          offset: Offset(2, 3),
        ),
        BoxShadow(
          color: Color(0xCCFFFFFF),
          blurRadius: 4,
          offset: Offset(-2, -2),
        ),
      ],
      selectedShadows: <BoxShadow>[
        BoxShadow(
          color: accentColor.withValues(alpha: 0.32),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Outer geometric silhouette of the tag.
  final TagShape shape;

  /// Sizing density tier of the tag.
  final TagSize size;

  /// Background fill color when the tag is unselected.
  final Color backgroundColor;

  /// Background fill color when the tag is selected.
  final Color selectedBackgroundColor;

  /// Label and icon color when the tag is unselected.
  final Color foregroundColor;

  /// Label and icon color when the tag is selected.
  final Color selectedForegroundColor;

  /// Border stroke color when the tag is unselected.
  final Color borderColor;

  /// Border stroke color when the tag is selected.
  final Color selectedBorderColor;

  /// Primary accent color used for focus rings, badges, and highlights.
  final Color accentColor;

  /// Optional override for the count/badge pill background color.
  final Color? badgeBackgroundColor;

  /// Optional override for the count/badge pill text color.
  final Color? badgeForegroundColor;

  /// Optional background gradient when the tag is unselected.
  final Gradient? gradient;

  /// Optional background gradient when the tag is selected.
  final Gradient? selectedGradient;

  /// Width of the tag border in logical pixels.
  final double borderWidth;

  /// Optional explicit corner radius override.
  final double? borderRadius;

  /// Optional explicit inner padding override.
  final EdgeInsetsGeometry? padding;

  /// Optional custom [TextStyle] for the main tag label.
  final TextStyle? textStyle;

  /// Optional custom [TextStyle] for the secondary tag subtitle.
  final TextStyle? subtitleStyle;

  /// Optional custom [TextStyle] for the count/badge text.
  final TextStyle? badgeTextStyle;

  /// Optional explicit leading icon size override.
  final double? iconSize;

  /// Optional explicit delete button icon size override.
  final double? deleteIconSize;

  /// Icon displayed inside the delete button.
  final IconData deleteIcon;

  /// Icon displayed when the tag is selected and [showSelectedCheckmark] is true.
  final IconData selectedIcon;

  /// Whether to animate a checkmark icon into view when the tag is selected.
  final bool showSelectedCheckmark;

  /// Whether to render the circular punch-hole when [shape] is [TagShape.priceTag].
  final bool showPriceTagHole;

  /// Whether to add an accent-colored glow shadow around the tag.
  final bool enableGlow;

  /// Optional drop shadows when the tag is unselected.
  final List<BoxShadow>? shadows;

  /// Optional drop shadows when the tag is selected.
  final List<BoxShadow>? selectedShadows;

  /// Duration of animated state transitions (selection, hover, size changes).
  final Duration animationDuration;

  /// Easing curve of animated state transitions.
  final Curve animationCurve;

  /// Resolves the effective corner radius based on [borderRadius], [shape], and [size].
  double get effectiveBorderRadius {
    if (borderRadius != null) return borderRadius!;
    switch (shape) {
      case TagShape.pill:
        return 999.0;
      case TagShape.rounded:
      case TagShape.priceTag:
      case TagShape.ticket:
      case TagShape.ribbon:
        switch (size) {
          case TagSize.small:
            return 8.0;
          case TagSize.medium:
            return 10.0;
          case TagSize.large:
            return 13.0;
        }
      case TagShape.square:
        return 4.0;
    }
  }

  /// Resolves the effective inner padding based on [padding], [size], and [shape].
  EdgeInsetsGeometry get effectivePadding {
    if (padding != null) return padding!;
    final extraLeft = shape == TagShape.priceTag
        ? (showPriceTagHole ? 16.0 : 10.0)
        : (shape == TagShape.ticket ? 6.0 : 0.0);
    final extraRight = shape == TagShape.ribbon
        ? 10.0
        : (shape == TagShape.ticket ? 6.0 : 0.0);

    switch (size) {
      case TagSize.small:
        return EdgeInsets.fromLTRB(
          9.0 + extraLeft,
          4.0,
          9.0 + extraRight,
          4.0,
        );
      case TagSize.medium:
        return EdgeInsets.fromLTRB(
          12.0 + extraLeft,
          6.5,
          12.0 + extraRight,
          6.5,
        );
      case TagSize.large:
        return EdgeInsets.fromLTRB(
          16.0 + extraLeft,
          9.0,
          16.0 + extraRight,
          9.0,
        );
    }
  }

  /// Resolves the base font size for the tag label based on [size].
  double get effectiveFontSize {
    if (textStyle?.fontSize != null) return textStyle!.fontSize!;
    switch (size) {
      case TagSize.small:
        return 11.5;
      case TagSize.medium:
        return 13.0;
      case TagSize.large:
        return 15.0;
    }
  }

  /// Resolves the leading icon size based on [iconSize] and [size].
  double get effectiveIconSize {
    if (iconSize != null) return iconSize!;
    switch (size) {
      case TagSize.small:
        return 13.5;
      case TagSize.medium:
        return 15.5;
      case TagSize.large:
        return 18.0;
    }
  }

  /// Resolves the delete icon size based on [deleteIconSize] and [size].
  double get effectiveDeleteIconSize {
    if (deleteIconSize != null) return deleteIconSize!;
    switch (size) {
      case TagSize.small:
        return 13.0;
      case TagSize.medium:
        return 15.0;
      case TagSize.large:
        return 17.0;
    }
  }

  /// Returns a derived [TagStyle] adapted to a specific per-tag [itemColor].
  TagStyle resolveForColor(Color? itemColor) {
    if (itemColor == null) return this;
    if (enableGlow) {
      return copyWith(
        accentColor: itemColor,
        foregroundColor: itemColor.withValues(alpha: 0.92),
        selectedForegroundColor: itemColor,
        borderColor: itemColor.withValues(alpha: 0.50),
        selectedBorderColor: itemColor,
        badgeBackgroundColor: itemColor.withValues(alpha: 0.20),
        badgeForegroundColor: itemColor,
        shadows: <BoxShadow>[
          BoxShadow(
            color: itemColor.withValues(alpha: 0.18),
            blurRadius: 8,
          ),
        ],
        selectedShadows: <BoxShadow>[
          BoxShadow(
            color: itemColor.withValues(alpha: 0.50),
            blurRadius: 14,
            spreadRadius: 0.5,
          ),
        ],
      );
    }

    final isTransparentBg = backgroundColor.a == 0;
    return copyWith(
      accentColor: itemColor,
      backgroundColor: isTransparentBg
          ? Colors.transparent
          : itemColor.withValues(alpha: 0.13),
      selectedBackgroundColor: itemColor,
      foregroundColor: isTransparentBg ? itemColor : foregroundColor,
      selectedForegroundColor: Colors.white,
      borderColor: itemColor.withValues(alpha: 0.42),
      selectedBorderColor: itemColor,
      badgeBackgroundColor: itemColor.withValues(alpha: 0.20),
      badgeForegroundColor: isTransparentBg ? itemColor : itemColor,
      selectedShadows: <BoxShadow>[
        BoxShadow(
          color: itemColor.withValues(alpha: 0.32),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Returns a copy of this [TagStyle] with the specified properties overridden.
  TagStyle copyWith({
    TagShape? shape,
    TagSize? size,
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? foregroundColor,
    Color? selectedForegroundColor,
    Color? borderColor,
    Color? selectedBorderColor,
    Color? accentColor,
    Color? badgeBackgroundColor,
    Color? badgeForegroundColor,
    Gradient? gradient,
    bool clearGradient = false,
    Gradient? selectedGradient,
    bool clearSelectedGradient = false,
    double? borderWidth,
    double? borderRadius,
    EdgeInsetsGeometry? padding,
    TextStyle? textStyle,
    TextStyle? subtitleStyle,
    TextStyle? badgeTextStyle,
    double? iconSize,
    double? deleteIconSize,
    IconData? deleteIcon,
    IconData? selectedIcon,
    bool? showSelectedCheckmark,
    bool? showPriceTagHole,
    bool? enableGlow,
    List<BoxShadow>? shadows,
    List<BoxShadow>? selectedShadows,
    Duration? animationDuration,
    Curve? animationCurve,
  }) {
    return TagStyle(
      shape: shape ?? this.shape,
      size: size ?? this.size,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? this.selectedBackgroundColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      selectedForegroundColor:
          selectedForegroundColor ?? this.selectedForegroundColor,
      borderColor: borderColor ?? this.borderColor,
      selectedBorderColor: selectedBorderColor ?? this.selectedBorderColor,
      accentColor: accentColor ?? this.accentColor,
      badgeBackgroundColor: badgeBackgroundColor ?? this.badgeBackgroundColor,
      badgeForegroundColor: badgeForegroundColor ?? this.badgeForegroundColor,
      gradient: clearGradient ? null : (gradient ?? this.gradient),
      selectedGradient: clearSelectedGradient
          ? null
          : (selectedGradient ?? this.selectedGradient),
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      badgeTextStyle: badgeTextStyle ?? this.badgeTextStyle,
      iconSize: iconSize ?? this.iconSize,
      deleteIconSize: deleteIconSize ?? this.deleteIconSize,
      deleteIcon: deleteIcon ?? this.deleteIcon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      showSelectedCheckmark:
          showSelectedCheckmark ?? this.showSelectedCheckmark,
      showPriceTagHole: showPriceTagHole ?? this.showPriceTagHole,
      enableGlow: enableGlow ?? this.enableGlow,
      shadows: shadows ?? this.shadows,
      selectedShadows: selectedShadows ?? this.selectedShadows,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
    );
  }
}
