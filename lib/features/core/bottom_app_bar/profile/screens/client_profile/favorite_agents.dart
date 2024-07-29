import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:property_match_258_v5/features/core/bottom_app_bar/profile/screens/agent_profile/agent_details.dart';
import 'package:sizer/sizer.dart';

import '../../../../../../model/user_models/agent_model.dart';
import '../../../../../../model/user_models/user_model.dart';
import '../../../../../../repository/user_repository/agent_repository.dart';
import '../../../../../../repository/user_repository/user_repository.dart';

class FavoriteAgents extends StatefulWidget {
  const FavoriteAgents({super.key});

  @override
  State<FavoriteAgents> createState() => _FavoriteAgentsState();
}

class _FavoriteAgentsState extends State<FavoriteAgents> {
  final _userRepo = Get.find<UserRepository>();
  final _agentRepo = Get.find<AgentRepository>();

  late Future<UserModel?>? userDataFuture;

  @override
  void initState() {
    super.initState();
    userDataFuture = Future.value(_userRepo.currentUser.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: IconTheme(
            data: IconThemeData(
              size: 14.sp,
              color: Colors.white,
            ),
            child: const FaIcon(FontAwesomeIcons.angleLeft),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          "Favorite Agents",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: "Roboto",
            fontSize: 14.sp,
          ),
        ),
        backgroundColor: Colors.black87,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Confirm Delete'),
                    content: Text('Are you sure you want to delete all favorite agents?'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Delete All'),
                        onPressed: () async {
                          // Call your method to delete all favorite agents here
                          await _agentRepo.removeAllFavoriteAgents();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
            icon: IconTheme(
              data: IconThemeData(
                color: Colors.white,
                size: 12.sp,
              ),
              child: FaIcon(FontAwesomeIcons.trash),
            ),
          ),
        ],
      ),
      body: Obx(() =>
        Container(
          color: Colors.grey.shade200,
          padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.h),
          child: ListView.builder(
            itemCount: _agentRepo.favoriteAgents.length,
            itemBuilder: (context, index) {
              final agent = _agentRepo.favoriteAgents[index];
              return SizedBox(
                height: 15.h,
                width: 100.w,
                child: agentCard(agent),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget agentCard(AgentModel agentModel) {
    return Card(
      color: Colors.white,
      elevation: 0.2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        agentModel.imageUrl != null && agentModel.imageUrl!.isNotEmpty
            ? CircleAvatar(
                radius: 10.w,
                backgroundImage: NetworkImage(agentModel.imageUrl!),
              )
            : ProfilePicture(
                name: "${agentModel.firstName} ${agentModel.lastName}",
                radius: 8.w,
                fontsize: 14.sp),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${agentModel.agencyName}", style: TextStyle(fontSize: 12.sp)),
            Text(
              "${agentModel.firstName} ${agentModel.lastName}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, size: 14.sp),
          onPressed: () {
            Get.to(AgentDetails(agentDetails: agentModel));
          },
        )
      ]),
    );
  }
}
