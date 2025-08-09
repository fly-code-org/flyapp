import 'dart:io';
import 'package:get/get.dart';

class UserProfileController extends GetxController {
  var username = ''.obs;
  var selectedImage = Rxn<File>();
}
