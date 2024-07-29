import 'package:flutter/material.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const SizedBox(
           width: 300,
           child: Text(
             "Please submit a copy of your ZIEA document.",
             style: TextStyle(
               fontWeight: FontWeight.w600,
               fontSize: 20,
             ),
           ),
         ),
        const SizedBox(height: 15,),
        const Text(
            "Verification takes approximately 2 working days",
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
        ),
        const SizedBox(height: 65,),
        Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.30,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            border: Border.all(width: 2.5, color: Colors.black),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {  },
                icon: const Icon(
                  Icons.upload_file_rounded,
                  size: 100,
                  color: Color(0xff0071b9),
                ),
              ),
              const Text(
                  "Upload document",
                style: TextStyle(
                  color: Color(0xff0071b9)
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 65,),
      ],
    );
  }
}
