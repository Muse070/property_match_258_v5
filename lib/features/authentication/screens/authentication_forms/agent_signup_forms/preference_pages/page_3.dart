import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Lottie.network('https://lottie.host/231f09a1-cdb2-4256-a5a0-22c6b6b0de2c/5IGljFkham.json'),
      ),
    );
  }
}
