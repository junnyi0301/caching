import 'package:cloud_firestore/cloud_firestore.dart';

class Voucher {
  final String id;
  final String icon;
  final String title;
  final String subtitle;
  final String description;
  final int value;
  final DateTime validFrom;
  final DateTime validUntil;
  final int requiredPoints;
  final String pointsLabel;

  Voucher({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.value,
    required this.validFrom,
    required this.validUntil,
    required this.requiredPoints,
    required this.pointsLabel,
  });

  factory Voucher.fromMap(Map<String, dynamic> m, String docId) {
    final validFromTimestamp = m['validFrom'];
    final validUntilTimestamp = m['validUntil'];

    return Voucher(
      id: docId,
      icon: m['icon'] as String? ?? '',
      title: m['title'] as String? ?? '',
      subtitle: m['subtitle'] as String? ?? '',
      description: m['description'] as String? ?? '',
      value: (m['value'] as int?) ?? 0,
      validFrom: validFromTimestamp is Timestamp
          ? validFromTimestamp.toDate()
          : DateTime.tryParse(validFromTimestamp?.toString() ?? '') ?? DateTime.now(),
      validUntil: validUntilTimestamp is Timestamp
          ? validUntilTimestamp.toDate()
          : DateTime.tryParse(validUntilTimestamp?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 30)),
      requiredPoints: (m['requiredPoints'] as int?) ?? 0,
      pointsLabel: m['pointsLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'icon': icon,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'value': value,
      'validFrom': Timestamp.fromDate(validFrom),
      'validUntil': Timestamp.fromDate(validUntil),
      'requiredPoints': requiredPoints,
      'pointsLabel': pointsLabel,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validUntil);
  }
}
