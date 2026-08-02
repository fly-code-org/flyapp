import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fly/features/user_profile/data/services/profile_pictures_service.dart';

class UserAvatarPicker extends StatefulWidget {
  final Function(String path, String url) onAvatarSelected;

  const UserAvatarPicker({
    super.key,
    required this.onAvatarSelected,
  });

  @override
  State<UserAvatarPicker> createState() => _UserAvatarPickerState();
}

class _UserAvatarPickerState extends State<UserAvatarPicker> {
  final ProfilePicturesService _service = ProfilePicturesService();
  ProfilePictureItem? _selectedPicture;
  bool _isLoading = false;

  void _showAvatarPicker() async {
    setState(() => _isLoading = true);

    final pictures = await _service.getProfilePictures();

    setState(() => _isLoading = false);

    if (pictures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No avatars available')),
      );
      return;
    }

    final result = await showModalBottomSheet<ProfilePictureItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AvatarPickerSheet(
        pictures: pictures,
        selectedPicture: _selectedPicture,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedPicture = result;
      });
      widget.onAvatarSelected(result.path, result.url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showAvatarPicker,
      child: SizedBox(
        width: 120,
        height: 120,
        child: Stack(
          children: [
            ClipOval(
              child: _selectedPicture != null
                  ? CachedNetworkImage(
                      imageUrl: _selectedPicture!.url,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            if (_isLoading)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF855DFC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: Border.all(color: Colors.grey[300]!, width: 2),
      ),
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      ),
    );
  }
}

class _AvatarPickerSheet extends StatefulWidget {
  final List<ProfilePictureItem> pictures;
  final ProfilePictureItem? selectedPicture;

  const _AvatarPickerSheet({
    required this.pictures,
    this.selectedPicture,
  });

  @override
  State<_AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends State<_AvatarPickerSheet> {
  ProfilePictureItem? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedPicture;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Choose Your Avatar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF855DFC),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: widget.pictures.length,
              itemBuilder: (context, index) {
                final picture = widget.pictures[index];
                final isSelected = _selected?.id == picture.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = picture;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF855DFC)
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: picture.url,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected != null
                    ? () => Navigator.of(context).pop(_selected)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF855DFC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Select Avatar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
