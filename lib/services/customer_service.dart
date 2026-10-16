import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';

class CustomerService {
  final CollectionReference customers =
      FirebaseFirestore.instance.collection('customers');

  // CREATE
  Future<void> addCustomer(Customer customer) async {
    await customers.add(customer.toMap());
  }

  // READ
  Stream<List<Customer>> getCustomers() {
    return customers
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateCustomer(Customer customer) async {
    await customers.doc(customer.id).update(customer.toMap());
  }

  // DELETE
  Future<void> deleteCustomer(String id) async {
    await customers.doc(id).delete();
  }
}