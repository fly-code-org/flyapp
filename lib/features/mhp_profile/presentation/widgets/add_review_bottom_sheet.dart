import 'package:flutter/material.dart';
import 'package:fly/features/mhp_profile/data/datasources/mhp_feedback_remote_data_source.dart';

class AddReviewBottomSheet extends StatefulWidget {
  const AddReviewBottomSheet({
    super.key,
    required this.mhpId,
    required this.mhpName,
    required this.bookingId,
  });

  final String mhpId;
  final String mhpName;
  final String bookingId;

  static Future<bool> show(
    BuildContext context, {
    required String mhpId,
    required String mhpName,
    required String bookingId,
  }) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReviewBottomSheet(
        mhpId: mhpId,
        mhpName: mhpName,
        bookingId: bookingId,
      ),
    );
    return submitted == true;
  }

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  int _selectedRating = 0;
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  // Emoji faces for each star level
  static const List<String> _emojis = ['😢', '🙁', '😐', '😊', '😄'];

  int _wordCount(String text) =>
      text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }
    if (_wordCount(_textController.text) > 240) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review exceeds 240 words')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await MhpFeedbackRemoteDataSource().submitFeedback(
        mhpId: widget.mhpId,
        bookingId: widget.bookingId,
        rating: _selectedRating,
        text: _textController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted. Thank you!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final wordCount = _wordCount(_textController.text);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Feel free to add your honest opinion',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          const Text(
            'How would you like to rate?',
            style: TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          // Emoji star row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              final isSelected = _selectedRating == star;
              return GestureDetector(
                onTap: () => setState(() => _selectedRating = star),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: isSelected ? 56 : 48,
                  height: isSelected ? 56 : 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFFC107)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _emojis[i],
                      style: TextStyle(fontSize: isSelected ? 26 : 22),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Text field
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _textController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: '${widget.mhpName} was',
                    hintStyle: const TextStyle(color: Colors.black38),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 15),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 4),
                Text(
                  'Maximum 240 words${wordCount > 0 ? ' · $wordCount used' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: wordCount > 240 ? Colors.red : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7B61FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Add my review',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
