import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tag_controller.dart';
import 'tag_style.dart';
import 'tag_types.dart';
import 'tag_widget_item.dart';

/// An interactive weighted tag cloud widget that scales and colors each
/// [TagWidget] dynamically according to its [TagItem.weight] or [TagItem.count].
class TagCloudWidget extends StatefulWidget {
  /// Creates a [TagCloudWidget].
  const TagCloudWidget({
    super.key,
    this.controller,
    this.tags,
    this.selectionMode = TagSelectionMode.multiple,
    this.style,
    this.colorMode = TagCloudColorMode.palette,
    this.palette = TagColorPalette.vibrant,
    this.lowWeightColor = const Color(0xFF38BDF8),
    this.highWeightColor = const Color(0xFFF43F5E),
    this.minScale = 0.86,
    this.maxScale = 1.32,
    this.spacing = 10.0,
    this.runSpacing = 10.0,
    this.alignment = WrapAlignment.center,
    this.showWeightAsCount = false,
    this.labelText,
    this.onTagTap,
    this.onSelectionChanged,
  }) : assert(
          minScale > 0 && maxScale >= minScale,
          'maxScale must be greater than or equal to minScale',
        );

  /// Optional external [TagController] managing the cloud's tags.
  final TagController? controller;

  /// List of tags to display when [controller] is not provided.
  final List<TagItem<dynamic>>? tags;

  /// Selection behavior when tags in the cloud are tapped.
  final TagSelectionMode selectionMode;

  /// Base visual style applied to tags in the cloud.
  final TagStyle? style;

  /// Strategy used to assign colors to tags in the cloud.
  final TagCloudColorMode colorMode;

  /// Color palette used when [colorMode] is [TagCloudColorMode.palette].
  final List<Color> palette;

  /// Cool color for lowest-weight tags when [colorMode] is [TagCloudColorMode.heat].
  final Color lowWeightColor;

  /// Hot color for highest-weight tags when [colorMode] is [TagCloudColorMode.heat].
  final Color highWeightColor;

  /// Scale factor applied to the lowest-weight tag in the cloud.
  final double minScale;

  /// Scale factor applied to the highest-weight tag in the cloud.
  final double maxScale;

  /// Horizontal gap between adjacent tags.
  final double spacing;

  /// Vertical gap between wrapped tag rows.
  final double runSpacing;

  /// Horizontal alignment of rows in the cloud.
  final WrapAlignment alignment;

  /// Whether to automatically display the tag's rounded weight as a count badge
  /// when [TagItem.count] and [TagItem.badgeText] are not set.
  final bool showWeightAsCount;

  /// Optional header title rendered above the tag cloud.
  final String? labelText;

  /// Callback invoked when a tag in the cloud is tapped.
  final ValueChanged<TagItem<dynamic>>? onTagTap;

  /// Callback invoked whenever the selected tags in the cloud change.
  final ValueChanged<List<TagItem<dynamic>>>? onSelectionChanged;

  @override
  State<TagCloudWidget> createState() => _TagCloudWidgetState();
}

class _TagCloudWidgetState extends State<TagCloudWidget> {
  TagController? _internalController;

  TagController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TagController(
        initialTags: widget.tags ?? const <TagItem<dynamic>>[],
        selectionMode: widget.selectionMode,
      );
    }
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant TagCloudWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _internalController?.removeListener(_handleControllerChanged);
      _internalController?.dispose();
      _internalController = null;

      if (widget.controller == null) {
        _internalController = TagController(
          initialTags: widget.tags ?? const <TagItem<dynamic>>[],
          selectionMode: widget.selectionMode,
        );
      }
      _effectiveController.addListener(_handleControllerChanged);
    } else if (widget.controller == null && widget.tags != oldWidget.tags) {
      _internalController?.setTags(widget.tags ?? const <TagItem<dynamic>>[]);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _internalController?.removeListener(_handleControllerChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  double _effectiveWeight(TagItem<dynamic> item) {
    if (item.weight != 1.0 || item.count == null) {
      return item.weight;
    }
    return item.count!.toDouble();
  }

  Color? _resolveItemColor(TagItem<dynamic> item, double normalizedWeight) {
    if (item.color != null) return item.color;
    switch (widget.colorMode) {
      case TagCloudColorMode.style:
        return null;
      case TagCloudColorMode.palette:
        return TagColorPalette.colorForLabel(
          item.label,
          palette: widget.palette,
        );
      case TagCloudColorMode.heat:
        return Color.lerp(
          widget.lowWeightColor,
          widget.highWeightColor,
          normalizedWeight.clamp(0.0, 1.0),
        );
    }
  }

  void _onTagTapped(TagItem<dynamic> item) {
    widget.onTagTap?.call(item);
    if (_effectiveController.selectionMode != TagSelectionMode.none) {
      final changed = _effectiveController.toggleSelection(item.id);
      if (changed) {
        widget.onSelectionChanged?.call(_effectiveController.selectedTags);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? TagStyle.modern();
    final items = _effectiveController.filteredTags;
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    var minW = double.infinity;
    var maxW = -double.infinity;
    for (final item in items) {
      final w = _effectiveWeight(item);
      minW = math.min(minW, w);
      maxW = math.max(maxW, w);
    }
    final range = maxW - minW;

    final cloudWrap = Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      alignment: widget.alignment,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final item in items)
          Builder(
            builder: (context) {
              final w = _effectiveWeight(item);
              final t = range <= 0.0001 ? 0.5 : (w - minW) / range;
              final scale =
                  widget.minScale + (widget.maxScale - widget.minScale) * t;
              final color = _resolveItemColor(item, t);
              final displayItem = (widget.showWeightAsCount &&
                      item.count == null &&
                      item.badgeText == null)
                  ? item.copyWith(
                      count: w.round(),
                      color: color,
                    )
                  : item.copyWith(color: color);

              return TagWidget.fromItem(
                key: ValueKey<String>('cloud_tag_${item.id}'),
                item: displayItem,
                style: effectiveStyle,
                scale: scale,
                onTap: () => _onTagTapped(item),
              );
            },
          ),
      ],
    );

    if (widget.labelText == null) {
      return cloudWrap;
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.labelText!,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10.0),
        cloudWrap,
      ],
    );
  }
}
