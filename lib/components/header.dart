import 'package:flutter/material.dart';

import 'drag_handle.dart';

Widget Header({required BuildContext context, Widget? leading}) => Container(
    decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
    width: MediaQuery.of(context).size.width,
    height: 50.0,
    child: Stack(children: [
      if (leading != null)
        Positioned(
          left: 0,
          child: leading,
        ),
      SizedBox(height: 18),
      buildDragHandle()
    ]));
