import 'package:flutter/material.dart';
import 'package:sample_flutter_wemap_inwink/inwink/models/inwink_model.dart';

class InwinkDataStoreController extends ChangeNotifier {
  List<InwinkPoint> points = [];
  InwinkPoint? selectedPoint;
  Map<int, VoidCallback> callbacks = {};
  Map<int, Set<String>> markers = {};
  List<Map<String, dynamic>> wemapPoints = [];

  InwinkDataStoreController();

  loadInwinkpoints(List<InwinkPoint> points) {
    this.points = points;
    notifyListeners();
  }

  loadPinpoints(List<Map<String, dynamic>> data) {
    wemapPoints = data;
    notifyListeners();
  }

  closePoint() {
    selectedPoint = null;
    flushCallbacks();
  }

  setPoint(String id) {
    selectedPoint = points.firstWhere((value) => value.id == id);
    notifyListeners();
  }

  popCallbackIfExist(int id) {
    var cb = callbacks.remove(id);
    cb?.call();
  }

  flushCallbacks() {
    for (var callback in callbacks.entries) {
      popCallbackIfExist(callback.key);
    }
    notifyListeners();
  }
}
