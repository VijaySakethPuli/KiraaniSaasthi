import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory_item.dart';

class FirestoreService {
  final CollectionReference _inventoryCollection =
      FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: 'kiraana').collection('inventory');

  // Add Item
  Future<void> addInventoryItem(Map<String, dynamic> data) async {
    await _inventoryCollection.add({
      'name': data['name'],
      'qty': data['qty'],
      'price': data['price'],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get Stream of Items
  Stream<List<InventoryItem>> getInventoryStream() {
    return _inventoryCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return InventoryItem.fromFirestore(doc);
      }).toList();
    });
  }

  // Delete Item
  Future<void> deleteItem(String id) async {
    await _inventoryCollection.doc(id).delete();
  }

  // Update Item
  Future<void> updateInventoryItem(String id, Map<String, dynamic> data) async {
    await _inventoryCollection.doc(id).update({
      'name': data['name'],
      'qty': data['qty'],
      'price': data['price'],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
