import 'package:flutter/material.dart';

/// Model for a tag
class CommunityTag {
  final String name;
  final IconData icon; // Placeholder, you can replace with your own icons
  CommunityTag({required this.name, required this.icon});
}

/// Base widget for tag picker
class CommunityTagPicker extends StatefulWidget {
  final List<CommunityTag> tags;
  final bool isSocial; // true = social, false = supported
  final String placeholder;

  const CommunityTagPicker({
    super.key,
    required this.tags,
    required this.isSocial,
    this.placeholder = "Select a tag",
  });

  @override
  State<CommunityTagPicker> createState() => _CommunityTagPickerState();
}

class _CommunityTagPickerState extends State<CommunityTagPicker> {
  CommunityTag? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final borderColor = _selectedTag == null
        ? Colors.grey
        : Colors.deepPurple.shade200;

    final borderRadius = BorderRadius.circular(widget.isSocial ? 20 : 8);

    return GestureDetector(
      onTap: () => _openTagSelector(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: borderRadius,
        ),
        child: Row(
          children: [
            if (_selectedTag != null)
              Icon(_selectedTag!.icon, size: 28)
            else
              const Icon(
                Icons.tag,
                size: 28,
                color: Colors.grey,
              ), // placeholder

            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _selectedTag?.name ?? widget.placeholder,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedTag == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 24),
          ],
        ),
      ),
    );
  }

  void _openTagSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return ListView.builder(
              controller: controller,
              itemCount: widget.tags.length,
              itemBuilder: (context, index) {
                final tag = widget.tags[index];
                return ListTile(
                  leading: widget.isSocial
                      ? CircleAvatar(
                          radius: 18,
                          child: Icon(tag.icon, size: 20),
                        )
                      : Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.deepPurple.shade50,
                          ),
                          child: Icon(tag.icon, size: 20),
                        ),
                  title: Text(tag.name),
                  onTap: () {
                    setState(() => _selectedTag = tag);
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
