import 'dart:math';

class DefaultProfilePicture {
  static const String cdnBaseUrl = 'https://cdn.flyapp.in';
  static const String dpFlyPath = '/user/DP-fly/';

  static const List<String> defaultProfilePictures = [
    '0_0_640_N.webp',
    '0_0_640_N (1).webp',
    '0_0_640_N (2).webp',
    '0_0_640_N (3).webp',
    '0_0_640_N (4).webp',
    '0_0_640_N (5).webp',
    '0_0_640_N (6).webp',
    '0_0_640_N (7).webp',
    '0_0_640_N (8).webp',
    '0_0_640_N (9).webp',
    '0_0_640_N (10).webp',
    '0_0_640_N (11).webp',
    '0_0_640_N (12).webp',
    '0_0_640_N (13).webp',
    '0_0_640_N (14).webp',
    '0_0_640_N (15).webp',
    '0_0_640_N (16).webp',
    '0_0_640_N (17).webp',
    '0_0_640_N (18).webp',
    '0_0_640_N (19).webp',
    '0_0_640_N (20).webp',
    '0_0_640_N (21).webp',
    '0_0_640_N (22).webp',
    '0_0_640_N (23).webp',
    '0_0_640_N (24).webp',
    '0_0_640_N (25).webp',
    '0_0_640_N (26).webp',
    '0_0_640_N (27).webp',
    '0_0_640_N (28).webp',
    '0_0_640_N (29).webp',
    '0_0_640_N (30).webp',
    '0_0_640_N (31).webp',
    '0_0_640_N (32).webp',
    '0_0_640_N (33).webp',
    '0_0_640_N (34).webp',
    '0_0_640_N (35).webp',
    '0_0_640_N (36).webp',
    '0_0_640_N (37).webp',
    '0_0_640_N (38).webp',
    '0_0_640_N (39).webp',
    '0_0_640_N (40).webp',
    '0_0_640_N (41).webp',
    '0_0_640_N (42).webp',
    '0_0_640_N (43).webp',
    '0_0_640_N (44).webp',
    '0_0_640_N (45).webp',
    '0_0_640_N (46).webp',
    '0_0_640_N (47).webp',
    '0_0_640_N (48).webp',
    '0_0_640_N (49).webp',
    '0_0_640_N (50).webp',
  ];

  static String getRandomProfilePicture(String userId) {
    final random = Random(userId.hashCode);
    final index = random.nextInt(defaultProfilePictures.length);
    final filename = defaultProfilePictures[index];
    return '$cdnBaseUrl$dpFlyPath$filename';
  }

  static String getRandomProfilePicturePath(String userId) {
    final random = Random(userId.hashCode);
    final index = random.nextInt(defaultProfilePictures.length);
    final filename = defaultProfilePictures[index];
    return '$dpFlyPath$filename';
  }
}
