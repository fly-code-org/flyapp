// presentation/views/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/services/s3_upload_service.dart';
import '../../../../features/interests/data/models/tag_icon_mapping.dart';
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
  final _uuid = const Uuid();

  List<File> _selectedImageFiles = [];
  File? _selectedVideoFile;
  VideoPlayerController? _videoPlayerController;
  String? _selectedTagName;
  int? _selectedTagId;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  // Poll state
  bool _showPollSection = false;
  final TextEditingController _pollQuestionController = TextEditingController();
  final List<TextEditingController> _pollOptionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    _pollQuestionController.dispose();
    for (var controller in _pollOptionControllers) {
      controller.dispose();
    }
    _videoPlayerController?.dispose();
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
    // Check if poll is active
    if (_showPollSection) {
      _showMediaPollConflictDialog(isPollActive: true);
      return;
    }

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

  Future<void> _pickVideo({required ImageSource source}) async {
    // Check if poll is active
    if (_showPollSection) {
      _showMediaPollConflictDialog(isPollActive: true);
      return;
    }

    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (video != null) {
        final file = File(video.path);

        // Check file size (250MB limit)
        final fileSizeInMB = await file.length() / (1024 * 1024);
        if (fileSizeInMB > 250) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video size must be less than 250MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Check duration (5 minutes max)
        // Note: ImagePicker's maxDuration might not be reliable, so we check file metadata
        // For now, we'll rely on ImagePicker's maxDuration parameter

        setState(() {
          _selectedVideoFile = file;
          _initializeVideoPlayer(file);
        });
      }
    } catch (e) {
      print('❌ [CREATE POST] Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showVideoSourceDialog() async {
    if (_showPollSection) {
      _showMediaPollConflictDialog(isPollActive: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Video Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(source: ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(source: ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _initializeVideoPlayer(File videoFile) {
    _videoPlayerController?.dispose();
    _videoPlayerController = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoPlayerController?.play();
          _videoPlayerController?.setLooping(true);
          _videoPlayerController?.setVolume(0); // Muted by default
        }
      }).catchError((e) {
        print('❌ [CREATE POST] Error initializing video player: $e');
      });
  }

  void _removeVideo() {
    setState(() {
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
      _selectedVideoFile = null;
    });
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

  void _togglePollSection() {
    // Check if media is selected
    if (_selectedImageFiles.isNotEmpty || _selectedVideoFile != null) {
      _showMediaPollConflictDialog(isPollActive: false);
      return;
    }

    setState(() {
      _showPollSection = !_showPollSection;
      if (!_showPollSection) {
        // Clear poll data when hiding
        _pollQuestionController.clear();
        for (var controller in _pollOptionControllers) {
          controller.clear();
        }
        // Reset to 2 options
        while (_pollOptionControllers.length > 2) {
          _pollOptionControllers.removeLast().dispose();
        }
      }
    });
  }

  void _showMediaPollConflictDialog({required bool isPollActive}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Conflict'),
        content: Text(
          isPollActive
              ? 'Adding media will remove the poll. Continue?'
              : 'Adding a poll will remove the selected media. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isPollActive) {
                // Remove poll, allow media
                setState(() {
                  _showPollSection = false;
                  _pollQuestionController.clear();
                  for (var controller in _pollOptionControllers) {
                    controller.clear();
                  }
                  while (_pollOptionControllers.length > 2) {
                    _pollOptionControllers.removeLast().dispose();
                  }
                });
              } else {
                // Remove media, allow poll
                setState(() {
                  _selectedImageFiles.clear();
                  _selectedVideoFile = null;
                  _videoPlayerController?.dispose();
                  _videoPlayerController = null;
                  _showPollSection = true;
                });
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _addPollOption() {
    if (_pollOptionControllers.length < 6) {
      setState(() {
        _pollOptionControllers.add(TextEditingController());
      });
    }
  }

  void _removePollOption(int index) {
    if (_pollOptionControllers.length > 2) {
      setState(() {
        _pollOptionControllers.removeAt(index).dispose();
      });
    }
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

  Future<Attachment?> _uploadVideo() async {
    if (_selectedVideoFile == null) return null;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      print('📤 [CREATE POST] Uploading video...');

      final s3Path = await _s3UploadService.uploadFile(
        file: _selectedVideoFile!,
        isProfilePicture: false,
        customFileType: 'post_video',
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );

      // Prepend CDN base URL
      final videoUrl = s3Path.startsWith('http')
          ? s3Path
          : 'https://cdn.flyapp.in$s3Path';

      print('✅ [CREATE POST] Video uploaded: $videoUrl');
      return Attachment(type: 'video', url: videoUrl);
    } catch (e) {
      print('❌ [CREATE POST] Error uploading video: $e');
      rethrow;
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Poll? _buildPoll() {
    if (!_showPollSection) return null;

    // Validate poll question
    final question = _pollQuestionController.text.trim();
    if (question.isEmpty) {
      return null; // Will be caught in validation
    }

    // Validate poll options (at least 2 non-empty)
    final validOptions = <PollOption>[];
    for (var controller in _pollOptionControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        // Generate UUID for option ID (backend will use this)
        validOptions.add(PollOption(
          optionId: _uuid.v4(),
          text: text,
          votes: const [],
        ));
      }
    }

    if (validOptions.length < 2) {
      return null; // Will be caught in validation
    }

    // Set expiration to 1 day from now
    final expiresAt = DateTime.now().add(const Duration(days: 1));

    return Poll(
      question: question,
      options: validOptions,
      expiresAt: expiresAt,
      createdAt: DateTime.now(),
    );
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
    final hasVideo = _selectedVideoFile != null;
    final hasPoll = _showPollSection;

    // Validate: must have content, media, or poll
    if (!hasContent && !hasImages && !hasVideo && !hasPoll) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add text, media, or a poll to your post'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate text length (5000 chars max)
    if (_textController.text.trim().length > 5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text must be less than 5000 characters'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate poll if active
    if (hasPoll) {
      final question = _pollQuestionController.text.trim();
      if (question.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll question is required'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final validOptions = _pollOptionControllers
          .where((c) => c.text.trim().isNotEmpty)
          .length;
      if (validOptions < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll must have at least 2 options'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Validate option text length (100 chars max)
      for (var controller in _pollOptionControllers) {
        final text = controller.text.trim();
        if (text.isNotEmpty && text.length > 100) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Poll options must be 100 characters or less'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload media first
      List<Attachment> attachments = [];
      if (_selectedImageFiles.isNotEmpty) {
        attachments.addAll(await _uploadImages());
      }
      if (_selectedVideoFile != null) {
        final videoAttachment = await _uploadVideo();
        if (videoAttachment != null) {
          attachments.add(videoAttachment);
        }
      }

      // Build poll
      final poll = _buildPoll();

      // Create post
      final success = await _postController.createPostEntry(
        tagId: _selectedTagId!,
        content: _textController.text.trim().isEmpty
            ? null
            : _textController.text.trim(),
        attachments: attachments,
        poll: poll,
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
              child: Row(
                children: [
                  // "Share to" label in grey
                  const Text(
                    'Share to',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tag selector - width fits content only
                  InkWell(
                    onTap: _showTagSelectionBottomSheet,
                    child: _selectedTagName == null
                        ? // Unselected state: Curved rectangular box with grey background and gradient purple border
                        Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8A56AC),
                                  Color(0xFF6A3BA0),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(1.5), // Border width
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10.5),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // PNG icon
                                  Image.asset(
                                    'assets/images/select_tag.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  // Light purple text "[add a tag]"
                                  const Text(
                                    '[add a tag]',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFFC4A8F5), // Light purple
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : // Selected state: Pill shape container with grey background
                        Builder(
                            builder: (context) {
                              // Get tag icon path from selected tag name
                              final tagIconPath = TagIconMapping.getTagIconPath(_selectedTagName!);
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(50), // Pill shape
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Selected tag icon on left
                                    if (tagIconPath.isNotEmpty)
                                      SvgPicture.asset(
                                        tagIconPath,
                                        width: 20,
                                        height: 20,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF855DFC),
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.local_offer,
                                        color: Color(0xFF855DFC),
                                        size: 20,
                                      ),
                                    const SizedBox(width: 8),
                                    // Selected tag text
                                    Text(
                                      _selectedTagName!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
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

            // Poll Section (Inline)
            if (_showPollSection) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Poll',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _togglePollSection,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Poll Question
                    TextField(
                      controller: _pollQuestionController,
                      decoration: const InputDecoration(
                        hintText: 'Ask a question...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),
                    // Poll Options
                    ...List.generate(
                      _pollOptionControllers.length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _pollOptionControllers[index],
                                decoration: InputDecoration(
                                  hintText: 'Option ${index + 1}',
                                  border: const OutlineInputBorder(),
                                  isDense: true,
                                ),
                                maxLength: 100,
                              ),
                            ),
                            if (_pollOptionControllers.length > 2)
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => _removePollOption(index),
                                padding: const EdgeInsets.only(left: 8),
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Add Option Button
                    if (_pollOptionControllers.length < 6)
                      TextButton.icon(
                        onPressed: _addPollOption,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add Option'),
                      ),
                  ],
                ),
              ),
            ],

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

            // Video preview
            if (_selectedVideoFile != null && _videoPlayerController != null)
              RepaintBoundary(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      if (_videoPlayerController!.value.isInitialized)
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: _videoPlayerController!.value.aspectRatio,
                              child: VideoPlayer(_videoPlayerController!),
                            ),
                          ),
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator(),
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
                            onPressed: _removeVideo,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                        'Uploading ${_selectedVideoFile != null ? "video" : "images"}... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
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
              icon: Icon(
                Icons.image,
                color: _showPollSection ? Colors.grey : null,
              ),
              onPressed: _isUploading || _showPollSection
                  ? null
                  : _pickImage,
              tooltip: _showPollSection ? 'Disable poll to add images' : 'Add Image',
            ),
            IconButton(
              icon: Icon(
                Icons.videocam,
                color: _showPollSection ? Colors.grey : null,
              ),
              onPressed: _isUploading || _showPollSection
                  ? null
                  : _showVideoSourceDialog,
              tooltip: _showPollSection ? 'Disable poll to add video' : 'Add Video',
            ),
            IconButton(
              icon: Icon(
                Icons.poll,
                color: (_selectedImageFiles.isNotEmpty || _selectedVideoFile != null)
                    ? Colors.grey
                    : (_showPollSection ? Colors.blue : null),
              ),
              onPressed: _isUploading ||
                      _selectedImageFiles.isNotEmpty ||
                      _selectedVideoFile != null
                  ? null
                  : _togglePollSection,
              tooltip: (_selectedImageFiles.isNotEmpty || _selectedVideoFile != null)
                  ? 'Remove media to add poll'
                  : (_showPollSection ? 'Remove Poll' : 'Add Poll'),
            ),
          ],
        ),
      ),
    );
  }
}
