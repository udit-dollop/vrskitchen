class UserModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String dietaryPreference; // Veg, Pure Veg, Jain, Non-Veg
  final String spiceLevel; // Mild, Medium, Spicy
  final List<String> allergies;
  final List<AddressModel> addresses;
  final String selectedAddressId;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.dietaryPreference,
    required this.spiceLevel,
    required this.allergies,
    required this.addresses,
    required this.selectedAddressId,
  });

  AddressModel? get selectedAddress {
    try {
      return addresses.firstWhere((a) => a.id == selectedAddressId);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? dietaryPreference,
    String? spiceLevel,
    List<String>? allergies,
    List<AddressModel>? addresses,
    String? selectedAddressId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      spiceLevel: spiceLevel ?? this.spiceLevel,
      allergies: allergies ?? this.allergies,
      addresses: addresses ?? this.addresses,
      selectedAddressId: selectedAddressId ?? this.selectedAddressId,
    );
  }
}

class AddressModel {
  final String id;
  final String tag; // Home, Office, Other
  final String addressLine;
  final String landmark;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.tag,
    required this.addressLine,
    required this.landmark,
    this.isDefault = false,
  });
}
