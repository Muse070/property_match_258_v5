import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

class ClientPage3 extends StatefulWidget {
  @override
  final Key key;
  const ClientPage3({required this.key}) : super(key: key);

  @override
  State<ClientPage3> createState() => ClientPage3State();
}

class ClientPage3State extends State<ClientPage3> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        child: Lottie.network('https://lottie.host/231f09a1-cdb2-4256-a5a0-22c6b6b0de2c/5IGljFkham.json'),
      ),
    );
  }

  void saveState() {
    _formKey.currentState?.save();
  }
}
