import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class JanazaPrayerScreen extends StatefulWidget {
  const JanazaPrayerScreen({super.key});

  @override
  State<JanazaPrayerScreen> createState() => _JanazaPrayerScreenState();
}

class _JanazaPrayerScreenState extends State<JanazaPrayerScreen> {
  bool _isSecondTakbirExpanded = false;
  bool _isThirdTakbirExpanded = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.selectedTheme;

    return Scaffold(
      backgroundColor: theme.lightBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Janaza Prayer Guide',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.lightBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSection(
                title: 'Basic Rules',
                content:
                    '📌 Essential Rules of the Janazah Prayer (Funeral Prayer).\n\n'
                    'The prayer is performed while standing, without bowing (ruku\') or prostration (sujood). '
                    'It consists of four takbirs (saying \'Allahu Akbar\').',
              ),
              const Divider(),
              _buildTakbirSection(
                title: '1. First Takbir',
                content:
                    'Raise your hands to the level of your shoulders or ears and say:\n\n'
                    'اللَّهُ أَكْبَرُ\n'
                    'Allahu Akbar (\'Allah is the Greatest\')\n\n'
                    'Then: Recite Surah Al-Fatihah.',
              ),
              const Divider(),
              _buildTakbirSection(
                title: '2. Second Takbir',
                content:
                    'Say the takbir (without raising the hands):\n\n'
                    'اللَّهُ أَكْبَرُ - Allahu Akbar\n\n'
                    'Then recite Salawat upon the Prophet ﷺ:'
                    '\n\nاللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَعَلَىٰ آلِ مُحَمَّدٍ...',
                isExpandable: true,
                isExpanded: _isSecondTakbirExpanded,
                expandedContent: 'Translation of Salawat...',
                onExpandedChanged: (value) {
                  setState(() {
                    _isSecondTakbirExpanded = value;
                  });
                },
              ),
              const Divider(),
              _buildTakbirSection(
                title: '3. Third Takbir',
                content:
                    'Say the takbir (without raising the hands):\n\n'
                    'اللَّهُ أَكْبَرُ - Allahu Akbar\n\n'
                    'Recite the dua for the deceased (if male):\n\n'
                    'اللَّهُمَّ اغْفِرْ لَهُ، وَارْحَمْهُ،\n'
                    'Allahumma ighfir lahu wa arhamhu.',
                isExpandable: true,
                isExpanded: _isThirdTakbirExpanded,
                expandedContent: 'Extended dua translation...',
                onExpandedChanged: (value) {
                  setState(() {
                    _isThirdTakbirExpanded = value;
                  });
                },
              ),
              const Divider(),
              _buildTakbirSection(
                title: '4. Fourth Takbir',
                content:
                    'Say the takbir (without raising the hands):\n\n'
                    'اللَّهُ أَكْبَرُ - Allahu Akbar\n\n'
                    'You can make a supplication, but it is not obligatory.',
              ),
              const Divider(),
              _buildSection(
                title: 'Conclusion (Taslim)',
                content:
                    '📌 You can say the taslim once to the right or twice (to the right and to the left).',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildTakbirSection({
    required String title,
    required String content,
    bool isExpandable = false,
    bool isExpanded = false,
    String? expandedContent,
    ValueChanged<bool>? onExpandedChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
          textDirection: TextDirection.ltr,
        ),
        if (isExpandable && expandedContent != null) ...[
          const SizedBox(height: 8),
          ExpansionTile(
            title: const Text(
              'Translation',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            initiallyExpanded: isExpanded,
            onExpansionChanged: onExpandedChanged,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  expandedContent,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
