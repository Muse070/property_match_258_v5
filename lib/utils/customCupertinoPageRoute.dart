import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomCupertinoPageRoute extends CupertinoPageRoute {
  final Duration transitionDuration;

  CustomCupertinoPageRoute({
    required WidgetBuilder builder,
    this.transitionDuration = const Duration(milliseconds: 800),  // Set your desired duration
  }) : super(builder: builder);

  @override
  Duration get transitionDurations => this.transitionDuration;
}
