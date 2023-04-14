import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wemap_sdk/flutter_wemap.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'components/header.dart';
import 'inwink/models/inwink_model.dart';
import 'inwink/components/inwink_detail_view.dart';
import 'inwink/components/inwink_points_list_view.dart';
import 'inwink/controllers/inwink_datacontroller.dart';

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

class OldMap extends StatefulWidget {
  final Function(LivemapController)? onMapCreated;
  final GlobalKey key;
  const OldMap({this.onMapCreated, required this.key});

  @override
  State<OldMap> createState() {
    return OldMapState();
  }
}

class OldMapState extends State<OldMap> {
  late final LivemapController _mapController;
  late PersistentBottomSheetController? controller;
  PanelController panelController = PanelController();
  PanelController pointPanelController = PanelController();
  late Future<List<InwinkPoint>> futureInwinkpoints;
  InwinkDataStoreController inwinkStore = InwinkDataStoreController();

  void _onMapCreated(LivemapController mapController) {
    inwinkStore.addListener(() async {
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

            pointPanelController.close().then((_) {
              panelController
                  .show()
                  .then((_) => panelController.animatePanelToSnapPoint());
            });
          };

          panelController.close().then((_) {
            pointPanelController.open();
            panelController.hide();
          });
        });
      }
    });

    setState(() {
      _mapController = mapController;
    });
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
      panelController.animatePanelToSnapPoint();
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

    return Scaffold(
      body: Stack(children: [
        Livemap(
          options: creationParams,
          onMapCreated: _onMapCreated,
          onMapReady: () {
            _mapController.setZoom(zoom: 18);
          },
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
          },
        ),
        SlidingUpPanel(
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
                      inwinkStore.closePoint();
                    }),
              )),
          panelBuilder: (controller) => inwinkStore.selectedPoint != null
              ? PanelPointDetailView(
              controller: controller,
              point: inwinkStore.selectedPoint!.toMap())
              : Text((inwinkStore.selectedPoint != null).toString()),
          minHeight: inwinkStore.selectedPoint != null ? 70 : 0,
          maxHeight: height * 0.5,
        ),
        SlidingUpPanel(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
          controller: panelController,
          header: Header(
              context: context,
              leading: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                            "${inwinkStore.points.length} résultat${inwinkStore.points.length > 1 ? "s" : ""}"),
                      ]))),
          panel: FutureBuilder<List<InwinkPoint>>(
            future: futureInwinkpoints,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var points = snapshot.data!;
                return PointsListView(
                  points: points.map((p) => p.toMap()).toList(),
                  store: inwinkStore,
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return const CircularProgressIndicator();
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          minHeight: 70,
          maxHeight: height * 0.8,
          snapPoint: 150 / height * 0.8,
        )
      ])
    );
  }
}
