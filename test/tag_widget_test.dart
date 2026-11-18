import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tag_widget/tag_widget.dart';

void main() {
  group('TagItem & TagColorPalette', () {
    test('TagItem equality, copyWith, fromLabels, and effectiveBadge work', () {
      const item1 = TagItem<String>(
        label: 'Flutter',
        subtitle: 'SDK',
        count: 42,
        weight: 2.5,
        selected: true,
        data: 'payload',
      );
      const item2 = TagItem<String>(
        label: 'Flutter',
        subtitle: 'SDK',
        count: 42,
        weight: 2.5,
        selected: true,
        data: 'payload',
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
      expect(item1.effectiveBadge, '42');
      expect(item1.toString(), contains('Flutter'));

      final modified = item1.copyWith(
        badgeText: 'HOT',
        selected: false,
        clearSubtitle: true,
      );
      expect(modified.effectiveBadge, 'HOT');
      expect(modified.selected, isFalse);
      expect(modified.subtitle, isNull);

      final list = TagItem.fromLabels(
        const <String>['Dart', 'Flutter'],
        selected: true,
        autoColor: true,
      );
      expect(list.length, 2);
      expect(list.first.selected, isTrue);
      expect(list.first.color, isNotNull);
    });

    test('TagColorPalette deterministic color and case transformations work',
        () {
      final colorA = TagColorPalette.colorForLabel('Humanize AI');
      final colorB = TagColorPalette.colorForLabel('Humanize AI');
      expect(colorA, equals(colorB));

      final fallbackColor = TagColorPalette.colorForLabel(
        'Test',
        palette: const <Color>[],
      );
      expect(fallbackColor, const Color(0xFF6366F1));

      expect(
        TagColorPalette.applyCase('flutter DART', TagCaseMode.preserve),
        'flutter DART',
      );
      expect(
        TagColorPalette.applyCase('Flutter Dart', TagCaseMode.lowercase),
        'flutter dart',
      );
      expect(
        TagColorPalette.applyCase('Flutter Dart', TagCaseMode.uppercase),
        'FLUTTER DART',
      );
      expect(
        TagColorPalette.applyCase('flutter dart widget', TagCaseMode.titleCase),
        'Flutter Dart Widget',
      );
    });
  });

  group('TagStyle Presets & Resolution', () {
    test('All 6 TagStyle presets and size/shape helpers resolve properly', () {
      final modern = TagStyle.modern(size: TagSize.small, shape: TagShape.pill);
      final glass =
          TagStyle.glass(size: TagSize.medium, shape: TagShape.rounded);
      final neon = TagStyle.neon(
        size: TagSize.large,
        shape: TagShape.priceTag,
      );
      final gradient = TagStyle.gradient(shape: TagShape.ticket);
      final outlined = TagStyle.outlined(shape: TagShape.ribbon);
      final soft = TagStyle.soft(shape: TagShape.square);

      expect(modern.effectiveBorderRadius, 999.0);
      expect(modern.effectiveFontSize, 11.5);
      expect(glass.effectiveBorderRadius, 10.0);
      expect(neon.effectiveBorderRadius, 13.0);
      expect(neon.enableGlow, isTrue);
      expect(gradient.gradient, isNotNull);
      expect(outlined.backgroundColor, Colors.transparent);
      expect(soft.effectiveBorderRadius, 4.0);

      final resolvedNeon = neon.resolveForColor(const Color(0xFFFF0055));
      expect(resolvedNeon.accentColor, const Color(0xFFFF0055));

      final resolvedModern = modern.resolveForColor(const Color(0xFF10B981));
      expect(resolvedModern.selectedBackgroundColor, const Color(0xFF10B981));
    });
  });

  group('TagController CRUD, Validation & Selection', () {
    test('addLabel, prefix, caseMode, duplicate detection, and maxTags work',
        () {
      final controller = TagController(
        prefix: '#',
        caseMode: TagCaseMode.lowercase,
        maxTags: 3,
        minTagLength: 2,
        maxTagLength: 12,
        autoColorNewTags: true,
      );

      expect(controller.addLabel(' '), TagRejectionReason.empty);
      expect(controller.addLabel('a'), TagRejectionReason.tooShort);
      expect(
        controller.addLabel('verylongtagname'),
        TagRejectionReason.tooLong,
      );

      expect(controller.addLabel('Flutter'), isNull);
      expect(controller.labels, <String>['#flutter']);
      expect(controller.tags.first.color, isNotNull);

      // Duplicate test (case-insensitive by default)
      expect(controller.addLabel('#FLUTTER'), TagRejectionReason.duplicate);

      expect(controller.addLabel('Dart'), isNull);
      expect(controller.addLabel('AI'), isNull);
      expect(controller.hasReachedMax, isTrue);
      expect(controller.addLabel('Extra'), TagRejectionReason.maxTagsReached);
    });

    test('single and multiple selection, sorting, filtering, and reorder work',
        () {
      final controller = TagController.fromLabels(
        const <String>['Charlie', 'Alpha', 'Bravo'],
        maxSelected: 2,
      );

      expect(controller.toggleSelection('Alpha'), isTrue);
      expect(controller.toggleSelection('Bravo'), isTrue);
      // Max 2 selected reached
      expect(controller.toggleSelection('Charlie'), isFalse);
      expect(controller.selectedLabels, <String>['Alpha', 'Bravo']);

      controller.clearSelection();
      expect(controller.selectedTags, isEmpty);

      controller.sortAlphabetically();
      expect(controller.labels, <String>['Alpha', 'Bravo', 'Charlie']);

      controller.reorder(0, 2);
      expect(controller.labels, <String>['Bravo', 'Charlie', 'Alpha']);

      controller.setSearchQuery('br');
      expect(controller.filteredTags.length, 1);
      expect(controller.filteredTags.first.label, 'Bravo');

      controller.reset();
      expect(controller.labels, <String>['Charlie', 'Alpha', 'Bravo']);
      expect(controller.searchQuery, isEmpty);
    });

    test('single selection mode allows only one selected tag at a time', () {
      final controller = TagController.fromLabels(
        const <String>['One', 'Two', 'Three'],
        selectionMode: TagSelectionMode.single,
      );

      controller.setSelected('One', selected: true);
      expect(controller.selectedLabels, <String>['One']);

      controller.setSelected('Two', selected: true);
      expect(controller.selectedLabels, <String>['Two']);
    });
  });

  group('TagWidget & Custom Shapes', () {
    testWidgets('Renders all shapes, avatars, badges, selection, and delete',
        (tester) async {
      var tapped = false;
      var deleted = false;
      bool? selectedState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                for (final shape in TagShape.values)
                  TagWidget(
                    label: 'Shape ${shape.name}',
                    subtitle: 'Sub',
                    avatarText: 'AI',
                    count: 7,
                    selected: true,
                    deletable: true,
                    style: TagStyle.modern(shape: shape),
                    onTap: () => tapped = true,
                    onSelected: (val) => selectedState = val,
                    onDeleted: () => deleted = true,
                  ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Shape priceTag'), findsOneWidget);
      expect(find.text('Shape ticket'), findsOneWidget);
      expect(find.text('Shape ribbon'), findsOneWidget);

      await tester.tap(find.text('Shape pill'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
      expect(selectedState, isFalse);

      // Tap delete icon on the first TagWidget
      final deleteButton = find.bySemanticsLabel('Delete Shape pill');
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });
  });

  group('TagGroupWidget', () {
    testWidgets('Supports selection, "All" toggle chip, and "+N more" overflow',
        (tester) async {
      final controller = TagController.fromLabels(
        const <String>['Flutter', 'Dart', 'Firebase', 'SQLite', 'GraphQL'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagGroupWidget(
              controller: controller,
              labelText: 'Topics',
              helperText: 'Filter by topic',
              showAllTag: true,
              maxVisibleTags: 3,
            ),
          ),
        ),
      );

      // Should show 'All', first 3 tags, and '+2 more'
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Firebase'), findsOneWidget);
      expect(find.text('SQLite'), findsNothing);
      expect(find.text('+2 more'), findsOneWidget);

      // Expand overflow
      await tester.tap(find.text('+2 more'));
      await tester.pumpAndSettle();
      expect(find.text('SQLite'), findsOneWidget);
      expect(find.text('GraphQL'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);

      // Tap 'All' to select all tags
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(controller.allSelected, isTrue);
      expect(controller.selectedTags.length, 5);

      // Tap 'All' again to clear selection
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(controller.selectedTags, isEmpty);
    });
  });

  group('TagInputWidget', () {
    testWidgets(
        'Creates tags on delimiter, submit, suggestion tap, and deletes on Backspace',
        (tester) async {
      final controller = TagController(
        initialTags: TagItem.fromLabels(const <String>['Initial']),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagInputWidget(
              controller: controller,
              suggestions: const <String>['Flutter', 'Firebase', 'Figma'],
              showSuggestionsWhenEmpty: true,
            ),
          ),
        ),
      );

      expect(find.text('Initial'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);

      // Tap suggestion 'Flutter'
      await tester.tap(find.text('Flutter'));
      await tester.pumpAndSettle();
      expect(controller.labels, <String>['Initial', 'Flutter']);

      // Enter comma-separated multi-tag string into the TextField
      await tester.enterText(find.byType(TextField), 'Dart, Web, ');
      await tester.pumpAndSettle();
      expect(controller.labels, <String>['Initial', 'Flutter', 'Dart', 'Web']);

      // Focus the TextField (currently empty) and press Backspace twice
      // (first press highlights 'Web', second press deletes 'Web')
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(controller.labels.length, 4);

      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(controller.labels, <String>['Initial', 'Flutter', 'Dart']);
    });
  });

  group('TagCloudWidget & TagFormField', () {
    testWidgets('TagCloudWidget scales and toggles weighted tags',
        (tester) async {
      final controller = TagController(
        initialTags: const <TagItem<void>>[
          TagItem<void>(label: 'Low', weight: 10),
          TagItem<void>(label: 'High', weight: 100),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TagCloudWidget(
              controller: controller,
              labelText: 'Trending Cloud',
              colorMode: TagCloudColorMode.heat,
              showWeightAsCount: true,
            ),
          ),
        ),
      );

      expect(find.text('Trending Cloud'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);

      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();
      expect(controller.selectedLabels, <String>['High']);
    });

    testWidgets('TagFormField validates and saves properly', (tester) async {
      final formKey = GlobalKey<FormState>();
      List<TagItem<dynamic>>? savedTags;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: TagFormField(
                labelText: 'Skills',
                validator: (tags) => (tags == null || tags.length < 2)
                    ? 'Need at least 2 tags'
                    : null,
                onSaved: (tags) => savedTags = tags,
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Need at least 2 tags'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Flutter, Dart,');
      await tester.pumpAndSettle();

      expect(formKey.currentState!.validate(), isTrue);
      formKey.currentState!.save();
      expect(savedTags?.length, 2);
    });
  });
}
