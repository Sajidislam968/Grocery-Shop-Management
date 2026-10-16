class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final DateTime? createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'createdAt': createdAt,
    };
  }

  factory Customer.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Customer(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      createdAt: map['createdAt']?.toDate(),
    );
  }
}