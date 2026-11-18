import 'package:flutter/material.dart';

import 'tag_shape_painter.dart';
import 'tag_style.dart';
import 'tag_types.dart';

/// A modern, customizable interactive tag / chip widget supporting custom
/// shapes ([TagShape.pill], [TagShape.rounded], [TagShape.square],
/// [TagShape.priceTag], [TagShape.ticket], [TagShape.ribbon]), 6 theme presets,
/// avatars, icons, count badges, selection states, and deletion callbacks.
class TagWidget extends StatefulWidget {
  /// Creates a [TagWidget].
  const TagWidget({
    required this.label,
    super.key,
    this.subtitle,
    this.icon,
    this.avatarText,
    this.leading,
    this.trailing,
    this.count,
    this.badgeText,
    this.color,
    this.selected = false,
    this.highlighted = false,
    this.enabled = true,
    this.deletable = false,
    this.tooltip,
    this.style,
    this.scale = 1.0,
    this.onTap,
    this.onSelected,
    this.onDeleted,
    this.onLongPress,
    this.onDoubleTap,
    this.semanticLabel,
  });

  /// Creates a [TagWidget] configured from a [TagItem] model.
  factory TagWidget.fromItem({
    required TagItem<dynamic> item,
    Key? key,
    TagStyle? style,
    bool highlighted = false,
    double scale = 1.0,
    VoidCallback? onTap,
    ValueChanged<bool>? onSelected,
    VoidCallback? onDeleted,
    VoidCallback? onLongPress,
    VoidCallback? onDoubleTap,
  }) {
    return TagWidget(
      key: key,
      label: item.label,
      subtitle: item.subtitle,
      icon: item.icon,
      avatarText: item.avatarText,
      leading: item.leading,
      count: item.count,
      badgeText: item.badgeText,
      color: item.color,
      selected: item.selected,
      highlighted: highlighted,
      enabled: item.enabled,
      deletable: item.deletable && onDeleted != null,
      tooltip: item.tooltip,
      style: style,
      scale: scale,
      onTap: onTap,
      onSelected: onSelected,
      onDeleted: onDeleted,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
    );
  }

  /// Primary text label displayed inside the tag.
  final String label;

  /// Optional secondary caption displayed beside [label].
  final String? subtitle;

  /// Optional leading icon displayed before [label].
  final IconData? icon;

  /// Optional short initials or character rendered inside a leading circular avatar.
  final String? avatarText;

  /// Optional custom leading widget that overrides [avatarText] and [icon].
  final Widget? leading;

  /// Optional custom trailing widget placed before the delete button.
  final Widget? trailing;

  /// Optional integer counter displayed inside a badge pill on the tag.
  final int? count;

  /// Optional custom badge text (e.g. `'NEW'`, `'HOT'`) overriding [count].
  final String? badgeText;

  /// Optional per-tag accent color overriding [TagStyle.accentColor].
  final Color? color;

  /// Whether the tag is currently selected.
  final bool selected;

  /// Whether the tag is visually highlighted (for example, pending backspace
  /// removal in `TagInputWidget`).
  final bool highlighted;

  /// Whether the tag responds to user gestures.
  final bool enabled;

  /// Whether to render the trailing delete button when [onDeleted] is provided.
  final bool deletable;

  /// Optional tooltip message shown on hover or long press.
  final String? tooltip;

  /// Visual theme configuration for this tag. Defaults to [TagStyle.modern].
  final TagStyle? style;

  /// Uniform scale multiplier applied to the tag (used by `TagCloudWidget`).
  final double scale;

  /// Callback invoked when the tag body is tapped.
  final VoidCallback? onTap;

  /// Callback invoked with the toggled selection state (`!selected`) when tapped.
  final ValueChanged<bool>? onSelected;

  /// Callback invoked when the trailing delete button is tapped.
  final VoidCallback? onDeleted;

  /// Callback invoked when the tag is long-pressed.
  final VoidCallback? onLongPress;

  /// Callback invoked when the tag is double-tapped.
  final VoidCallback? onDoubleTap;

  /// Optional accessibility label announced by screen readers.
  final String? semanticLabel;

  @override
  State<TagWidget> createState() => _TagWidgetState();
}

class _TagWidgetState extends State<TagWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isInteractive =>
      widget.enabled &&
      (widget.onTap != null ||
          widget.onSelected != null ||
          widget.onLongPress != null ||
          widget.onDoubleTap != null);

  void _handleTap() {
    if (!widget.enabled) return;
    widget.onTap?.call();
    widget.onSelected?.call(!widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final baseStyle = widget.style ?? TagStyle.modern();
    final resolvedStyle = baseStyle.resolveForColor(widget.color);

    final isSelected = widget.selected || widget.highlighted;
    final fillColor = isSelected
        ? resolvedStyle.selectedBackgroundColor
        : (_isHovered && _isInteractive
            ? Color.alphaBlend(
                resolvedStyle.accentColor.withValues(alpha: 0.08),
                resolvedStyle.backgroundColor,
              )
            : resolvedStyle.backgroundColor);

    final fgColor = isSelected
        ? resolvedStyle.selectedForegroundColor
        : resolvedStyle.foregroundColor;

    final strokeColor = widget.highlighted
        ? const Color(0xFFF43F5E)
        : (isSelected
            ? resolvedStyle.selectedBorderColor
            : (_isHovered && _isInteractive
                ? resolvedStyle.accentColor.withValues(alpha: 0.75)
                : resolvedStyle.borderColor));

    final activeGradient = isSelected
        ? (resolvedStyle.selectedGradient ?? resolvedStyle.gradient)
        : resolvedStyle.gradient;

    final activeShadows = isSelected
        ? (resolvedStyle.selectedShadows ?? resolvedStyle.shadows)
        : resolvedStyle.shadows;

    final effectiveBadge =
        widget.badgeText ?? (widget.count != null ? '${widget.count}' : null);

    final fontSize = resolvedStyle.effectiveFontSize * widget.scale;
    final iconSize = resolvedStyle.effectiveIconSize * widget.scale;
    final deleteIconSize = resolvedStyle.effectiveDeleteIconSize * widget.scale;

    final labelStyle = (resolvedStyle.textStyle ??
            TextStyle(
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 0.1,
              height: 1.2,
            ))
        .copyWith(
      color: fgColor,
      fontSize: fontSize,
    );

    final subStyle = (resolvedStyle.subtitleStyle ??
            TextStyle(
              fontSize: fontSize * 0.86,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ))
        .copyWith(
      color: fgColor.withValues(alpha: 0.74),
      fontSize: fontSize * 0.86,
    );

    final badgeBg = isSelected
        ? fgColor.withValues(alpha: 0.20)
        : (resolvedStyle.badgeBackgroundColor ??
            resolvedStyle.accentColor.withValues(alpha: 0.16));
    final badgeFg = isSelected
        ? fgColor
        : (resolvedStyle.badgeForegroundColor ?? resolvedStyle.accentColor);

    final badgeStyle = (resolvedStyle.badgeTextStyle ??
            TextStyle(
              fontSize: fontSize * 0.82,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ))
        .copyWith(
      color: badgeFg,
      fontSize: fontSize * 0.82,
    );

    final showCheck = widget.selected && resolvedStyle.showSelectedCheckmark;
    final showDelete =
        widget.deletable && widget.onDeleted != null && widget.enabled;

    final interactionScale = !widget.enabled
        ? 1.0
        : (_isPressed ? 0.96 : (_isHovered && _isInteractive ? 1.02 : 1.0));

    Widget content = AnimatedScale(
      scale: interactionScale,
      duration: resolvedStyle.animationDuration,
      curve: resolvedStyle.animationCurve,
      child: AnimatedOpacity(
        opacity: widget.enabled ? 1.0 : 0.48,
        duration: resolvedStyle.animationDuration,
        child: CustomPaint(
          painter: TagShapePainter(
            shape: resolvedStyle.shape,
            fillColor: fillColor,
            borderColor: strokeColor,
            borderWidth: widget.highlighted
                ? resolvedStyle.borderWidth + 0.8
                : resolvedStyle.borderWidth,
            borderRadius: resolvedStyle.effectiveBorderRadius,
            gradient: activeGradient,
            shadows: activeShadows,
            showPriceTagHole: resolvedStyle.showPriceTagHole,
          ),
          child: Padding(
            padding: resolvedStyle.effectivePadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Animated selection checkmark
                AnimatedSize(
                  duration: resolvedStyle.animationDuration,
                  curve: resolvedStyle.animationCurve,
                  child: showCheck
                      ? Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Icon(
                            resolvedStyle.selectedIcon,
                            size: iconSize,
                            color: fgColor,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),

                // Leading widget, avatarText, or icon
                if (widget.leading != null) ...<Widget>[
                  widget.leading!,
                  const SizedBox(width: 6.0),
                ] else if (widget.avatarText != null &&
                    widget.avatarText!.isNotEmpty) ...<Widget>[
                  Container(
                    width: iconSize + 4.0,
                    height: iconSize + 4.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.avatarText!,
                      style: badgeStyle.copyWith(fontSize: fontSize * 0.75),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 6.0),
                ] else if (widget.icon != null && !showCheck) ...<Widget>[
                  Icon(
                    widget.icon,
                    size: iconSize,
                    color: fgColor,
                  ),
                  const SizedBox(width: 5.5),
                ],

                // Main label
                Flexible(
                  child: Text(
                    widget.label,
                    style: labelStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Optional subtitle
                if (widget.subtitle != null &&
                    widget.subtitle!.isNotEmpty) ...<Widget>[
                  const SizedBox(width: 5.0),
                  Text(
                    widget.subtitle!,
                    style: subStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Optional count / text badge
                if (effectiveBadge != null &&
                    effectiveBadge.isNotEmpty) ...<Widget>[
                  const SizedBox(width: 6.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      effectiveBadge,
                      style: badgeStyle,
                    ),
                  ),
                ],

                // Optional trailing widget
                if (widget.trailing != null) ...<Widget>[
                  const SizedBox(width: 5.0),
                  widget.trailing!,
                ],

                // Optional delete action button
                if (showDelete) ...<Widget>[
                  const SizedBox(width: 5.0),
                  Semantics(
                    button: true,
                    label: 'Delete ${widget.label}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onDeleted,
                      child: Container(
                        padding: const EdgeInsets.all(2.0),
                        decoration: BoxDecoration(
                          color: fgColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          resolvedStyle.deleteIcon,
                          size: deleteIconSize * 0.85,
                          color: fgColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    content = MouseRegion(
      cursor: widget.enabled
          ? (_isInteractive ? SystemMouseCursors.click : MouseCursor.defer)
          : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isInteractive ? _handleTap : null,
        onLongPress: widget.enabled ? widget.onLongPress : null,
        onDoubleTap: widget.enabled ? widget.onDoubleTap : null,
        onTapDown:
            _isInteractive ? (_) => setState(() => _isPressed = true) : null,
        onTapUp:
            _isInteractive ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            _isInteractive ? () => setState(() => _isPressed = false) : null,
        child: content,
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      content = Tooltip(
        message: widget.tooltip!,
        child: content,
      );
    }

    return Semantics(
      button: _isInteractive,
      selected: widget.selected,
      enabled: widget.enabled,
      label: widget.semanticLabel ?? widget.label,
      child: content,
    );
  }
}
