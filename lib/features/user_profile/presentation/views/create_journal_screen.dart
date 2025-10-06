import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class CreateJournalScreen extends StatefulWidget {
  const CreateJournalScreen({super.key});

  @override
  State<CreateJournalScreen> createState() => _CreateJournalScreenState();
}

class _CreateJournalScreenState extends State<CreateJournalScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Color selectedColor = Colors.white;

  final List<Map<String, dynamic>> moods = const [
    {'color': Colors.white, 'text': 'Neutral, minimal, open to interpretation'},
    {'color': Color(0xFFFFF5B7), 'text': 'Happy, cheerful, or content'},
    {'color': Color(0xFFCFE8FF), 'text': 'Sad, low, or feeling down'},
    {'color': Color(0xFFF7C0C0), 'text': 'Angry, frustrated, or irritated'},
    {'color': Color(0xFFE3D4F3), 'text': 'Anxious, stressed, or overwhelmed'},
    {'color': Color(0xFFD6F5E3), 'text': 'Calm, relaxed, or peaceful'},
  ];

  void _saveJournal() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    Navigator.pop(context, {
      'title': title,
      'desc': desc,
      'color': selectedColor,
    });
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
                  setState(() => selectedColor = mood['color']);
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
    return Scaffold(
      backgroundColor: selectedColor,
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: selectedColor,
        title: Row(
          children: [
            const SizedBox(width: 8),
            const Text(
              "My Daily Journal",
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
            const SizedBox(width: 25),
            DottedBorder(
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
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mood, color: Colors.black54),
                      const SizedBox(width: 8),
                      const Text(
                        "Add your mood",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
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
              const SizedBox(height: 20),

              const SizedBox(height: 40),

              // SizedBox(
              //   width: double.infinity,
              //   height: 50,
              //   child: ElevatedButton(
              //     onPressed: _saveJournal,
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: const Color(0xFF855DFC),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //     ),
              //     child: const Text(
              //       "Save Journal",
              //       style: TextStyle(
              //         fontSize: 16,
              //         fontWeight: FontWeight.w600,
              //         color: Colors.white,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
