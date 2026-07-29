import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final double averageRating;
  final int ratingCount;
  final List<String> specializations;
  final List<Map<String, dynamic>> feedbackItems;
  /// When true, skips Scaffold/SafeArea/SingleChildScrollView wrappers so the
  /// parent scroll view (CustomScrollView) handles all scrolling.
  final bool embedded;

  const MHPProfileEditScreen({
    super.key,
    this.initialWhoIAm,
    this.initialHowICanHelp,
    this.initialWhatToExpect,
    this.readOnly = false,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.specializations = const [],
    this.feedbackItems = const [],
    this.embedded = false,
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
    final content = Column(
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
              if (widget.specializations.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagCard(
                  title: "I help people going through:",
                  color: primaryColor,
                  tags: widget.specializations,
                ),
              ],
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
        const SizedBox(height: 24),
        _buildRatingSection(),
        const SizedBox(height: 20),
      ],
    );
    if (widget.embedded) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: content,
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      ),
    );
  }

  Widget _buildRatingSection() {
    if (widget.averageRating <= 0 && widget.ratingCount == 0 && widget.feedbackItems.isEmpty) {
      return const SizedBox.shrink();
    }
    final displayRating = widget.averageRating.toStringAsFixed(1);
    final fullStars = widget.averageRating.floor();
    final hasHalf = (widget.averageRating - fullStars) >= 0.25;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Divider header ──
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'check what client says',
                style: TextStyle(
                  
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Big rating number + stars ──
        Center(
          child: Column(
            children: [
              Text(
                displayRating,
                style: const TextStyle(
                  
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  if (i < fullStars) {
                    return const Icon(Icons.star, color: Color(0xFFFFC107), size: 32);
                  } else if (i == fullStars && hasHalf) {
                    return const Icon(Icons.star_half, color: Color(0xFFFFC107), size: 32);
                  }
                  return const Icon(Icons.star_border, color: Color(0xFFFFC107), size: 32);
                }),
              ),
              if (widget.ratingCount > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${widget.ratingCount} ${widget.ratingCount == 1 ? 'review' : 'reviews'}',
                  style: TextStyle(
                    
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),

        // ── Individual review cards ──
        if (widget.feedbackItems.isNotEmpty) ...[
          const SizedBox(height: 20),
          ...widget.feedbackItems.reversed.map((f) => _buildReviewCard(f)),
        ],

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> f) {
    final text = (f['text'] as String?)?.trim() ?? '';
    final rating = (f['rating'] as num?)?.toInt() ?? 0;
    final createdAt = f['created_at'];
    String dateLabel = '';
    if (createdAt is String) {
      final dt = DateTime.tryParse(createdAt)?.toLocal();
      if (dt != null) {
        const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        dateLabel = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFFFC107),
                  size: 18,
                )),
              ),
              if (dateLabel.isNotEmpty)
                Text(
                  dateLabel,
                  style: TextStyle(
                    
                    fontSize: 12,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ],
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
                      
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
              if (!readOnly) SvgPicture.asset('assets/icon/edit.svg', width: 20, height: 20),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: readOnly ? null : onChanged,
            maxLines: null,
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
                  style: TextStyle(color: Colors.white),
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
