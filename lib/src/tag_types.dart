import 'package:flutter/material.dart';

/// Defines the outer geometric silhouette of a [TagWidget].
enum TagShape {
  /// Full stadium capsule with circular left and right ends.
  pill,

  /// Modern rounded rectangle with a balanced corner radius.
  rounded,

  /// Crisp minimal rectangle with a subtle 4px corner radius.
  square,

  /// Classic physical retail price-tag silhouette with an angled pointer end
  /// and an optional decorative punch hole.
  priceTag,

  /// Event ticket / coupon badge with semicircular perforated cutouts on the
  /// left and right edges.
  ticket,

  /// Bookmark ribbon banner with a V-shaped chevron notch on the right edge.
  ribbon,
}

/// Predefined sizing density tiers for [TagWidget].
enum TagSize {
  /// Compact badge density ideal for inline metadata and dense lists.
  small,

  /// Balanced standard tag size for forms, filter bars, and tag inputs.
  medium,

  /// Prominent touch-friendly tag size for hero filters and dashboards.
  large,
}

/// Selection behavior for tags inside a [TagGroupWidget] or [TagController].
enum TagSelectionMode {
  /// Tags do not maintain toggle selection state when tapped.
  none,

  /// Only a single tag can be selected at any given time (radio choice chip).
  single,

  /// Multiple tags can be selected simultaneously (filter chip).
  multiple,
}

/// Layout arrangement for a collection of tags in [TagGroupWidget].
enum TagGroupLayout {
  /// Flows tags across multiple lines using a responsive [Wrap].
  wrap,

  /// Displays tags in a single horizontally scrollable filter bar.
  horizontalScroll,
}

/// Layout arrangement for [TagInputWidget].
enum TagInputLayout {
  /// Created tags and the inline text input wrap together inside the field.
  wrap,

  /// Created tags and the inline text input scroll horizontally on one row.
  scrollableHorizontal,

  /// The text input field appears on top and created tags wrap below it.
  stacked,
}

/// Casing transformation applied to newly created tags in [TagInputWidget].
enum TagCaseMode {
  /// Preserves the exact character casing entered by the user.
  preserve,

  /// Transforms tag labels to lowercase (e.g. `flutter`).
  lowercase,

  /// Transforms tag labels to uppercase (e.g. `FLUTTER`).
  uppercase,

  /// Transforms tag labels to title case (e.g. `Flutter Dart`).
  titleCase,
}

/// Reason why a candidate tag was rejected by [TagController] or [TagInputWidget].
enum TagRejectionReason {
  /// The trimmed tag label was empty.
  empty,

  /// A tag with an identical label already exists and duplicates are disabled.
  duplicate,

  /// The maximum allowed number of tags (`maxTags`) has already been reached.
  maxTagsReached,

  /// The tag label is shorter than the configured `minTagLength`.
  tooShort,

  /// The tag label exceeds the configured `maxTagLength`.
  tooLong,

  /// A custom validator callback returned an error for the candidate tag.
  customValidationFailed,
}

/// Coloring strategy used by `TagCloudWidget` when rendering weighted tags.
enum TagCloudColorMode {
  /// Uses the base `TagStyle` (or each item's explicit [TagItem.color]).
  style,

  /// Assigns deterministic vibrant accents from [TagColorPalette].
  palette,

  /// Interpolates between a low-weight cool color and high-weight hot color.
  heat,
}

/// Curated color palettes and string formatting helpers for tags.
class TagColorPalette {
  const TagColorPalette._();

  /// Vibrant modern accent colors suitable for dark and light surfaces.
  static const List<Color> vibrant = <Color>[
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFFF43F5E), // Rose
    Color(0xFFF59E0B), // Amber
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFFA855F7), // Purple
    Color(0xFF14B8A6), // Teal
  ];

  /// Soft pastel accent colors for gentle UI tags.
  static const List<Color> pastel = <Color>[
    Color(0xFF818CF8),
    Color(0xFFC084FC),
    Color(0xFFF472B6),
    Color(0xFFFB7185),
    Color(0xFFFBBF24),
    Color(0xFF34D399),
    Color(0xFF38BDF8),
    Color(0xFFA78BFA),
  ];

  /// High-contrast glowing cyber neon colors.
  static const List<Color> neon = <Color>[
    Color(0xFF00F5D4), // Neon Mint
    Color(0xFF38BDF8), // Electric Sky
    Color(0xFFA855F7), // Neon Purple
    Color(0xFFF43F5E), // Laser Rose
    Color(0xFFFACC15), // Cyber Yellow
    Color(0xFF4ADE80), // Matrix Green
  ];

  /// Returns a deterministic color from [palette] based on [label]'s character codes.
  static Color colorForLabel(
    String label, {
    List<Color> palette = vibrant,
  }) {
    if (palette.isEmpty) {
      return const Color(0xFF6366F1);
    }
    var hash = 0;
    for (var i = 0; i < label.length; i++) {
      hash = (hash * 31 + label.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return palette[hash % palette.length];
  }

  /// Transforms [input] according to the specified [mode].
  static String applyCase(String input, TagCaseMode mode) {
    switch (mode) {
      case TagCaseMode.preserve:
        return input;
      case TagCaseMode.lowercase:
        return input.toLowerCase();
      case TagCaseMode.uppercase:
        return input.toUpperCase();
      case TagCaseMode.titleCase:
        if (input.isEmpty) return input;
        return input.split(RegExp(r'\s+')).map((word) {
          if (word.isEmpty) return word;
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        }).join(' ');
    }
  }
}

/// Immutable data model representing a single tag or chip item.
@immutable
class TagItem<T> {
  /// Creates a [TagItem] with the given [label] and optional metadata.
  const TagItem({
    required this.label,
    String? id,
    this.subtitle,
    this.icon,
    this.avatarText,
    this.leading,
    this.count,
    this.badgeText,
    this.color,
    this.weight = 1.0,
    this.selected = false,
    this.enabled = true,
    this.deletable = true,
    this.tooltip,
    this.data,
  }) : id = id ?? label;

  /// Creates a list of [TagItem] instances from a list of string [labels].
  static List<TagItem<void>> fromLabels(
    Iterable<String> labels, {
    bool selected = false,
    bool deletable = true,
    bool autoColor = false,
  }) {
    return labels
        .map(
          (label) => TagItem<void>(
            label: label,
            selected: selected,
            deletable: deletable,
            color: autoColor ? TagColorPalette.colorForLabel(label) : null,
          ),
        )
        .toList();
  }

  /// Unique identifier for this tag. Defaults to [label] when omitted.
  final String id;

  /// Primary text displayed inside the tag.
  final String label;

  /// Optional secondary caption or category text shown next to [label].
  final String? subtitle;

  /// Optional leading icon displayed before the label.
  final IconData? icon;

  /// Optional short text (such as initials `'AI'`) rendered inside a circular
  /// leading avatar badge when [leading] is null.
  final String? avatarText;

  /// Optional custom leading widget that takes precedence over [avatarText] and [icon].
  final Widget? leading;

  /// Optional numeric counter rendered inside a pill badge on the tag (e.g. `128`).
  final int? count;

  /// Optional custom badge text rendered on the tag (e.g. `'NEW'` or `'PRO'`).
  /// Takes precedence over [count] when both are provided.
  final String? badgeText;

  /// Optional per-tag accent color overriding the base `TagStyle.accentColor`.
  final Color? color;

  /// Relative importance weight of this tag (used by `TagCloudWidget` and sorting).
  final double weight;

  /// Whether this tag is currently in a selected state.
  final bool selected;

  /// Whether user interactions (tap, select, delete) are enabled for this tag.
  final bool enabled;

  /// Whether this tag displays a delete button when deletions are enabled.
  final bool deletable;

  /// Optional tooltip message shown on long-press or mouse hover.
  final String? tooltip;

  /// Optional strongly-typed custom payload associated with this tag.
  final T? data;

  /// Effective badge text derived from [badgeText] or [count].
  String? get effectiveBadge => badgeText ?? (count != null ? '$count' : null);

  /// Returns a copy of this [TagItem] with the specified fields replaced.
  TagItem<T> copyWith({
    String? id,
    String? label,
    String? subtitle,
    bool clearSubtitle = false,
    IconData? icon,
    bool clearIcon = false,
    String? avatarText,
    bool clearAvatarText = false,
    Widget? leading,
    bool clearLeading = false,
    int? count,
    bool clearCount = false,
    String? badgeText,
    bool clearBadgeText = false,
    Color? color,
    bool clearColor = false,
    double? weight,
    bool? selected,
    bool? enabled,
    bool? deletable,
    String? tooltip,
    bool clearTooltip = false,
    T? data,
  }) {
    return TagItem<T>(
      id: id ?? this.id,
      label: label ?? this.label,
      subtitle: clearSubtitle ? null : (subtitle ?? this.subtitle),
      icon: clearIcon ? null : (icon ?? this.icon),
      avatarText: clearAvatarText ? null : (avatarText ?? this.avatarText),
      leading: clearLeading ? null : (leading ?? this.leading),
      count: clearCount ? null : (count ?? this.count),
      badgeText: clearBadgeText ? null : (badgeText ?? this.badgeText),
      color: clearColor ? null : (color ?? this.color),
      weight: weight ?? this.weight,
      selected: selected ?? this.selected,
      enabled: enabled ?? this.enabled,
      deletable: deletable ?? this.deletable,
      tooltip: clearTooltip ? null : (tooltip ?? this.tooltip),
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TagItem<T> &&
        other.id == id &&
        other.label == label &&
        other.subtitle == subtitle &&
        other.icon == icon &&
        other.avatarText == avatarText &&
        other.count == count &&
        other.badgeText == badgeText &&
        other.color == color &&
        other.weight == weight &&
        other.selected == selected &&
        other.enabled == enabled &&
        other.deletable == deletable &&
        other.tooltip == tooltip &&
        other.data == data;
  }

  @override
  int get hashCode => Object.hash(
        id,
        label,
        subtitle,
        icon,
        avatarText,
        count,
        badgeText,
        color,
        weight,
        selected,
        enabled,
        deletable,
        tooltip,
        data,
      );

  @override
  String toString() =>
      'TagItem(id: $id, label: $label, selected: $selected, weight: $weight)';
}
