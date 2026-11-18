import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tag_controller.dart';
import 'tag_style.dart';
import 'tag_types.dart';
import 'tag_widget_item.dart';

/// An interactive tag input field that converts typed text, delimiter characters
/// (`,`, `;`, `Enter`), pasted lists, and autocomplete suggestions into
/// styled [TagWidget] pills.
class TagInputWidget extends StatefulWidget {
  /// Creates a [TagInputWidget].
  const TagInputWidget({
    super.key,
    this.controller,
    this.initialTags = const <TagItem<dynamic>>[],
    this.layout = TagInputLayout.wrap,
    this.tagStyle,
    this.hintText = 'Add a tag...',
    this.labelText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.delimiters = const <String>[',', ';', '\n'],
    this.suggestions = const <String>[],
    this.showSuggestionsWhenEmpty = false,
    this.maxSuggestions = 6,
    this.confirmDeleteOnBackspace = true,
    this.submitOnFocusLost = false,
    this.showCounter = true,
    this.showClearAllButton = true,
    this.showAddButton = true,
    this.enabled = true,
    this.readOnly = false,
    this.allowDuplicates = false,
    this.autoColorTags = false,
    this.caseMode = TagCaseMode.preserve,
    this.tagPrefix,
    this.maxTags,
    this.minTagLength = 1,
    this.maxTagLength,
    this.spacing = 6.0,
    this.runSpacing = 6.0,
    this.containerBackgroundColor,
    this.containerBorderColor,
    this.focusedBorderColor,
    this.containerBorderRadius = 14.0,
    this.containerPadding = const EdgeInsets.symmetric(
      horizontal: 12.0,
      vertical: 10.0,
    ),
    this.inputTextStyle,
    this.onTagAdded,
    this.onTagRemoved,
    this.onChanged,
    this.onTagRejected,
  });

  /// Optional external [TagController] managing the tag list and validation rules.
  final TagController? controller;

  /// Initial tags used when [controller] is not provided.
  final List<TagItem<dynamic>> initialTags;

  /// Layout arrangement for the input field and created tags.
  final TagInputLayout layout;

  /// Visual theme applied to each created [TagWidget].
  final TagStyle? tagStyle;

  /// Placeholder hint text shown when the text input is empty.
  final String hintText;

  /// Optional header label rendered above the input container.
  final String? labelText;

  /// Optional helper caption rendered below the input container.
  final String? helperText;

  /// Optional validation error message rendered below the input container.
  final String? errorText;

  /// Optional leading icon rendered inside the input container.
  final IconData? prefixIcon;

  /// Delimiter strings that automatically trigger tag creation when typed or pasted.
  final List<String> delimiters;

  /// Optional list of autocomplete suggestion strings filtered as the user types.
  final List<String> suggestions;

  /// Whether to show available autocomplete suggestions even when the text input is empty.
  final bool showSuggestionsWhenEmpty;

  /// Maximum number of autocomplete suggestion chips displayed at once.
  final int maxSuggestions;

  /// Whether pressing Backspace on an empty input highlights the last tag first
  /// before deleting it on a second Backspace press.
  final bool confirmDeleteOnBackspace;

  /// Whether remaining text in the input is converted into a tag when focus is lost.
  final bool submitOnFocusLost;

  /// Whether to display a tag count badge (e.g. `3 / 10` or `3`).
  final bool showCounter;

  /// Whether to display a clear-all button when at least two tags exist.
  final bool showClearAllButton;

  /// Whether to show an inline `+` submit button when text is entered.
  final bool showAddButton;

  /// Whether the input field and tag deletions are enabled.
  final bool enabled;

  /// Whether the widget is read-only (tags cannot be added or deleted).
  final bool readOnly;

  /// Whether duplicate tag labels are permitted (used when creating an internal controller).
  final bool allowDuplicates;

  /// Whether newly created tags automatically receive a deterministic color from
  /// [TagColorPalette] (used when creating an internal controller).
  final bool autoColorTags;

  /// Character casing transformation for new tags (used when creating an internal controller).
  final TagCaseMode caseMode;

  /// Optional prefix automatically prepended to new tags, such as `'#'` or `'@'`.
  final String? tagPrefix;

  /// Optional maximum number of tags allowed (used when creating an internal controller).
  final int? maxTags;

  /// Minimum character length for a valid tag (used when creating an internal controller).
  final int minTagLength;

  /// Maximum character length for a valid tag (used when creating an internal controller).
  final int? maxTagLength;

  /// Horizontal spacing between tags.
  final double spacing;

  /// Vertical spacing between wrapped tag rows.
  final double runSpacing;

  /// Optional background color override for the input box container.
  final Color? containerBackgroundColor;

  /// Optional border color override for the input box container when unfocused.
  final Color? containerBorderColor;

  /// Optional border color override for the input box container when focused.
  final Color? focusedBorderColor;

  /// Corner radius of the outer input box container.
  final double containerBorderRadius;

  /// Inner padding of the outer input box container.
  final EdgeInsetsGeometry containerPadding;

  /// Optional custom [TextStyle] for the inline text field.
  final TextStyle? inputTextStyle;

  /// Callback invoked whenever a new tag is added.
  final ValueChanged<TagItem<dynamic>>? onTagAdded;

  /// Callback invoked whenever an existing tag is removed.
  final ValueChanged<TagItem<dynamic>>? onTagRemoved;

  /// Callback invoked with the current list of tags whenever tags are added, removed, or cleared.
  final ValueChanged<List<TagItem<dynamic>>>? onChanged;

  /// Callback invoked when a candidate tag string is rejected by validation rules.
  final void Function(String candidate, TagRejectionReason reason)?
      onTagRejected;

  @override
  State<TagInputWidget> createState() => _TagInputWidgetState();
}

class _TagInputWidgetState extends State<TagInputWidget> {
  TagController? _internalController;
  late final TextEditingController _textController;
  late final FocusNode _textFocusNode;

  String? _highlightedTagId;
  bool _isFocused = false;
  bool _isHandlingTextChange = false;

  TagController get _effectiveController =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = _createInternalController();
    }
    _effectiveController.addListener(_handleControllerChanged);
    _textController = TextEditingController();
    _textFocusNode = FocusNode(onKeyEvent: _handleKeyEvent)
      ..addListener(_handleFocusChanged);
  }

  TagController _createInternalController() {
    return TagController(
      initialTags: widget.initialTags,
      allowDuplicates: widget.allowDuplicates,
      caseMode: widget.caseMode,
      prefix: widget.tagPrefix,
      maxTags: widget.maxTags,
      minTagLength: widget.minTagLength,
      maxTagLength: widget.maxTagLength,
      autoColorNewTags: widget.autoColorTags,
    );
  }

  @override
  void didUpdateWidget(covariant TagInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _internalController?.removeListener(_handleControllerChanged);
      _internalController?.dispose();
      _internalController = null;

      if (widget.controller == null) {
        _internalController = _createInternalController();
      }
      _effectiveController.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    _internalController?.removeListener(_handleControllerChanged);
    _internalController?.dispose();
    _textFocusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (!mounted) return;
    if (_highlightedTagId != null &&
        !_effectiveController.tags.any((t) => t.id == _highlightedTagId)) {
      _highlightedTagId = null;
    }
    setState(() {});
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    final hasFocus = _textFocusNode.hasFocus;
    setState(() {
      _isFocused = hasFocus;
      if (!hasFocus) {
        _highlightedTagId = null;
      }
    });
    if (!hasFocus &&
        widget.submitOnFocusLost &&
        _textController.text.trim().isNotEmpty) {
      _submitText(_textController.text);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || widget.readOnly) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        _textController.text.isEmpty) {
      final tags = _effectiveController.tags;
      if (tags.isEmpty) return KeyEventResult.ignored;

      if (widget.confirmDeleteOnBackspace) {
        if (_highlightedTagId == null) {
          // Highlight the last deletable tag
          for (var i = tags.length - 1; i >= 0; i--) {
            if (tags[i].deletable && tags[i].enabled) {
              setState(() => _highlightedTagId = tags[i].id);
              return KeyEventResult.handled;
            }
          }
        } else {
          final targetId = _highlightedTagId!;
          _highlightedTagId = null;
          _deleteTagById(targetId);
          return KeyEventResult.handled;
        }
      } else {
        final removed = _effectiveController.removeLast();
        if (removed != null) {
          widget.onTagRemoved?.call(removed);
          widget.onChanged?.call(_effectiveController.tags);
          return KeyEventResult.handled;
        }
      }
    } else if (event.logicalKey == LogicalKeyboardKey.escape &&
        _highlightedTagId != null) {
      setState(() => _highlightedTagId = null);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _onTextChanged(String value) {
    if (_isHandlingTextChange) return;
    if (_highlightedTagId != null && value.isNotEmpty) {
      _highlightedTagId = null;
    }

    final matchedDelimiter = widget.delimiters.any(
      (d) => d.isNotEmpty && value.contains(d),
    );

    if (!matchedDelimiter) {
      setState(() {});
      return;
    }

    _isHandlingTextChange = true;
    try {
      final pattern = RegExp(
        widget.delimiters
            .where((d) => d.isNotEmpty)
            .map(RegExp.escape)
            .join('|'),
      );
      final parts = value.split(pattern);

      // All segments except the last one were followed by a delimiter
      for (var i = 0; i < parts.length - 1; i++) {
        final segment = parts[i].trim();
        if (segment.isNotEmpty) {
          _tryAddSingleLabel(segment);
        }
      }

      final remainder = parts.last.trimLeft();
      _textController.value = TextEditingValue(
        text: remainder,
        selection: TextSelection.collapsed(offset: remainder.length),
      );
    } finally {
      _isHandlingTextChange = false;
    }
    setState(() {});
  }

  void _submitText(String rawValue) {
    if (!widget.enabled || widget.readOnly) return;
    final trimmed = rawValue.trim();
    if (trimmed.isEmpty) return;

    final activeDelimiters =
        widget.delimiters.where((d) => d.isNotEmpty).toList();
    if (activeDelimiters.isNotEmpty) {
      final pattern = RegExp(activeDelimiters.map(RegExp.escape).join('|'));
      final parts = trimmed.split(pattern);
      var allAdded = true;
      for (final part in parts) {
        final candidate = part.trim();
        if (candidate.isEmpty) continue;
        final added = _tryAddSingleLabel(candidate);
        if (!added) allAdded = false;
      }
      if (allAdded) {
        _textController.clear();
      }
    } else {
      if (_tryAddSingleLabel(trimmed)) {
        _textController.clear();
      }
    }
    setState(() {});
  }

  bool _tryAddSingleLabel(String candidate) {
    final rejection = _effectiveController.addLabel(candidate);
    if (rejection != null) {
      if (rejection == TagRejectionReason.duplicate) {
        final normalized = _effectiveController.normalizeLabel(candidate);
        final existing =
            _effectiveController.tags.cast<TagItem<dynamic>?>().firstWhere(
                  (t) =>
                      t != null &&
                      t.label.toLowerCase() == normalized.toLowerCase(),
                  orElse: () => null,
                );
        if (existing != null) {
          setState(() => _highlightedTagId = existing.id);
        }
      }
      widget.onTagRejected?.call(candidate, rejection);
      return false;
    }

    _highlightedTagId = null;
    final addedItem = _effectiveController.tags.last;
    widget.onTagAdded?.call(addedItem);
    widget.onChanged?.call(_effectiveController.tags);
    return true;
  }

  void _deleteTagById(String id) {
    if (!widget.enabled || widget.readOnly) return;
    final index = _effectiveController.tags.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final removed = _effectiveController.removeAt(index);
    if (removed != null) {
      widget.onTagRemoved?.call(removed);
      widget.onChanged?.call(_effectiveController.tags);
    }
  }

  void _clearAllTags() {
    if (!widget.enabled || widget.readOnly) return;
    _effectiveController.clear();
    _highlightedTagId = null;
    widget.onChanged?.call(_effectiveController.tags);
  }

  List<String> _computeFilteredSuggestions() {
    if (widget.suggestions.isEmpty ||
        !widget.enabled ||
        widget.readOnly ||
        _effectiveController.hasReachedMax) {
      return const <String>[];
    }

    final query = _textController.text.trim().toLowerCase();
    if (query.isEmpty && !widget.showSuggestionsWhenEmpty) {
      return const <String>[];
    }

    final results = <String>[];
    for (final suggestion in widget.suggestions) {
      if (_effectiveController.containsLabel(suggestion)) continue;
      if (query.isEmpty || suggestion.toLowerCase().contains(query)) {
        results.add(suggestion);
        if (results.length >= widget.maxSuggestions) break;
      }
    }
    return results;
  }

  Widget _buildTagChip(TagItem<dynamic> item, TagStyle effectiveStyle) {
    return TagWidget.fromItem(
      key: ValueKey<String>('input_tag_${item.id}'),
      item: item,
      style: effectiveStyle,
      highlighted: _highlightedTagId == item.id,
      onTap: widget.enabled
          ? () {
              setState(() {
                _highlightedTagId =
                    _highlightedTagId == item.id ? null : item.id;
              });
            }
          : null,
      onDeleted: (widget.enabled && !widget.readOnly && item.deletable)
          ? () => _deleteTagById(item.id)
          : null,
    );
  }

  Widget _buildInlineTextField(TagStyle effectiveStyle) {
    final canAddMore = !_effectiveController.hasReachedMax && !widget.readOnly;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 90, maxWidth: 220),
      child: IntrinsicWidth(
        child: TextField(
          controller: _textController,
          focusNode: _textFocusNode,
          enabled: widget.enabled && canAddMore,
          readOnly: widget.readOnly,
          style: widget.inputTextStyle ??
              TextStyle(
                fontSize: effectiveStyle.effectiveFontSize,
                fontWeight: FontWeight.w500,
              ),
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4.0,
              vertical: 6.0,
            ),
            hintText: canAddMore ? widget.hintText : 'Max tags reached',
          ),
          textInputAction: TextInputAction.done,
          onChanged: _onTextChanged,
          onSubmitted: _submitText,
        ),
      ),
    );
  }

  Widget _buildTrailingControls(TagStyle effectiveStyle) {
    final tags = _effectiveController.tags;
    final maxTags = _effectiveController.maxTags;
    final hasText = _textController.text.trim().isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.showAddButton &&
            hasText &&
            widget.enabled &&
            !widget.readOnly)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Semantics(
              button: true,
              label: 'Add tag',
              child: GestureDetector(
                onTap: () => _submitText(_textController.text),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: effectiveStyle.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 15.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        if (widget.showClearAllButton &&
            tags.length >= 2 &&
            widget.enabled &&
            !widget.readOnly)
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: Semantics(
              button: true,
              label: 'Clear all tags',
              child: GestureDetector(
                onTap: _clearAllTags,
                child: Icon(
                  Icons.clear_all_rounded,
                  size: 18.0,
                  color: effectiveStyle.accentColor.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),
        if (widget.showCounter && (tags.isNotEmpty || maxTags != null))
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 7.0,
                vertical: 2.5,
              ),
              decoration: BoxDecoration(
                color: effectiveStyle.accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                maxTags != null
                    ? '${tags.length} / $maxTags'
                    : '${tags.length}',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.w700,
                  color: effectiveStyle.accentColor,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveStyle = widget.tagStyle ?? TagStyle.modern();
    final tags = _effectiveController.tags;

    final hasError =
        widget.errorText != null && widget.errorText!.trim().isNotEmpty;

    final boxBg = widget.containerBackgroundColor ??
        (effectiveStyle.enableGlow
            ? const Color(0xFF090D16)
            : (isDark ? const Color(0xFF1E293B) : Colors.white));

    final defaultBorder = widget.containerBorderColor ??
        (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1));

    final activeBorderColor = hasError
        ? theme.colorScheme.error
        : (_isFocused
            ? (widget.focusedBorderColor ?? effectiveStyle.accentColor)
            : defaultBorder);

    Widget inputArea;
    switch (widget.layout) {
      case TagInputLayout.wrap:
        inputArea = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.enabled ? () => _textFocusNode.requestFocus() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: widget.containerPadding,
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: BorderRadius.circular(widget.containerBorderRadius),
              border: Border.all(
                color: activeBorderColor,
                width: _isFocused || hasError ? 1.6 : 1.2,
              ),
              boxShadow: _isFocused
                  ? <BoxShadow>[
                      BoxShadow(
                        color: activeBorderColor.withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (widget.prefixIcon != null) ...<Widget>[
                  Icon(
                    widget.prefixIcon,
                    size: 19.0,
                    color: _isFocused
                        ? effectiveStyle.accentColor
                        : theme.hintColor,
                  ),
                  const SizedBox(width: 8.0),
                ],
                Expanded(
                  child: Wrap(
                    spacing: widget.spacing,
                    runSpacing: widget.runSpacing,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      for (final item in tags)
                        _buildTagChip(item, effectiveStyle),
                      _buildInlineTextField(effectiveStyle),
                    ],
                  ),
                ),
                _buildTrailingControls(effectiveStyle),
              ],
            ),
          ),
        );

      case TagInputLayout.scrollableHorizontal:
        inputArea = GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.enabled ? () => _textFocusNode.requestFocus() : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: widget.containerPadding,
            decoration: BoxDecoration(
              color: boxBg,
              borderRadius: BorderRadius.circular(widget.containerBorderRadius),
              border: Border.all(
                color: activeBorderColor,
                width: _isFocused || hasError ? 1.6 : 1.2,
              ),
            ),
            child: Row(
              children: <Widget>[
                if (widget.prefixIcon != null) ...<Widget>[
                  Icon(
                    widget.prefixIcon,
                    size: 19.0,
                    color: _isFocused
                        ? effectiveStyle.accentColor
                        : theme.hintColor,
                  ),
                  const SizedBox(width: 8.0),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final item in tags) ...<Widget>[
                          _buildTagChip(item, effectiveStyle),
                          SizedBox(width: widget.spacing),
                        ],
                        _buildInlineTextField(effectiveStyle),
                      ],
                    ),
                  ),
                ),
                _buildTrailingControls(effectiveStyle),
              ],
            ),
          ),
        );

      case TagInputLayout.stacked:
        inputArea = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: widget.containerPadding,
              decoration: BoxDecoration(
                color: boxBg,
                borderRadius:
                    BorderRadius.circular(widget.containerBorderRadius),
                border: Border.all(
                  color: activeBorderColor,
                  width: _isFocused || hasError ? 1.6 : 1.2,
                ),
              ),
              child: Row(
                children: <Widget>[
                  if (widget.prefixIcon != null) ...<Widget>[
                    Icon(
                      widget.prefixIcon,
                      size: 19.0,
                      color: _isFocused
                          ? effectiveStyle.accentColor
                          : theme.hintColor,
                    ),
                    const SizedBox(width: 8.0),
                  ],
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      focusNode: _textFocusNode,
                      enabled: widget.enabled &&
                          !_effectiveController.hasReachedMax &&
                          !widget.readOnly,
                      readOnly: widget.readOnly,
                      style: widget.inputTextStyle ??
                          TextStyle(
                            fontSize: effectiveStyle.effectiveFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4.0,
                          vertical: 4.0,
                        ),
                        hintText: !_effectiveController.hasReachedMax
                            ? widget.hintText
                            : 'Max tags reached',
                      ),
                      textInputAction: TextInputAction.done,
                      onChanged: _onTextChanged,
                      onSubmitted: _submitText,
                    ),
                  ),
                  _buildTrailingControls(effectiveStyle),
                ],
              ),
            ),
            if (tags.isNotEmpty) ...<Widget>[
              const SizedBox(height: 10.0),
              Wrap(
                spacing: widget.spacing,
                runSpacing: widget.runSpacing,
                children: <Widget>[
                  for (final item in tags) _buildTagChip(item, effectiveStyle),
                ],
              ),
            ],
          ],
        );
    }

    final matchingSuggestions = _computeFilteredSuggestions();

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
          const SizedBox(height: 6.0),
        ],
        inputArea,
        if (matchingSuggestions.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: <Widget>[
              for (final suggestion in matchingSuggestions)
                TagWidget(
                  key: ValueKey<String>('suggestion_$suggestion'),
                  label: suggestion,
                  icon: Icons.add_rounded,
                  style: effectiveStyle.copyWith(
                    size: TagSize.small,
                    showSelectedCheckmark: false,
                  ),
                  onTap: () {
                    if (_tryAddSingleLabel(suggestion)) {
                      _textController.clear();
                      setState(() {});
                    }
                  },
                ),
            ],
          ),
        ],
        if (hasError) ...<Widget>[
          const SizedBox(height: 6.0),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else if (widget.helperText != null) ...<Widget>[
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
