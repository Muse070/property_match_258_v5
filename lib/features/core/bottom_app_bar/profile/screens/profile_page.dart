import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../model/user_models/user_model.dart';
import '../../../../../repository/user_repository/user_repository.dart';
import 'agent_profile/agent_profile_page.dart';
import 'client_profile/client_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String account = 'client';
  final UserRepository _userRepository = UserRepository.instance;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  Future<void> _getUserDetails() async {
    user = _userRepository.currentUser.value;
    setState(() {}); // Trigger a UI rebuild after user data is fetched
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: account == user?.userType ? const ClientProfilePage() : const AgentProfilePage(),
      ),
    );
    }
}
