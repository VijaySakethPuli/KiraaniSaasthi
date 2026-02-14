import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String id;
  final String name;
  final String qty;
  final String price;
  final DateTime createdAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    required this.createdAt,
  });

  // Convert Firestore Document to InventoryItem
  factory InventoryItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return InventoryItem(
      id: doc.id,
      name: data['name'] ?? '',
      qty: data['qty'] ?? '',
      price: data['price'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert InventoryItem to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'qty': qty,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
