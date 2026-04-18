/// Parsed display data for MHP profile screen from GET /mhp/.../profile response.
class MhpProfileDisplay {
  final String userName;
  final String bio;
  final String picturePath;
  final String locationString;
  final String memberSinceString;
  final String whoIAm;
  final String howICanHelp;
  final String whatToExpect;
  final List<Map<String, dynamic>> availableSlots;
  final List<Map<String, dynamic>> appointments;
  final String? communityId;
  /// From GET self profile: server-backed Google Calendar link state (no tokens).
  final bool googleCalendarConnected;
  /// `active` | `reauth_required` when [googleCalendarConnected] is true.
  final String? googleCalendarStatus;

  const MhpProfileDisplay({
    required this.userName,
    required this.bio,
    required this.picturePath,
    required this.locationString,
    required this.memberSinceString,
    this.whoIAm = '',
    this.howICanHelp = '',
    this.whatToExpect = '',
    this.availableSlots = const [],
    this.appointments = const [],
    this.communityId,
    this.googleCalendarConnected = false,
    this.googleCalendarStatus,
  });

  /// Builds display from API response map. [userName] comes from JWT (pass separately).
  factory MhpProfileDisplay.fromMap(
    Map<String, dynamic> map, {
    required String userName,
  }) {
    final bio = _string(map['bio']);
    final picturePath = _string(map['picture_path']);

    String locationString = '';
    final locationDetails = map['location_details'];
    if (locationDetails is Map<String, dynamic>) {
      final parts = <String>[
        _string(locationDetails['city']),
        _string(locationDetails['state']),
        _string(locationDetails['country']),
      ].where((s) => s.isNotEmpty);
      locationString = parts.join(', ');
    }
    if (locationString.isEmpty && map['geo_location'] is Map) {
      final geo = map['geo_location'] as Map<String, dynamic>;
      locationString = _string(geo['formatted_address'] ?? geo['address']);
    }

    String memberSinceString = '';
    final createdAt = map['created_at'];
    if (createdAt != null) {
      DateTime? dt;
      if (createdAt is String) {
        dt = DateTime.tryParse(createdAt);
      } else if (createdAt is Map && createdAt.containsKey('\$date')) {
        final d = createdAt['\$date'];
        if (d is String) dt = DateTime.tryParse(d);
      }
      if (dt != null) {
        const months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December',
        ];
        memberSinceString = '${months[dt.month - 1]}, ${dt.year}';
      }
    }

    final about = map['about'];
    String whoIAm = '', howICanHelp = '', whatToExpect = '';
    if (about is Map<String, dynamic>) {
      whoIAm = _string(about['who_i_am']);
      howICanHelp = _string(about['how_i_can_help']);
      whatToExpect = _string(about['what_to_expect']);
    }

    final connect = map['connect'];
    List<Map<String, dynamic>> availableSlots = [];
    List<Map<String, dynamic>> appointments = [];
    if (connect is Map<String, dynamic>) {
      final slots = connect['available_slots'];
      if (slots is List) {
        for (final e in slots) {
          if (e is Map<String, dynamic>) {
            availableSlots.add(Map.from(e));
          }
        }
      }
      final appts = connect['appointment'];
      if (appts is List) {
        for (final e in appts) {
          if (e is Map<String, dynamic>) {
            appointments.add(Map.from(e));
          }
        }
      }
    }

    String? communityId;
    final cid = map['community_id'];
    if (cid != null && cid is String) communityId = cid;

    final displayFromApi = _string(map['display_name']);
    final resolvedName = displayFromApi.isNotEmpty
        ? displayFromApi
        : (userName.isNotEmpty ? userName : 'MHP');

    final gcc = map['google_calendar_connected'];
    final googleCalendarConnected = gcc == true;
    final gcsRaw = map['google_calendar_status'];
    final String? googleCalendarStatus = gcsRaw is String && gcsRaw.trim().isNotEmpty
        ? gcsRaw.trim()
        : null;

    return MhpProfileDisplay(
      userName: resolvedName,
      bio: bio,
      picturePath: picturePath,
      locationString: locationString,
      memberSinceString: memberSinceString,
      whoIAm: whoIAm,
      howICanHelp: howICanHelp,
      whatToExpect: whatToExpect,
      availableSlots: availableSlots,
      appointments: appointments,
      communityId: communityId,
      googleCalendarConnected: googleCalendarConnected,
      googleCalendarStatus: googleCalendarStatus,
    );
  }

  static String _string(dynamic v) {
    if (v == null) return '';
    if (v is String) return v.trim();
    return v.toString().trim();
  }
}
