import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'inwink/new_map_view.dart';
import 'old_map_view.dart';

class MapSwitcher extends StatelessWidget {
  final mapKey = GlobalKey();

  MapSwitcher({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Row(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OldMap(key: mapKey)),
                );
              },
              child: const Text("Old Map")),
          const Spacer(),
          ElevatedButton(onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewMap(key: mapKey)),
            );
          }, child: const Text("New Map"))
        ],
      ),
    ));
  }
}
