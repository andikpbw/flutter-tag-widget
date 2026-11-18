import 'package:flutter/material.dart';

import 'tag_controller.dart';
import 'tag_style.dart';
import 'tag_types.dart';
import 'tag_widget_item.dart';

/// A responsive tag collection and filter bar widget supporting single-choice
/// and multi-choice selection, horizontal scrolling or multi-line wrapping,
/// an optional `"All"` toggle chip, and collapsible `+N more` overflow expansion.
class TagGroupWidget extends StatefulWidget {
  /// Creates a [TagGroupWidget].
  const TagGroupWidget({
    super.key,
    this.controller,
    this.tags,
    this.selectionMode = TagSelectionMode.multiple,
    this.layout = TagGroupLayout.wrap,
    this.style,
    this.spacing = 8.0,
    this.runSpacing = 8.0,
    this.wrapAlignment = WrapAlignment.start,
    this.showAllTag = false,
    this.allTagLabel = 'All',
    this.maxVisibleTags,
    this.expandLabelBuilder,
    this.collapseLabel = 'Show less',
    this.deletable = false,
    this.labelText,
    this.helperText,
    this.emptyWidget,
    this.onTagTap,
    this.onSelectionChanged,
    this.onTagDeleted,
  }) : assert(
          maxVisibleTags == null || maxVisibleTags > 0,
          'maxVisibleTags must be greater than zero when provided',
        );

  /// Optional external [TagController] managing the tags and selection state.
  final TagController? controller;

  /// List of tags to display when [controller] is not provided.
  final List<TagItem<dynamic>>? tags;

  /// Selection mode used when creating an internal controller.
  final TagSelectionMode selectionMode;

  /// Arrangement layout ([TagGroupLayout.wrap] or [TagGroupLayout.horizontalScroll]).
  final TagGroupLayout layout;

  /// Visual theme applied to all tags in the group.
  final TagStyle? style;

  /// Horizontal gap between adjacent tags.
  final double spacing;

  /// Vertical gap between wrapped rows when [layout] is [TagGroupLayout.wrap].
  final double runSpacing;

  /// Horizontal alignment of wrapped tag rows.
  final WrapAlignment wrapAlignment;

  /// Whether to prepend a master `"All"` filter chip at the start of the group.
  final bool showAllTag;

  /// Label displayed on the master `"All"` chip when [showAllTag] is `true`.
  final String allTagLabel;

  /// Optional maximum number of tags shown before collapsing the rest behind
  /// an interactive `+N more` chip.
  final int? maxVisibleTags;

  /// Custom label builder for the overflow expansion chip.
  /// Defaults to `'+$hiddenCount more'`.
  final String Function(int hiddenCount)? expandLabelBuilder;

  /// Label displayed on the collapse chip when overflow tags are expanded.
  final String collapseLabel;

  /// Whether tags in this group display a trailing delete button.
  final bool deletable;

  /// Optional section header text rendered above the tag group.
  final String? labelText;

  /// Optional helper caption rendered below the tag group.
  final String? helperText;

  /// Optional placeholder widget rendered when there are no tags to display.
  final Widget? emptyWidget;

  /// Callback invoked whenever a tag is tapped.
  final ValueChanged<TagItem<dynamic>>? onTagTap;

  /// Callback invoked with the updated list of selected tags whenever selection changes.
  final ValueChanged<List<TagItem<dynamic>>>? onSelectionChanged;

  /// Callback invoked when a tag's delete button is tapped.
  final ValueChanged<TagItem<dynamic>>? onTagDeleted;

  @override
  State<TagGroupWidget> createState() => _TagGroupWidgetState();
}

class _TagGroupWidgetState extends State<TagGroupWidget> {
  TagController? _internalController;
  bool _isExpanded = false;

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
  void didUpdateWidget(covariant TagGroupWidget oldWidget) {
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

  void _onTagTapped(TagItem<dynamic> item) {
    widget.onTagTap?.call(item);
    if (_effectiveController.selectionMode != TagSelectionMode.none) {
      final changed = _effectiveController.toggleSelection(item.id);
      if (changed) {
        widget.onSelectionChanged?.call(_effectiveController.selectedTags);
      }
    }
  }

  void _onAllTapped() {
    if (_effectiveController.allSelected) {
      _effectiveController.clearSelection();
    } else {
      _effectiveController.selectAll();
    }
    widget.onSelectionChanged?.call(_effectiveController.selectedTags);
  }

  void _onTagDeleted(TagItem<dynamic> item) {
    _effectiveController.removeById(item.id);
    widget.onTagDeleted?.call(item);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = widget.style ?? TagStyle.modern();
    final allTags = _effectiveController.filteredTags;

    if (allTags.isEmpty && widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    final maxVisible = widget.maxVisibleTags;
    final hasOverflow = maxVisible != null && allTags.length > maxVisible;
    final visibleTags = (hasOverflow && !_isExpanded)
        ? allTags.take(maxVisible).toList()
        : allTags;
    final hiddenCount = allTags.length - visibleTags.length;

    final chipWidgets = <Widget>[];

    if (widget.showAllTag && allTags.isNotEmpty) {
      chipWidgets.add(
        TagWidget(
          key: const ValueKey<String>('__tag_group_all__'),
          label: widget.allTagLabel,
          count: allTags.length,
          selected: _effectiveController.allSelected,
          style: effectiveStyle,
          onTap: _onAllTapped,
        ),
      );
    }

    for (final item in visibleTags) {
      chipWidgets.add(
        TagWidget.fromItem(
          key: ValueKey<String>('tag_item_${item.id}'),
          item: item,
          style: effectiveStyle,
          onTap: () => _onTagTapped(item),
          onDeleted: (widget.deletable && item.deletable)
              ? () => _onTagDeleted(item)
              : null,
        ),
      );
    }

    if (hasOverflow) {
      final overflowLabel = _isExpanded
          ? widget.collapseLabel
          : (widget.expandLabelBuilder?.call(hiddenCount) ??
              '+$hiddenCount more');
      chipWidgets.add(
        TagWidget(
          key: const ValueKey<String>('__tag_group_overflow_toggle__'),
          label: overflowLabel,
          icon: _isExpanded
              ? Icons.unfold_less_rounded
              : Icons.more_horiz_rounded,
          style: effectiveStyle.copyWith(
            showSelectedCheckmark: false,
            borderColor: effectiveStyle.accentColor.withValues(alpha: 0.65),
          ),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
        ),
      );
    }

    Widget groupBody;
    switch (widget.layout) {
      case TagGroupLayout.wrap:
        groupBody = Wrap(
          spacing: widget.spacing,
          runSpacing: widget.runSpacing,
          alignment: widget.wrapAlignment,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: chipWidgets,
        );
      case TagGroupLayout.horizontalScroll:
        groupBody = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var i = 0; i < chipWidgets.length; i++) ...<Widget>[
                if (i > 0) SizedBox(width: widget.spacing),
                chipWidgets[i],
              ],
            ],
          ),
        );
    }

    if (widget.labelText == null && widget.helperText == null) {
      return groupBody;
    }

    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.labelText != null) ...<Widget>[
          Text(
            widget.labelText!,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8.0),
        ],
        groupBody,
        if (widget.helperText != null) ...<Widget>[
          const SizedBox(height: 6.0),
          Text(
            widget.helperText!,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
