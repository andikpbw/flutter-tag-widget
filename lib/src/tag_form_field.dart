import 'package:flutter/material.dart';

import 'tag_controller.dart';
import 'tag_input_widget.dart';
import 'tag_style.dart';
import 'tag_types.dart';

/// A [FormField] wrapper around [TagInputWidget] that integrates tag entry,
/// minimum/maximum tag constraints, and custom validation with Flutter's [Form].
class TagFormField extends FormField<List<TagItem<dynamic>>> {
  /// Creates a [TagFormField] backed by a [TagInputWidget].
  TagFormField({
    super.key,
    this.controller,
    List<TagItem<dynamic>>? initialValue,
    TagInputLayout layout = TagInputLayout.wrap,
    TagStyle? tagStyle,
    String hintText = 'Add a tag...',
    String? labelText,
    String? helperText,
    IconData? prefixIcon,
    List<String> delimiters = const <String>[',', ';', '\n'],
    List<String> suggestions = const <String>[],
    bool showSuggestionsWhenEmpty = false,
    bool confirmDeleteOnBackspace = true,
    bool submitOnFocusLost = true,
    bool showCounter = true,
    bool showClearAllButton = true,
    bool allowDuplicates = false,
    bool autoColorTags = false,
    TagCaseMode caseMode = TagCaseMode.preserve,
    String? tagPrefix,
    int? maxTags,
    int minTagLength = 1,
    int? maxTagLength,
    ValueChanged<List<TagItem<dynamic>>>? onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled = true,
    super.restorationId,
  }) : super(
          initialValue:
              controller?.tags ?? initialValue ?? const <TagItem<dynamic>>[],
          builder: (FormFieldState<List<TagItem<dynamic>>> field) {
            final state = field as _TagFormFieldState;
            return TagInputWidget(
              controller: state._effectiveController,
              layout: layout,
              tagStyle: tagStyle,
              hintText: hintText,
              labelText: labelText,
              helperText: helperText,
              errorText: field.errorText,
              prefixIcon: prefixIcon,
              delimiters: delimiters,
              suggestions: suggestions,
              showSuggestionsWhenEmpty: showSuggestionsWhenEmpty,
              confirmDeleteOnBackspace: confirmDeleteOnBackspace,
              submitOnFocusLost: submitOnFocusLost,
              showCounter: showCounter,
              showClearAllButton: showClearAllButton,
              enabled: enabled,
              allowDuplicates: allowDuplicates,
              autoColorTags: autoColorTags,
              caseMode: caseMode,
              tagPrefix: tagPrefix,
              maxTags: maxTags,
              minTagLength: minTagLength,
              maxTagLength: maxTagLength,
              onChanged: (tags) {
                field.didChange(tags);
                onChanged?.call(tags);
              },
            );
          },
        );

  /// Optional external [TagController] managing the tags in this form field.
  final TagController? controller;

  @override
  FormFieldState<List<TagItem<dynamic>>> createState() => _TagFormFieldState();
}

class _TagFormFieldState extends FormFieldState<List<TagItem<dynamic>>> {
  TagController? _internalController;

  TagFormField get _tagFormField => widget as TagFormField;

  TagController get _effectiveController =>
      _tagFormField.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (_tagFormField.controller == null) {
      _internalController = TagController(
        initialTags: widget.initialValue ?? const <TagItem<dynamic>>[],
      );
    }
    _effectiveController.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant TagFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_tagFormField.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChanged);
      _internalController?.removeListener(_handleControllerChanged);
      _internalController?.dispose();
      _internalController = null;

      if (_tagFormField.controller == null) {
        _internalController = TagController(
          initialTags: widget.initialValue ?? const <TagItem<dynamic>>[],
        );
      }
      _effectiveController.addListener(_handleControllerChanged);
    }
  }

  @override
  void dispose() {
    _tagFormField.controller?.removeListener(_handleControllerChanged);
    _internalController?.removeListener(_handleControllerChanged);
    _internalController?.dispose();
    super.dispose();
  }

  void _handleControllerChanged() {
    if (mounted && value != _effectiveController.tags) {
      didChange(_effectiveController.tags);
    }
  }

  @override
  void reset() {
    _effectiveController.reset();
    super.reset();
  }
}
