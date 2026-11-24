class Vitrine {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? contactPhone;
  final String? contactEmail;
  final String? address;
  final bool isActive;

  const Vitrine({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.contactPhone,
    this.contactEmail,
    this.address,
    required this.isActive,
  });

  factory Vitrine.fromJson(Map<String, dynamic> j) => Vitrine(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        description: j['description'] as String? ?? '',
        logoUrl: j['logo_url'] as String?,
        contactPhone: j['contact_phone'] as String?,
        contactEmail: j['contact_email'] as String?,
        address: j['address'] as String?,
        isActive: j['is_active'] as bool? ?? true,
      );
}
