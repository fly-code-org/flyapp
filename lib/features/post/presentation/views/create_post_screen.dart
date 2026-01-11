// presentation/views/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/s3_upload_service.dart';
import '../../domain/entities/post.dart';
import '../controllers/post_controller.dart';
import '../widgets/tag_selection_bottom_sheet.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _textController = TextEditingController();
  final PageController _pageController = PageController();
  final PostController _postController = sl<PostController>();
  final S3UploadService _s3UploadService = sl<S3UploadService>();

  List<File> _selectedImageFiles = [];
  String? _selectedTagName;
  int? _selectedTagId;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showTagSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TagSelectionBottomSheet(
        onTagSelected: (tagName, tagId) {
          setState(() {
            _selectedTagName = tagName;
            _selectedTagId = tagId;
          });
          print('✅ [CREATE POST] Selected tag: $tagName (ID: $tagId)');
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress for cost optimization
      );

      if (image != null) {
        final file = File(image.path);

        // Check file size (10MB limit for images)
        final fileSizeInMB = await file.length() / (1024 * 1024);
        if (fileSizeInMB > 10) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size must be less than 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImageFiles.add(file);
        });
      }
    } catch (e) {
      print('❌ [CREATE POST] Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImageFiles.removeAt(index);
      if (_currentPage >= _selectedImageFiles.length &&
          _selectedImageFiles.isNotEmpty) {
        _currentPage = _selectedImageFiles.length - 1;
      }
    });
  }

  Future<List<Attachment>> _uploadImages() async {
    if (_selectedImageFiles.isEmpty) return [];

    final attachments = <Attachment>[];
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      for (int i = 0; i < _selectedImageFiles.length; i++) {
        final file = _selectedImageFiles[i];
        print(
          '📤 [CREATE POST] Uploading image ${i + 1}/${_selectedImageFiles.length}...',
        );

        final s3Path = await _s3UploadService.uploadFile(
          file: file,
          isProfilePicture: false,
          customFileType: 'post_image',
          onProgress: (progress) {
            // Calculate overall progress
            final overallProgress = (i + progress) / _selectedImageFiles.length;
            setState(() {
              _uploadProgress = overallProgress;
            });
          },
        );

        // Prepend CDN base URL
        final imageUrl = s3Path.startsWith('http')
            ? s3Path
            : 'https://cdn.flyapp.in$s3Path';

        attachments.add(Attachment(type: 'image', url: imageUrl));
        print('✅ [CREATE POST] Image ${i + 1} uploaded: $imageUrl');
      }

      return attachments;
    } catch (e) {
      print('❌ [CREATE POST] Error uploading images: $e');
      rethrow;
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Future<void> _submitPost() async {
    // Validation
    if (_selectedTagId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a tag'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final hasContent = _textController.text.trim().isNotEmpty;
    final hasImages = _selectedImageFiles.isNotEmpty;

    if (!hasContent && !hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add text or an image to your post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate text length (5000 chars max, typical for modern social apps)
    if (_textController.text.trim().length > 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text must be less than 5000 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload images first
      List<Attachment> attachments = [];
      if (_selectedImageFiles.isNotEmpty) {
        attachments = await _uploadImages();
      }

      // Create post
      final success = await _postController.createPostEntry(
        tagId: _selectedTagId!,
        content: _textController.text.trim().isEmpty
            ? null
            : _textController.text.trim(),
        attachments: attachments,
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back
        Navigator.pop(context, true); // Return true to indicate success
      } else if (mounted) {
        // Show error message
        final errorMsg = _postController.errorMessage.value.isNotEmpty
            ? _postController.errorMessage.value
            : 'Failed to create post. Please try again later.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ [CREATE POST] Error submitting post: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}. Please try again later.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Post"),
        actions: [
          // Only observe loading state, not rebuild on every keystroke
          Obx(() {
            final isLoading = _postController.isLoading.value || _isUploading;
            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return TextButton(
              onPressed: _submitPost,
              child: const Text(
                "Post",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag Selection (Required) - Wrap in RepaintBoundary to prevent unnecessary repaints
            RepaintBoundary(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Tag *',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _showTagSelectionBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedTagName ?? 'Tap to select a tag',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedTagName != null
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Text field - Optimized with better performance settings
            TextField(
              controller: _textController,
              maxLines: null,
              minLines: 1,
              maxLength: 5000, // Modern social app limit
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              enableSuggestions: true,
              enableInteractiveSelection: true,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null, // Hide counter
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              ),
            ),

            // Images preview with PageView + dots - Wrap in RepaintBoundary and optimize
            if (_selectedImageFiles.isNotEmpty)
              RepaintBoundary(
                key: ValueKey(
                  'image_preview_${_selectedImageFiles.length}_$_currentPage',
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) {
                          setState(() => _currentPage = i);
                        },
                        itemCount: _selectedImageFiles.length,
                        itemBuilder: (context, index) {
                          return RepaintBoundary(
                            key: ValueKey('image_$index'),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(
                                    _selectedImageFiles[index],
                                    fit: BoxFit.cover,
                                    cacheWidth:
                                        800, // Limit image resolution for better performance
                                    cacheHeight: 600,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.black54,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Optimize dot indicators
                    RepaintBoundary(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _selectedImageFiles.length,
                          (i) => Container(
                            key: ValueKey('dot_$i'),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == i
                                  ? const Color(0xFF855DFC)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Upload progress indicator - Only rebuild when uploading
            if (_isUploading)
              RepaintBoundary(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      LinearProgressIndicator(value: _uploadProgress),
                      const SizedBox(height: 8),
                      Text(
                        'Uploading images... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),

      // Bottom bar to attach media
      bottomNavigationBar: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: _isUploading ? null : _pickImage,
              tooltip: 'Add Image',
            ),
            // Video and Poll buttons disabled for MVP (Option A)
            // Will be enabled in future iterations
            IconButton(
              icon: const Icon(Icons.videocam),
              onPressed: null, // Disabled for MVP
              tooltip: 'Coming soon',
            ),
            IconButton(
              icon: const Icon(Icons.poll),
              onPressed: null, // Disabled for MVP
              tooltip: 'Coming soon',
            ),
          ],
        ),
      ),
    );
  }
}
