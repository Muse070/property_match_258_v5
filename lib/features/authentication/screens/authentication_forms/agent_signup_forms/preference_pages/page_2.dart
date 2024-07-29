import 'package:flutter/material.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _cardWidget(),
      ],
    );
  }

  Widget _cardWidget() {
    return const SizedBox(
      width: double.maxFinite,
      height: 100,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Note:",
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15
              ),
            ),
            Text(
              "A one time agent signup fee of \$99 is charged.",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15
              ),
            ),
            Text(
              "Thereafter, a monthly subscription of \$9 is charged",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 15
              ),
            ),
          ],
        ),
      ),
    );
  }
}
