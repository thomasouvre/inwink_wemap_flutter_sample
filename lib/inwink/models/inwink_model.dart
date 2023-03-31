class InwinkPoint {
  final String id;
  final String? name;
  final String? emplacement;
  final String? affiliatedToId;

  InwinkPoint(
      {required this.id,
      required this.name,
      required this.emplacement,
      this.affiliatedToId});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "emplacement": emplacement,
      "affiliatedToId": affiliatedToId,
    };
  }

  factory InwinkPoint.fromJson(Map<String, dynamic> json) {
    return InwinkPoint(
      id: json['id'],
      name: json['name'],
      emplacement: json['emplacement'],
      affiliatedToId: json['affiliatedToId'],
    );
  }
}
