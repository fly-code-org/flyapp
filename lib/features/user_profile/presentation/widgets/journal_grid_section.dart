import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../journal/presentation/controllers/journal_controller.dart';
import '../views/create_journal_screen.dart';

class JournalGridSection extends StatelessWidget {
  const JournalGridSection({super.key});


  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Get or create controller
    JournalController journalController;
    if (Get.isRegistered<JournalController>()) {
      journalController = Get.find<JournalController>();
    } else {
      journalController = Get.put(JournalController(), permanent: true);
    }

    return Obx(() {
      // Show loading
      if (journalController.isLoading.value && journalController.journals.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Show error
      if (journalController.errorMessage.value.isNotEmpty &&
          journalController.journals.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading journals',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  journalController.errorMessage.value,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    journalController.fetchJournals(forceRefresh: true);
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      // Show empty state
      if (journalController.journals.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No journals yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to start writing your journal',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // Show journals
      final journals = journalController.journals;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: journals.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final journal = journals[index];
        
        // Get color from color_template_id using the cached color templates
        // The controller's getColorFromTemplateId method handles:
        // 1. Looking up the template ID in the cached color templates list
        // 2. Extracting the hex code
        // 3. Converting to Color object
        // 4. Providing fallback to white if template not found or empty
        final journalColor = journalController.getColorFromTemplateId(journal.colorTemplate) ?? Colors.white;
        
        return GestureDetector(
          onTap: () async {
            // Navigate to edit screen
            final result = await Get.to(() => CreateJournalScreen(journal: journal));
            // Refresh if journal was updated
            if (result == true) {
              journalController.fetchJournals(forceRefresh: true);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: journalColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journal.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  _formatDate(journal.createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Lexend',
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    });
  }
}
