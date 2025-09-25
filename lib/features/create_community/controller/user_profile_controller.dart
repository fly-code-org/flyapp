import 'dart:io';
import 'package:get/get.dart';

class CommunityController extends GetxController {
  var username = ''.obs;
  var selectedImage = Rxn<File>();
}

class CommunityMediaController extends GetxController {
  RxBool showFullMedia = false.obs;
  RxInt currentTabIndex = 0.obs; // 0 = New, 1 = Popular

  void toggleMediaView() => showFullMedia.value = !showFullMedia.value;
  void setTabIndex(int index) => currentTabIndex.value = index;
}
