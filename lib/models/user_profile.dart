class UserProfile {
  final String name;
  final String phone;
  final String address;
  final String email;

  UserProfile({
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'address': address,
    'email': email,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    email: json['email'] ?? '',
  );

  bool get isEmpty => name.isEmpty && phone.isEmpty;
}
