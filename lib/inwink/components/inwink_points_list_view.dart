import 'package:flutter/material.dart';
import 'package:sample_flutter_wemap_inwink/inwink/controllers/inwink_datacontroller.dart';

// Bidi.stripHtmlIfNeeded("<p>Hello World</p>") // import 'package:intl/intl.dart';
String stripHtmlIfNeeded(String text) {
  return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
}

class PointsListView extends StatelessWidget {
  List<dynamic> points;
  final InwinkDataStoreController? store;

  PointsListView({super.key, required this.points, this.store});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: points.length,
      separatorBuilder: (context, index) {
        return const Divider();
      },
      itemBuilder: (context, index) {
        String description = points[index]['emplacement'] ?? 'stand';
        return ListTile(
            leading: const CircleAvatar(),
            title: Text(points[index]['name']),
            subtitle: Text(description),
            onTap: () async {
              return store?.setPoint(points[index]['id']!);
            });
      },
    );
  }
}
