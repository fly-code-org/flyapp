import 'package:flutter/material.dart';

class MHPProfileEditScreen extends StatefulWidget {
  const MHPProfileEditScreen({super.key});

  @override
  State<MHPProfileEditScreen> createState() => _MHPProfileEditScreenState();
}

class _MHPProfileEditScreenState extends State<MHPProfileEditScreen> {
  final Color primaryColor = const Color(0xFF855DFC);

  final TextEditingController whoIAmController = TextEditingController();
  final TextEditingController howICanHelpController = TextEditingController();

  bool showSaveWhoIAm = false;
  bool showSaveHowICanHelp = false;

  final List<String> helpTags = [
    "Anxiety",
    "Depression",
    "Job Aspirant",
    "Teenager",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // ✅ Wrapping with SingleChildScrollView fixes bottom overflow
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEditableCard(
                icon: Icons.verified_user,
                title: "Who I Am?",
                color: primaryColor,
                controller: whoIAmController,
                showSaveButton: showSaveWhoIAm,
                onChanged: (value) {
                  setState(() => showSaveWhoIAm = value.isNotEmpty);
                },
                onSave: () {
                  setState(() => showSaveWhoIAm = false);
                },
              ),
              const SizedBox(height: 16),
              _buildEditableCard(
                icon: Icons.flash_on_outlined,
                title: "How I Can Help?",
                color: primaryColor,
                controller: howICanHelpController,
                showSaveButton: showSaveHowICanHelp,
                onChanged: (value) {
                  setState(() => showSaveHowICanHelp = value.isNotEmpty);
                },
                onSave: () {
                  setState(() => showSaveHowICanHelp = false);
                },
              ),
              const SizedBox(height: 16),
              _buildTagCard(
                title: "I help people going through:",
                color: primaryColor,
                tags: helpTags,
              ),
              const SizedBox(height: 16),
              _buildEditableCard(
                icon: Icons.flash_on_outlined,
                title: "What to Expect?",
                color: primaryColor,
                controller: howICanHelpController,
                showSaveButton: showSaveHowICanHelp,
                onChanged: (value) {
                  setState(() => showSaveHowICanHelp = value.isNotEmpty);
                },
                onSave: () {
                  setState(() => showSaveHowICanHelp = false);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableCard({
    required IconData icon,
    required String title,
    required Color color,
    required TextEditingController controller,
    required bool showSaveButton,
    required Function(String) onChanged,
    required VoidCallback onSave,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Lexend',
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.edit, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            onChanged: onChanged,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: "Add details here...",
              border: InputBorder.none,
            ),
          ),
          if (showSaveButton) ...[
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  "Save Changes",
                  style: TextStyle(color: Colors.white, fontFamily: 'Lexend'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTagCard({
    required String title,
    required Color color,
    required List<String> tags,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_alt_outlined, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (tag) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpectationCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Lexend',
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
