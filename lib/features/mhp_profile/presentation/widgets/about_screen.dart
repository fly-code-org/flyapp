import 'package:flutter/material.dart';
import 'package:fly/core/di/service_locator.dart';
import 'package:fly/features/profile_creation/domain/usecases/get_about_me.dart';
import 'package:fly/features/profile_creation/domain/usecases/update_about_me.dart';
import 'package:get/get.dart';

class MHPProfileEditScreen extends StatefulWidget {
  final String? initialWhoIAm;
  final String? initialHowICanHelp;
  final String? initialWhatToExpect;
  /// When true (viewer on another MHP's profile): same layout as edit mode but no edits or API load of *viewer's* about me.
  final bool readOnly;

  const MHPProfileEditScreen({
    super.key,
    this.initialWhoIAm,
    this.initialHowICanHelp,
    this.initialWhatToExpect,
    this.readOnly = false,
  });

  @override
  State<MHPProfileEditScreen> createState() => _MHPProfileEditScreenState();
}

class _MHPProfileEditScreenState extends State<MHPProfileEditScreen> {
  final Color primaryColor = const Color(0xFF855DFC);

  final TextEditingController whoIAmController = TextEditingController();
  final TextEditingController howICanHelpController = TextEditingController();
  final TextEditingController whatToExpectController = TextEditingController();

  bool showSaveWhoIAm = false;
  bool showSaveHowICanHelp = false;
  bool showSaveWhatToExpect = false;
  bool _saving = false;

  final List<String> helpTags = [
    "Anxiety",
    "Depression",
    "Job Aspirant",
    "Teenager",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialWhoIAm != null && widget.initialWhoIAm!.isNotEmpty) {
      whoIAmController.text = widget.initialWhoIAm!;
    }
    if (widget.initialHowICanHelp != null && widget.initialHowICanHelp!.isNotEmpty) {
      howICanHelpController.text = widget.initialHowICanHelp!;
    }
    if (widget.initialWhatToExpect != null && widget.initialWhatToExpect!.isNotEmpty) {
      whatToExpectController.text = widget.initialWhatToExpect!;
    }
    if (widget.readOnly) {
      return;
    }
    if (whoIAmController.text.isEmpty && howICanHelpController.text.isEmpty && whatToExpectController.text.isEmpty) {
      _loadAboutMe();
    }
  }

  @override
  void didUpdateWidget(MHPProfileEditScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.readOnly) {
      return;
    }
    if (widget.initialWhoIAm != oldWidget.initialWhoIAm) {
      whoIAmController.text = widget.initialWhoIAm ?? '';
    }
    if (widget.initialHowICanHelp != oldWidget.initialHowICanHelp) {
      howICanHelpController.text = widget.initialHowICanHelp ?? '';
    }
    if (widget.initialWhatToExpect != oldWidget.initialWhatToExpect) {
      whatToExpectController.text = widget.initialWhatToExpect ?? '';
    }
  }

  Future<void> _loadAboutMe() async {
    try {
      final data = await sl<GetAboutMe>().call();
      if (!mounted) return;
      setState(() {
        whoIAmController.text = data['who_i_am']?.toString() ?? '';
        howICanHelpController.text = data['how_i_can_help']?.toString() ?? '';
        whatToExpectController.text = data['what_to_expect']?.toString() ?? '';
      });
    } catch (_) {}
  }

  Future<void> _saveAboutMe() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await sl<UpdateAboutMe>().call({
        'who_i_am': whoIAmController.text.trim(),
        'how_i_can_help': howICanHelpController.text.trim(),
        'what_to_expect': whatToExpectController.text.trim(),
      });
      if (!mounted) return;
      Get.snackbar('Saved', 'About updated', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      setState(() {
        showSaveWhoIAm = false;
        showSaveHowICanHelp = false;
        showSaveWhatToExpect = false;
      });
    } catch (e) {
      if (mounted) {
        Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    whoIAmController.dispose();
    howICanHelpController.dispose();
    whatToExpectController.dispose();
    super.dispose();
  }

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
                onSave: () => _saveAboutMe(),
                readOnly: widget.readOnly,
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
                onSave: () => _saveAboutMe(),
                readOnly: widget.readOnly,
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
                controller: whatToExpectController,
                showSaveButton: showSaveWhatToExpect,
                onChanged: (value) {
                  setState(() => showSaveWhatToExpect = value.isNotEmpty);
                },
                onSave: () => _saveAboutMe(),
                readOnly: widget.readOnly,
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
    bool readOnly = false,
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
              if (!readOnly) const Icon(Icons.edit, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: readOnly ? null : onChanged,
            maxLines: null,
            style: const TextStyle(fontFamily: 'Lexend'),
            decoration: InputDecoration(
              hintText: readOnly ? null : "Add details here...",
              border: InputBorder.none,
              isDense: true,
            ),
          ),
          if (!readOnly && showSaveButton) ...[
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

}
