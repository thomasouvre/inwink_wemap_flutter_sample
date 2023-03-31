import 'package:flutter/material.dart';

class PanelPointDetailView extends StatelessWidget {
  final ScrollController controller;
  final dynamic point;

  PanelPointDetailView({required this.controller, required this.point});

  @override
  Widget build(BuildContext context) {
    String name = point.containsKey('name') ? point['name'] : '';
    String emplacement =
        point.containsKey('emplacement') ? point['emplacement'] : '';

    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(controller: controller, children: [
          Center(
              child: Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).textTheme.bodyLarge!.fontSize))),
          Text(emplacement),
        ]));
  }
}
