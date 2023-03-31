import 'package:flutter/material.dart';

Widget buildDragHandle() => Center(
      child: Container(
        width: 30,
        height: 5,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
      ),
    );
