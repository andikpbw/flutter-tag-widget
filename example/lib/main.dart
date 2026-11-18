import 'package:flutter/material.dart';
import 'package:tag_widget/tag_widget.dart';

void main() {
  runApp(const TagWidgetShowcaseApp());
}

/// Root showcase application demonstrating the features of `tag_widget`.
class TagWidgetShowcaseApp extends StatelessWidget {
  /// Creates a [TagWidgetShowcaseApp].
  const TagWidgetShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'tag_widget Showcase',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6366F1),
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
      ),
      home: const TagWidgetShowcaseScreen(),
    );
  }
}

/// Main interactive screen demonstrating [TagWidget], [TagInputWidget],
/// [TagGroupWidget], [TagCloudWidget], and [TagFormField].
class TagWidgetShowcaseScreen extends StatefulWidget {
  /// Creates a [TagWidgetShowcaseScreen].
  const TagWidgetShowcaseScreen({super.key});

  @override
  State<TagWidgetShowcaseScreen> createState() =>
      _TagWidgetShowcaseScreenState();
}

class _TagWidgetShowcaseScreenState extends State<TagWidgetShowcaseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TagController _inputController;
  late final TagController _filterController;
  late final TagController _cloudController;

  @override
  void initState() {
    super.initState();
    _inputController = TagController(
      initialTags: const <TagItem<void>>[
        TagItem<void>(
          label: '#flutter',
          icon: Icons.flutter_dash,
          color: Color(0xFF38BDF8),
        ),
        TagItem<void>(
          label: '#dart',
          icon: Icons.code_rounded,
          color: Color(0xFF6366F1),
        ),
        TagItem<void>(
          label: '#humanize-ai',
          badgeText: 'PRO',
          color: Color(0xFFA855F7),
        ),
      ],
      prefix: '#',
      caseMode: TagCaseMode.lowercase,
      maxTags: 8,
      autoColorNewTags: true,
    );

    _filterController = TagController(
      initialTags: const <TagItem<void>>[
        TagItem<void>(
          label: 'Mobile UI',
          count: 42,
          selected: true,
          icon: Icons.phone_iphone_rounded,
        ),
        TagItem<void>(
          label: 'AI & LLM',
          count: 128,
          selected: true,
          icon: Icons.auto_awesome_rounded,
        ),
        TagItem<void>(
          label: 'Design System',
          count: 35,
          icon: Icons.palette_outlined,
        ),
        TagItem<void>(
          label: 'Open Source',
          count: 89,
          icon: Icons.public_rounded,
        ),
        TagItem<void>(
          label: 'WebAssembly',
          count: 19,
        ),
        TagItem<void>(
          label: 'Animations',
          count: 64,
        ),
        TagItem<void>(
          label: 'Performance',
          count: 27,
        ),
      ],
    );

    _cloudController = TagController(
      initialTags: const <TagItem<void>>[
        TagItem<void>(label: 'Humanize AI', weight: 98, selected: true),
        TagItem<void>(label: 'Flutter 3', weight: 92),
        TagItem<void>(label: 'Dart 3', weight: 84),
        TagItem<void>(label: 'CustomPainter', weight: 70),
        TagItem<void>(label: 'Tag Input', weight: 78, selected: true),
        TagItem<void>(label: 'Material 3', weight: 65),
        TagItem<void>(label: 'Glassmorphism', weight: 58),
        TagItem<void>(label: 'Neon Cyber', weight: 50),
        TagItem<void>(label: 'Price Tag', weight: 72),
        TagItem<void>(label: 'Cross-Platform', weight: 62),
      ],
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _filterController.dispose();
    _cloudController.dispose();
    super.dispose();
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131B2E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF26324D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text(
          'tag_widget • Interactive Showcase',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildSectionCard(
              title: '1. Interactive Tag Input & Live Autocomplete',
              subtitle:
                  'Type a hashtag and press Enter, comma, or tap a suggestion below. Press Backspace on empty input to highlight & remove.',
              child: TagInputWidget(
                controller: _inputController,
                hintText: 'Type topic or comma...',
                prefixIcon: Icons.tag_rounded,
                tagStyle: TagStyle.glass(),
                showSuggestionsWhenEmpty: true,
                suggestions: const <String>[
                  '#widget',
                  '#pubdev',
                  '#opensource',
                  '#material3',
                  '#crossplatform',
                  '#animation',
                ],
              ),
            ),
            _buildSectionCard(
              title: '2. Physical Price-Tag, Ticket, Ribbon & 6 Theme Presets',
              subtitle:
                  'Custom vector silhouettes and ready-to-use Modern, Glass, Neon, Gradient, Outlined, and Soft presets.',
              child: Wrap(
                spacing: 10,
                runSpacing: 12,
                children: <Widget>[
                  TagWidget(
                    label: r'Flash Sale • $29',
                    badgeText: '-40%',
                    selected: true,
                    style: TagStyle.gradient(
                      startColor: const Color(0xFFF43F5E),
                      endColor: const Color(0xFFF59E0B),
                      shape: TagShape.priceTag,
                      showSelectedCheckmark: false,
                    ),
                    onTap: () {},
                  ),
                  TagWidget(
                    label: 'VIP Pass 2026',
                    icon: Icons.confirmation_num_outlined,
                    selected: true,
                    style: TagStyle.neon(
                      accentColor: const Color(0xFF00F5D4),
                      shape: TagShape.ticket,
                      showSelectedCheckmark: false,
                    ),
                    onTap: () {},
                  ),
                  TagWidget(
                    label: 'Featured Story',
                    icon: Icons.bookmark_added_rounded,
                    selected: true,
                    style: TagStyle.modern(
                      accentColor: const Color(0xFF8B5CF6),
                      shape: TagShape.ribbon,
                      showSelectedCheckmark: false,
                    ),
                    onTap: () {},
                  ),
                  TagWidget(
                    label: 'Glass Pill',
                    avatarText: 'AI',
                    count: 99,
                    selected: true,
                    style: TagStyle.glass(
                      accentColor: const Color(0xFF38BDF8),
                    ),
                    onTap: () {},
                  ),
                  TagWidget(
                    label: 'Outlined Badge',
                    icon: Icons.verified_outlined,
                    style: TagStyle.outlined(
                      accentColor: const Color(0xFF4ADE80),
                    ),
                    onTap: () {},
                  ),
                  TagWidget(
                    label: 'Soft Tactile',
                    count: 12,
                    style: TagStyle.soft(),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            _buildSectionCard(
              title: '3. Filter Tag Group with "All" & "+N more" Overflow',
              subtitle:
                  'Multi-select filter chips with automatic count badges and expandable overflow.',
              child: TagGroupWidget(
                controller: _filterController,
                showAllTag: true,
                maxVisibleTags: 4,
                style: TagStyle.glass(
                  accentColor: const Color(0xFF6366F1),
                ),
              ),
            ),
            _buildSectionCard(
              title: '4. Weighted Interactive Tag Cloud',
              subtitle:
                  'Dynamic scale and heat/palette coloring based on each tag\'s popularity weight.',
              child: TagCloudWidget(
                controller: _cloudController,
                colorMode: TagCloudColorMode.heat,
                showWeightAsCount: true,
                style: TagStyle.neon(),
              ),
            ),
            _buildSectionCard(
              title: '5. Form Validation (TagFormField)',
              subtitle: 'Integrates directly with Flutter Form validation.',
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TagFormField(
                      labelText: 'Required Project Skills (Min 2 tags)',
                      initialValue: TagItem.fromLabels(
                        const <String>['Flutter'],
                        autoColor: true,
                      ),
                      tagStyle: TagStyle.modern(),
                      validator: (tags) {
                        if (tags == null || tags.length < 2) {
                          return 'Please add at least 2 project skill tags.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        _formKey.currentState?.validate();
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Validate Form'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
