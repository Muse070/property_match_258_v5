import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../../model/user_models//user_model.dart';
import '../../../../../repository/user_repository/user_repository.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();
  //
  // final _userRepo = Get.find<UserRepository>();
  //
  // Rx<UserModel?> get currentUser => _userRepo.currentUser;
  //
  //
  // Future<UserModel?> getUserData() async{
  //   return _userRepo.currentUser.value;
  // }
}

