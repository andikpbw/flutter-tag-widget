import 'package:flutter/material.dart';

import 'tag_types.dart';

/// Programmatic controller for managing a collection of [TagItem]s, their
/// selection states, validation constraints, filtering, and ordering.
class TagController extends ChangeNotifier {
  /// Creates a [TagController] with optional [initialTags] and validation rules.
  TagController({
    Iterable<TagItem<dynamic>> initialTags = const <TagItem<dynamic>>[],
    this.selectionMode = TagSelectionMode.multiple,
    this.allowDuplicates = false,
    this.caseSensitiveDuplicates = false,
    this.caseMode = TagCaseMode.preserve,
    this.prefix,
    this.maxTags,
    this.maxSelected,
    this.minTagLength = 1,
    this.maxTagLength,
    this.autoColorNewTags = false,
    this.customValidator,
  })  : assert(minTagLength >= 0, 'minTagLength must be non-negative'),
        assert(
          maxTags == null || maxTags > 0,
          'maxTags must be greater than zero when provided',
        ),
        _initialTags = List<TagItem<dynamic>>.unmodifiable(initialTags),
        _tags = List<TagItem<dynamic>>.of(initialTags);

  /// Creates a [TagController] initialized from a list of string [labels].
  factory TagController.fromLabels(
    Iterable<String> labels, {
    TagSelectionMode selectionMode = TagSelectionMode.multiple,
    bool allowDuplicates = false,
    bool caseSensitiveDuplicates = false,
    TagCaseMode caseMode = TagCaseMode.preserve,
    String? prefix,
    int? maxTags,
    int? maxSelected,
    int minTagLength = 1,
    int? maxTagLength,
    bool autoColor = false,
    bool initialSelected = false,
  }) {
    final items = TagItem.fromLabels(
      labels,
      selected: initialSelected,
      autoColor: autoColor,
    );
    return TagController(
      initialTags: items,
      selectionMode: selectionMode,
      allowDuplicates: allowDuplicates,
      caseSensitiveDuplicates: caseSensitiveDuplicates,
      caseMode: caseMode,
      prefix: prefix,
      maxTags: maxTags,
      maxSelected: maxSelected,
      minTagLength: minTagLength,
      maxTagLength: maxTagLength,
      autoColorNewTags: autoColor,
    );
  }

  final List<TagItem<dynamic>> _initialTags;
  final List<TagItem<dynamic>> _tags;
  String _searchQuery = '';

  /// Selection behavior enforced when [toggleSelection] or [setSelected] is called.
  final TagSelectionMode selectionMode;

  /// Whether multiple tags with the same label are allowed.
  final bool allowDuplicates;

  /// Whether duplicate label detection is case-sensitive.
  final bool caseSensitiveDuplicates;

  /// Character casing transformation applied to newly added tag labels.
  final TagCaseMode caseMode;

  /// Optional prefix automatically prepended to new tag labels (e.g. `'#'` or `'@'`).
  final String? prefix;

  /// Maximum total number of tags allowed in this controller.
  final int? maxTags;

  /// Maximum number of tags that can be selected simultaneously in
  /// [TagSelectionMode.multiple].
  final int? maxSelected;

  /// Minimum character length (excluding [prefix]) for a valid tag label.
  final int minTagLength;

  /// Optional maximum character length for a valid tag label.
  final int? maxTagLength;

  /// Whether newly added string labels automatically receive a deterministic
  /// color from [TagColorPalette].
  final bool autoColorNewTags;

  /// Optional custom validation callback returning `true` when a label is valid.
  final bool Function(String candidate)? customValidator;

  /// Unmodifiable list of all tags currently managed by this controller.
  List<TagItem<dynamic>> get tags => List<TagItem<dynamic>>.unmodifiable(_tags);

  /// Unmodifiable list of tags currently marked as selected.
  List<TagItem<dynamic>> get selectedTags =>
      List<TagItem<dynamic>>.unmodifiable(
        _tags.where((tag) => tag.selected),
      );

  /// Unmodifiable list of tags currently unselected.
  List<TagItem<dynamic>> get unselectedTags =>
      List<TagItem<dynamic>>.unmodifiable(
        _tags.where((tag) => !tag.selected),
      );

  /// All tag labels in their current order.
  List<String> get labels =>
      List<String>.unmodifiable(_tags.map((tag) => tag.label));

  /// Labels of all currently selected tags.
  List<String> get selectedLabels => List<String>.unmodifiable(
        _tags.where((tag) => tag.selected).map((tag) => tag.label),
      );

  /// Total number of tags in the controller.
  int get length => _tags.length;

  /// Whether the controller contains zero tags.
  bool get isEmpty => _tags.isEmpty;

  /// Whether the controller contains at least one tag.
  bool get isNotEmpty => _tags.isNotEmpty;

  /// Whether the tag count has reached [maxTags].
  bool get hasReachedMax => maxTags != null && _tags.length >= maxTags!;

  /// Whether every enabled tag in the controller is currently selected.
  bool get allSelected {
    final enabledTags = _tags.where((t) => t.enabled).toList();
    if (enabledTags.isEmpty) return false;
    return enabledTags.every((t) => t.selected);
  }

  /// Active search query used by [filteredTags].
  String get searchQuery => _searchQuery;

  /// Tags matching the active [searchQuery] (or all tags when [searchQuery] is empty).
  List<TagItem<dynamic>> get filteredTags {
    if (_searchQuery.trim().isEmpty) return tags;
    final q = _searchQuery.trim().toLowerCase();
    return List<TagItem<dynamic>>.unmodifiable(
      _tags.where(
        (tag) =>
            tag.label.toLowerCase().contains(q) ||
            (tag.subtitle?.toLowerCase().contains(q) ?? false),
      ),
    );
  }

  /// Normalizes [rawLabel] by trimming whitespace, applying [caseMode], and
  /// ensuring [prefix] is prepended when configured.
  String normalizeLabel(String rawLabel) {
    var cleaned = rawLabel.trim();
    if (cleaned.isEmpty) return '';

    final activePrefix = prefix;
    if (activePrefix != null && activePrefix.isNotEmpty) {
      if (cleaned.startsWith(activePrefix)) {
        cleaned = cleaned.substring(activePrefix.length).trim();
      }
      if (cleaned.isEmpty) return '';
      cleaned = TagColorPalette.applyCase(cleaned, caseMode);
      return '$activePrefix$cleaned';
    }

    return TagColorPalette.applyCase(cleaned, caseMode);
  }

  /// Checks whether [label] already exists in the controller.
  bool containsLabel(String label) {
    final normalized = normalizeLabel(label);
    if (normalized.isEmpty) return false;
    return _tags.any((tag) {
      if (caseSensitiveDuplicates) {
        return tag.label == normalized;
      }
      return tag.label.toLowerCase() == normalized.toLowerCase();
    });
  }

  /// Validates a candidate [rawLabel] and returns `null` if valid, or a
  /// [TagRejectionReason] describing why it cannot be added.
  TagRejectionReason? validateCandidate(String rawLabel) {
    final normalized = normalizeLabel(rawLabel);
    if (normalized.isEmpty) {
      return TagRejectionReason.empty;
    }
    if (hasReachedMax) {
      return TagRejectionReason.maxTagsReached;
    }

    final coreLength = (prefix != null && normalized.startsWith(prefix!))
        ? normalized.length - prefix!.length
        : normalized.length;

    if (coreLength < minTagLength) {
      return TagRejectionReason.tooShort;
    }
    if (maxTagLength != null && normalized.length > maxTagLength!) {
      return TagRejectionReason.tooLong;
    }
    if (!allowDuplicates && containsLabel(normalized)) {
      return TagRejectionReason.duplicate;
    }
    if (customValidator != null && !customValidator!(normalized)) {
      return TagRejectionReason.customValidationFailed;
    }
    return null;
  }

  /// Validates and adds a new tag from [rawLabel].
  ///
  /// Returns `null` when the tag was added, or a [TagRejectionReason] if rejected.
  TagRejectionReason? addLabel(
    String rawLabel, {
    Color? color,
    IconData? icon,
    String? subtitle,
    int? count,
    String? badgeText,
    double weight = 1.0,
    bool selected = false,
  }) {
    final rejection = validateCandidate(rawLabel);
    if (rejection != null) return rejection;

    final normalized = normalizeLabel(rawLabel);
    final effectiveColor = color ??
        (autoColorNewTags ? TagColorPalette.colorForLabel(normalized) : null);

    _tags.add(
      TagItem<dynamic>(
        label: normalized,
        subtitle: subtitle,
        icon: icon,
        count: count,
        badgeText: badgeText,
        color: effectiveColor,
        weight: weight,
        selected: selected,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Validates and adds a [TagItem] to the controller.
  ///
  /// Returns `null` when added, or a [TagRejectionReason] if rejected.
  TagRejectionReason? addTag(TagItem<dynamic> item) {
    final rejection = validateCandidate(item.label);
    if (rejection != null) return rejection;

    final normalized = normalizeLabel(item.label);
    final effectiveColor = item.color ??
        (autoColorNewTags ? TagColorPalette.colorForLabel(normalized) : null);

    _tags.add(
      item.copyWith(
        label: normalized,
        color: effectiveColor,
      ),
    );
    notifyListeners();
    return null;
  }

  /// Adds multiple string [rawLabels], skipping any invalid or duplicate entries.
  ///
  /// Returns the number of tags that were added.
  int addLabels(
    Iterable<String> rawLabels, {
    bool selected = false,
  }) {
    var addedCount = 0;
    for (final raw in rawLabels) {
      final rejection = validateCandidate(raw);
      if (rejection == null) {
        final normalized = normalizeLabel(raw);
        final effectiveColor =
            autoColorNewTags ? TagColorPalette.colorForLabel(normalized) : null;
        _tags.add(
          TagItem<dynamic>(
            label: normalized,
            color: effectiveColor,
            selected: selected,
          ),
        );
        addedCount++;
      }
    }
    if (addedCount > 0) {
      notifyListeners();
    }
    return addedCount;
  }

  /// Adds multiple [TagItem]s, skipping any invalid or duplicate entries.
  ///
  /// Returns the number of tags that were added.
  int addTags(Iterable<TagItem<dynamic>> items) {
    var addedCount = 0;
    for (final item in items) {
      final rejection = validateCandidate(item.label);
      if (rejection == null) {
        final normalized = normalizeLabel(item.label);
        final effectiveColor = item.color ??
            (autoColorNewTags
                ? TagColorPalette.colorForLabel(normalized)
                : null);
        _tags.add(
          item.copyWith(
            label: normalized,
            color: effectiveColor,
          ),
        );
        addedCount++;
      }
    }
    if (addedCount > 0) {
      notifyListeners();
    }
    return addedCount;
  }

  /// Removes the tag matching [id]. Returns `true` if a tag was removed.
  bool removeById(String id) {
    final index = _tags.indexWhere((tag) => tag.id == id);
    if (index == -1) return false;
    _tags.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Removes the first tag matching [label]. Returns `true` if a tag was removed.
  bool removeByLabel(String label) {
    final index = _tags.indexWhere(
      (tag) => caseSensitiveDuplicates
          ? tag.label == label
          : tag.label.toLowerCase() == label.toLowerCase(),
    );
    if (index == -1) return false;
    _tags.removeAt(index);
    notifyListeners();
    return true;
  }

  /// Removes and returns the tag at [index], or `null` if out of range.
  TagItem<dynamic>? removeAt(int index) {
    if (index < 0 || index >= _tags.length) return null;
    final removed = _tags.removeAt(index);
    notifyListeners();
    return removed;
  }

  /// Removes and returns the last deletable tag, or `null` if none exists.
  TagItem<dynamic>? removeLast({bool onlyDeletable = true}) {
    if (_tags.isEmpty) return null;
    for (var i = _tags.length - 1; i >= 0; i--) {
      if (!onlyDeletable || (_tags[i].deletable && _tags[i].enabled)) {
        final removed = _tags.removeAt(i);
        notifyListeners();
        return removed;
      }
    }
    return null;
  }

  /// Replaces the tag matching [id] with [updated]. Returns `true` if updated.
  bool updateTag(String id, TagItem<dynamic> updated) {
    final index = _tags.indexWhere((tag) => tag.id == id);
    if (index == -1) return false;
    _tags[index] = updated;
    notifyListeners();
    return true;
  }

  /// Toggles the selection state of the tag with [id] according to [selectionMode].
  ///
  /// Returns `true` if the selection state changed.
  bool toggleSelection(String id) {
    if (selectionMode == TagSelectionMode.none) return false;
    final index = _tags.indexWhere((tag) => tag.id == id);
    if (index == -1 || !_tags[index].enabled) return false;

    final target = _tags[index];
    return setSelected(id, selected: !target.selected);
  }

  /// Explicitly sets the selection state of the tag with [id].
  ///
  /// Returns `true` if the selection state changed.
  bool setSelected(String id, {required bool selected}) {
    if (selectionMode == TagSelectionMode.none) return false;
    final index = _tags.indexWhere((tag) => tag.id == id);
    if (index == -1 || !_tags[index].enabled) return false;

    final current = _tags[index];
    if (current.selected == selected) return false;

    if (selectionMode == TagSelectionMode.single) {
      for (var i = 0; i < _tags.length; i++) {
        if (i == index) {
          _tags[i] = _tags[i].copyWith(selected: selected);
        } else if (selected && _tags[i].selected) {
          _tags[i] = _tags[i].copyWith(selected: false);
        }
      }
      notifyListeners();
      return true;
    }

    // Multiple selection mode
    if (selected && maxSelected != null) {
      final currentSelectedCount = _tags.where((t) => t.selected).length;
      if (currentSelectedCount >= maxSelected!) {
        return false;
      }
    }

    _tags[index] = current.copyWith(selected: selected);
    notifyListeners();
    return true;
  }

  /// Selects all enabled tags (respecting [maxSelected] and [selectionMode]).
  void selectAll() {
    if (selectionMode == TagSelectionMode.none || _tags.isEmpty) return;
    if (selectionMode == TagSelectionMode.single) {
      final firstEnabled = _tags.indexWhere((t) => t.enabled);
      if (firstEnabled != -1) {
        setSelected(_tags[firstEnabled].id, selected: true);
      }
      return;
    }

    var changed = false;
    var selectedCount = _tags.where((t) => t.selected).length;
    for (var i = 0; i < _tags.length; i++) {
      if (!_tags[i].enabled || _tags[i].selected) continue;
      if (maxSelected != null && selectedCount >= maxSelected!) break;
      _tags[i] = _tags[i].copyWith(selected: true);
      selectedCount++;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Clears the selection state on all tags.
  void clearSelection() {
    var changed = false;
    for (var i = 0; i < _tags.length; i++) {
      if (_tags[i].selected) {
        _tags[i] = _tags[i].copyWith(selected: false);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Replaces the entire tag list with [items].
  void setTags(Iterable<TagItem<dynamic>> items) {
    _tags
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  /// Removes all tags from the controller.
  void clear() {
    if (_tags.isEmpty) return;
    _tags.clear();
    notifyListeners();
  }

  /// Moves a tag from [oldIndex] to [newIndex].
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _tags.length ||
        newIndex < 0 ||
        newIndex >= _tags.length ||
        oldIndex == newIndex) {
      return;
    }
    final item = _tags.removeAt(oldIndex);
    _tags.insert(newIndex, item);
    notifyListeners();
  }

  /// Sorts all tags alphabetically by their [TagItem.label].
  void sortAlphabetically({bool ascending = true}) {
    if (_tags.length < 2) return;
    _tags.sort((a, b) {
      final cmp = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return ascending ? cmp : -cmp;
    });
    notifyListeners();
  }

  /// Sorts all tags by their [TagItem.weight].
  void sortByWeight({bool descending = true}) {
    if (_tags.length < 2) return;
    _tags.sort((a, b) {
      final cmp = a.weight.compareTo(b.weight);
      return descending ? -cmp : cmp;
    });
    notifyListeners();
  }

  /// Updates the active [searchQuery] used to filter [filteredTags].
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Resets the controller back to its [initialTags] state.
  void reset() {
    _tags
      ..clear()
      ..addAll(_initialTags);
    _searchQuery = '';
    notifyListeners();
  }
}
