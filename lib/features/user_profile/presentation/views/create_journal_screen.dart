import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import '../../../journal/presentation/controllers/journal_controller.dart';
import '../../../journal/domain/entities/journal.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/safe_navigation.dart';

class CreateJournalScreen extends StatefulWidget {
  final Journal? journal; // Optional journal for editing

  const CreateJournalScreen({super.key, this.journal});

  @override
  State<CreateJournalScreen> createState() => _CreateJournalScreenState();
}

class _CreateJournalScreenState extends State<CreateJournalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  late final JournalController _journalController;

  Color selectedColor = Colors.white;
  String selectedMood = 'Neutral, minimal, open to interpretation';

  final List<Map<String, dynamic>> moods = const [
    {'color': Colors.white, 'text': 'Neutral, minimal, open to interpretation'},
    {'color': Color(0xFFFFF5B7), 'text': 'Happy, cheerful, or content'},
    {'color': Color(0xFFCFE8FF), 'text': 'Sad, low, or feeling down'},
    {'color': Color(0xFFF7C0C0), 'text': 'Angry, frustrated, or irritated'},
    {'color': Color(0xFFE3D4F3), 'text': 'Anxious, stressed, or overwhelmed'},
    {'color': Color(0xFFD6F5E3), 'text': 'Calm, relaxed, or peaceful'},
  ];

  @override
  void initState() {
    super.initState();
    // Get or create controller
    if (Get.isRegistered<JournalController>()) {
      _journalController = Get.find<JournalController>();
    } else {
      _journalController = sl<JournalController>();
      Get.put(_journalController, permanent: true);
    }

    // Ensure color templates are loaded (needed for journal creation)
    if (_journalController.colorTemplates.isEmpty) {
      _journalController.fetchColorTemplates();
    }

    // If editing, populate fields
    if (widget.journal != null) {
      _titleController.text = widget.journal!.title;
      _descController.text = widget.journal!.content;
      selectedMood = widget.journal!.mood ?? 'Neutral, minimal, open to interpretation';
      
      // Get color from template
      final color = _journalController.getColorFromTemplateId(widget.journal!.colorTemplate);
      if (color != null) {
        selectedColor = color;
      }
    }
  }

  Future<void> _saveJournal() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // Create or update journal via API
    final success = widget.journal != null
        ? await _journalController.updateJournalEntry(
            journalId: widget.journal!.id,
            title: title,
            content: desc,
            selectedColor: selectedColor,
            mood: selectedMood,
          )
        : await _journalController.createJournalEntry(
            title: title,
            content: desc,
            selectedColor: selectedColor,
            mood: selectedMood,
          );

    // Hide loading
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
    }

    if (success) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.journal != null
                ? "Journal updated successfully!"
                : "Journal created successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Navigate back and refresh
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_journalController.errorMessage.value.isNotEmpty
                ? _journalController.errorMessage.value
                : "Failed to create journal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openMoodPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: 400,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: moods.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final mood = moods[index];
              return ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.deepPurple, // <-- your #855DFC color
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: mood['color'],
                    radius: 18, // slightly smaller to fit inside border
                  ),
                ),
                title: Text(mood['text']),
                onTap: () {
                  setState(() {
                    selectedColor = mood['color'];
                    selectedMood = mood['text'];
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafePopScope(
      child: Scaffold(
      backgroundColor: selectedColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popOrGoHome(context),
        ),
        backgroundColor: selectedColor,
        title: Row(
          children: [
            const Flexible(
              child: Text(
                "My Daily Journal",
                style: TextStyle(fontWeight: FontWeight.w400),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: DottedBorder(
                options: const RoundedRectDottedBorderOptions(
                  color: Colors.black54,
                  strokeWidth: 1.5,
                  dashPattern: [6, 3],
                  radius: Radius.circular(12),
                  padding: EdgeInsets.all(0),
                ),
                child: InkWell(
                  onTap: _openMoodPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.mood, color: Colors.black54, size: 18),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "Add your mood",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: "Title"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Write your thoughts...",
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveJournal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF855DFC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.journal != null ? "Update Journal" : "Save Journal",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
