import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wemap_sdk/flutter_wemap.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../components/header.dart';
import 'components/inwink_detail_view.dart';
import 'components/inwink_points_list_view.dart';
import 'controllers/inwink_datacontroller.dart';
import 'models/inwink_model.dart';

Future<List<InwinkPoint>> getLocalData() async {
  var jsonText =
      await rootBundle.loadString('assets/sample_viva_filtered.json');
  var data = json.decode(jsonText);
  return data.map<InwinkPoint>((r) => InwinkPoint.fromJson(r)).toList();
}

Future<List<Map<String, dynamic>>> getWemapLocalBinding() async {
  var jsonText =
      await rootBundle.loadString('assets/inwink-test-pinpoints.json');
  var data = json.decode(jsonText);
  List<Map<String, dynamic>> results = data['results']
      .map((result) => result)
      .cast<Map<String, dynamic>>()
      .toList();
  return results;
}

class NewMap extends StatefulWidget {
  final Function(LivemapController)? onMapCreated;
  final GlobalKey key;

  const NewMap({this.onMapCreated, required this.key});

  @override
  State<NewMap> createState() {
    return NewMapState();
  }
}

class NewMapState extends State<NewMap> {
  late LivemapController _mapController;
  late PersistentBottomSheetController? controller;
  PanelController panelController = PanelController();
  PanelController pointPanelController = PanelController();
  late Future<List<InwinkPoint>> futureInwinkpoints;
  InwinkDataStoreController inwinkStore = InwinkDataStoreController();
  bool isPointsListVisible = true;

  void _onMapCreated(LivemapController mapController) {
    _mapController = mapController;
    _mapController.setZoom(zoom: 18);
    inwinkStore.addListener(() async {
      _doFocus();
    });
  }
  void _doFocus(){
    if (inwinkStore.selectedPoint != null) {
      InwinkPoint point = inwinkStore.selectedPoint!;
      dynamic pinpoint = inwinkStore.wemapPoints.firstWhere(
              (element) => element['external_data']['partner_id'] == point.id);

      _mapController.easeTo(
          center: {
            "longitude": pinpoint['longitude'],
            "latitude": pinpoint['latitude'],
          },
          zoom: 18,
          padding: {
            "bottom":
            MediaQuery.of(widget.key.currentContext!).size.height / 2
          });

      Timer(const Duration(milliseconds: 500), () {
        _mapController.setIndoorFeatureState(
            id: pinpoint['id'], state: {"selected": true});

        inwinkStore.callbacks[pinpoint['id']] = () {
          _mapController.setIndoorFeatureState(
              id: pinpoint['id'], state: {"selected": false});
        };
      });
    }
  }

  void _onMapReady() {
    _doFocus();
  }

  @override
  void initState() {
    inwinkStore.addListener(() {
      setState(() {});
    });
    super.initState();
    futureInwinkpoints = getLocalData();
    futureInwinkpoints.then((points) {
      inwinkStore.loadInwinkpoints(points);
    });
    getWemapLocalBinding().then((data) {
      inwinkStore.loadPinpoints(data);
    });
  }

  @override
  void dispose() {
    inwinkStore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Map<String, dynamic> creationParams = <String, dynamic>{
      // inwink test map
      "emmid": 22764,
      "token": "at57ea248c510508.01219386",
    };

    var height = MediaQuery.of(context).size.height;
    var points = inwinkStore.points.map((p) => p.toMap()).toList();
    var store = inwinkStore;
    return Scaffold(
        body: Stack(children: [
      Visibility(
          visible: !isPointsListVisible,
          child: Livemap(
              options: creationParams,
              onMapCreated: _onMapCreated,
              onMapReady: _onMapReady,
              onMapClick: (dynamic coordinates) {
                inwinkStore.flushCallbacks();
              },
              onIndoorFeatureClick: (data) {
                inwinkStore.setPoint(data['externalId']!);
                print("indoorfeatureclicked");
                print("indoorfeatureclicked : $data");
              },
              onIndoorLevelChanged: (date) {
                print("indoorlevel changed");
              })),
      Visibility(
          visible: !isPointsListVisible,
          child: SlidingUpPanel(
            onPanelClosed: () {
              inwinkStore.closePoint();
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            defaultPanelState: PanelState.CLOSED,
            controller: pointPanelController,
            header: Header(
                context: context,
                leading: Container(
                  alignment: Alignment.topLeft,
                  child: TextButton.icon(
                      icon: const Icon(Icons.chevron_left),
                      label: const Text('retour'),
                      onPressed: () {
                        setState(() {
                          isPointsListVisible = !isPointsListVisible;
                        });
                      }),
                )),
            panelBuilder: (controller) => inwinkStore.selectedPoint != null
                ? PanelPointDetailView(
                    controller: controller,
                    point: inwinkStore.selectedPoint!.toMap())
                : Text((inwinkStore.selectedPoint != null).toString()),
            minHeight: inwinkStore.selectedPoint != null ? 70 : 0,
            maxHeight: height * 0.5,
          )),
      Visibility(
          visible: isPointsListVisible,
          child: ListView.separated(
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
                    setState(() {
                      isPointsListVisible = false;
                    });
                    return store?.setPoint(points[index]['id']!);
                  });
            },
          ))
    ]));
  }
}
