// presentation/controllers/journal_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/journal.dart';
import '../../domain/entities/create_journal_request.dart';
import '../../domain/usecases/get_journals.dart';
import '../../domain/usecases/create_journal.dart';
import '../../domain/usecases/update_journal.dart';
import '../../domain/usecases/get_color_templates.dart';
import '../../domain/usecases/create_color_template.dart';
import '../../domain/entities/update_journal_request.dart';

class JournalController extends GetxController {
  final GetJournals getJournals;
  final CreateJournal createJournal;
  final UpdateJournal updateJournal;
  final GetColorTemplates getColorTemplates;
  final CreateColorTemplate createColorTemplate;

  JournalController({
    GetJournals? getJournals,
    CreateJournal? createJournal,
    UpdateJournal? updateJournal,
    GetColorTemplates? getColorTemplates,
    CreateColorTemplate? createColorTemplate,
  })  : getJournals = getJournals ?? sl<GetJournals>(),
        createJournal = createJournal ?? sl<CreateJournal>(),
        updateJournal = updateJournal ?? sl<UpdateJournal>(),
        getColorTemplates = getColorTemplates ?? sl<GetColorTemplates>(),
        createColorTemplate = createColorTemplate ?? sl<CreateColorTemplate>();

  // State
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var journals = <Journal>[].obs;
  var colorTemplates = <ColorTemplate>[].obs;

  // Cache
  DateTime? _lastFetchTime;
  static const Duration cacheValidDuration = Duration(minutes: 5);

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch on init - let the profile screen control when to fetch
    // This prevents unnecessary API calls when controller is created but not needed
    // The profile screen will call fetchColorTemplates() and fetchJournals() when appropriate
  }

  Future<void> fetchJournals({bool forceRefresh = false}) async {
    if (isLoading.value) return;

    if (!forceRefresh &&
        journals.isNotEmpty &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheValidDuration) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [JOURNAL] Fetching journals...');
      final fetchedJournals = await getJournals.call(limit: 10, skip: 0);
      
      journals.value = fetchedJournals;
      _lastFetchTime = DateTime.now();
      
      print('✅ [JOURNAL] Fetched ${journals.length} journals');
    } on ServerException catch (e) {
      print('❌ [JOURNAL] ServerException: ${e.message}');
      errorMessage.value = e.message;
    } on NetworkException catch (e) {
      print('❌ [JOURNAL] NetworkException: ${e.message}');
      errorMessage.value = e.message;
    } catch (e) {
      print('❌ [JOURNAL] Unexpected error: $e');
      errorMessage.value = 'Failed to load journals: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchColorTemplates() async {
    try {
      print('🔍 [JOURNAL] Fetching color templates...');
      final templates = await getColorTemplates.call(limit: 100, skip: 0);
      
      colorTemplates.value = templates;
      print('✅ [JOURNAL] Fetched ${templates.length} color templates');
    } catch (e) {
      print('⚠️ [JOURNAL] Error fetching color templates: $e');
      // Don't fail if color templates can't be fetched
      colorTemplates.value = [];
    }
  }

  // Normalize hex code for comparison (remove #, uppercase, trim)
  String _normalizeHexCode(String hex) {
    return hex.replaceFirst('#', '').toUpperCase().trim();
  }

  Future<String?> findOrCreateColorTemplate(Color selectedColor) async {
    // Ensure color templates are loaded first
    if (colorTemplates.isEmpty) {
      print('⚠️ [JOURNAL] Color templates not loaded, fetching now...');
      await fetchColorTemplates();
    }
    
    // Convert Color to hex code (ensure it has # prefix)
    final colorValue = selectedColor.value.toRadixString(16);
    final hexCode = '#${colorValue.substring(2).toUpperCase()}';
    final normalizedHex = _normalizeHexCode(hexCode);
    
    print('🔍 [JOURNAL] Looking for color template with hex: $hexCode (normalized: $normalizedHex)');
    print('📋 [JOURNAL] Available templates: ${colorTemplates.length} templates loaded');
    // Log first few templates for debugging
    for (var i = 0; i < colorTemplates.length && i < 5; i++) {
      final t = colorTemplates[i];
      print('  📋 Template[$i]: id="${t.id}", hex="${t.hexCode}" (normalized: ${_normalizeHexCode(t.hexCode)})');
    }
    
    // Try to find existing template by matching hex code (normalized comparison)
    ColorTemplate? existing;
    for (var template in colorTemplates) {
      final templateHex = _normalizeHexCode(template.hexCode);
      if (templateHex == normalizedHex) {
        existing = template;
        break;
      }
    }

    if (existing != null) {
      // Check if template has a valid ID
      if (existing.id.isNotEmpty) {
        print('✅ [JOURNAL] Found existing color template: id="${existing.id}", hex="${existing.hexCode}"');
        return existing.id;
      } else {
        print('⚠️ [JOURNAL] Found template with empty ID for hex: ${existing.hexCode}, will create new one');
        // Template exists but has empty ID, create a new one with proper ID
      }
    }

    // Create new template if not found or has empty ID
    try {
      print('🔍 [JOURNAL] Creating new color template for $hexCode');
      final newTemplate = await createColorTemplate.call(hexCode: hexCode);
      // Add to cache (replace if exists with empty ID)
      if (existing != null) {
        final index = colorTemplates.indexWhere((t) => _normalizeHexCode(t.hexCode) == normalizedHex);
        if (index != -1) {
          colorTemplates[index] = newTemplate;
        } else {
          colorTemplates.add(newTemplate);
        }
      } else {
        colorTemplates.add(newTemplate);
      }
      print('✅ [JOURNAL] Created color template: id="${newTemplate.id}", hex="${newTemplate.hexCode}"');
      return newTemplate.id;
    } catch (e) {
      print('❌ [JOURNAL] Error creating color template: $e');
      // If creation fails and we found a template (even with empty ID), try to use a fallback
      if (existing != null) {
        // Try to find another template with similar color or use first available with valid ID
        final fallback = colorTemplates.firstWhereOrNull(
          (t) => t.id.isNotEmpty && _normalizeHexCode(t.hexCode) == normalizedHex,
        );
        if (fallback != null) {
          print('⚠️ [JOURNAL] Using fallback template: ${fallback.id}');
          return fallback.id;
        }
      }
      // Last resort: use first available template with valid ID
      final firstValid = colorTemplates.firstWhereOrNull((t) => t.id.isNotEmpty);
      if (firstValid != null) {
        print('⚠️ [JOURNAL] Using first available template as fallback: ${firstValid.id}');
        return firstValid.id;
      }
      return null;
    }
  }

  Future<bool> createJournalEntry({
    required String title,
    required String content,
    required Color selectedColor,
    required String mood,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [JOURNAL] Creating journal entry...');
      
      // Find or create color template - ensure we have a valid ID
      final colorTemplateId = await findOrCreateColorTemplate(selectedColor);
      
      if (colorTemplateId == null || colorTemplateId.trim().isEmpty) {
        print('❌ [JOURNAL] Failed to get color template ID, cannot create journal');
        print('❌ [JOURNAL] colorTemplateId value: "$colorTemplateId"');
        errorMessage.value = 'Failed to create color template. Please try again.';
        return false;
      }
      
      final trimmedId = colorTemplateId.trim();
      print('✅ [JOURNAL] Using color template ID: "$trimmedId"');

      final request = CreateJournalRequest(
        title: title,
        content: content,
        colorTemplateId: trimmedId, // Use trimmed ID to avoid whitespace issues
        mood: mood,
        tags: [],
      );
      
      print('📤 [JOURNAL] Sending request: title=${request.title}, colorTemplateId=${request.colorTemplateId}, mood=${request.mood}');

      final createdJournal = await createJournal.call(request);
      
      // Add to list and refresh
      journals.insert(0, createdJournal);
      
      print('✅ [JOURNAL] Journal created successfully with ID: ${createdJournal.id}');
      return true;
    } on ServerException catch (e) {
      print('❌ [JOURNAL] ServerException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [JOURNAL] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      print('❌ [JOURNAL] Unexpected error: $e');
      errorMessage.value = 'Failed to create journal: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateJournalEntry({
    required int journalId,
    required String title,
    required String content,
    required Color selectedColor,
    required String mood,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🔍 [JOURNAL] Updating journal entry $journalId...');
      
      // Find or create color template - ensure we have a valid ID
      final colorTemplateId = await findOrCreateColorTemplate(selectedColor);
      
      if (colorTemplateId == null || colorTemplateId.trim().isEmpty) {
        print('❌ [JOURNAL] Failed to get color template ID, cannot update journal');
        print('❌ [JOURNAL] colorTemplateId value: "$colorTemplateId"');
        errorMessage.value = 'Failed to create color template. Please try again.';
        return false;
      }
      
      final trimmedId = colorTemplateId.trim();
      print('✅ [JOURNAL] Using color template ID: "$trimmedId"');

      final request = UpdateJournalRequest(
        title: title,
        content: content,
        colorTemplateId: trimmedId, // Use trimmed ID to avoid whitespace issues
        mood: mood,
        tags: [],
      );

      final updatedJournal = await updateJournal.call(journalId, request);
      
      // Update in list
      final index = journals.indexWhere((j) => j.id == journalId);
      if (index != -1) {
        journals[index] = updatedJournal;
      } else {
        // If not found, refresh the list
        await fetchJournals(forceRefresh: true);
      }
      
      print('✅ [JOURNAL] Journal updated successfully');
      return true;
    } on ServerException catch (e) {
      print('❌ [JOURNAL] ServerException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } on NetworkException catch (e) {
      print('❌ [JOURNAL] NetworkException: ${e.message}');
      errorMessage.value = e.message;
      return false;
    } catch (e) {
      print('❌ [JOURNAL] Unexpected error: $e');
      errorMessage.value = 'Failed to update journal: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Get color from color template ID
  // This method looks up the color template from the cached list and returns the Color
  Color? getColorFromTemplateId(String? templateId) {
    // Handle empty or null template ID
    if (templateId == null || templateId.isEmpty || templateId.trim().isEmpty) {
      print('⚠️ [JOURNAL] Empty color_template_id, using default color');
      return Colors.white; // Default color
    }
    
    // Look up template from cached list
    final template = colorTemplates.firstWhereOrNull((t) => t.id == templateId.trim());
    if (template == null) {
      print('⚠️ [JOURNAL] Color template not found for ID: $templateId');
      print('📋 [JOURNAL] Available template IDs: ${colorTemplates.map((t) => t.id).join(", ")}');
      return Colors.white; // Fallback to white if template not found
    }
    
    try {
      // Parse hex code to Color
      final hexCode = template.hexCode.replaceFirst('#', '').trim();
      if (hexCode.isEmpty) {
        print('⚠️ [JOURNAL] Empty hex code for template: $templateId');
        return Colors.white;
      }
      
      final colorValue = int.parse(hexCode, radix: 16) + 0xFF000000;
      print('✅ [JOURNAL] Found color for template $templateId: $hexCode -> Color($colorValue)');
      return Color(colorValue);
    } catch (e) {
      print('❌ [JOURNAL] Error parsing hex code "${template.hexCode}" for template $templateId: $e');
      return Colors.white; // Fallback on parse error
    }
  }
  
  // Get color template details by ID (returns full template object)
  ColorTemplate? getColorTemplateById(String? templateId) {
    if (templateId == null || templateId.isEmpty || templateId.trim().isEmpty) {
      return null;
    }
    
    return colorTemplates.firstWhereOrNull((t) => t.id == templateId.trim());
  }

  void clearCache() {
    journals.clear();
    _lastFetchTime = null;
    errorMessage.value = '';
  }
}

