import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../model/user_models/agent_model.dart';

class AgentCardWidget extends StatelessWidget {
  final AgentModel? agentDetails;

  const AgentCardWidget({
    super.key, required this.agentDetails,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Card(
        elevation: 2,
        color: Colors.grey[100],
        child: Container(
          padding: EdgeInsets.all(2.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              agentDetails!.imageUrl != null &&
                  agentDetails!.imageUrl!.isNotEmpty
                  ? CircleAvatar(
                radius: 5.w,
                backgroundImage:
                NetworkImage(agentDetails!.imageUrl!),
              )
                  : CircleAvatar(
                radius: 5.w,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person),
              ),
              SizedBox(
                width: 3.w,
              ),
              const Divider(),
              Text(
                "${agentDetails!.firstName} ${agentDetails!.lastName}",
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
