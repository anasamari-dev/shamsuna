class CatalogCompany {
  const CatalogCompany({
    required this.id,
    required this.name,
    required this.iconUrl,
  });

  final int id; // company_id.
  final String name; // اسم الشركة.
  final String? iconUrl; // رابط الأيقونة من Supabase Storage أو رابط HTTPS.

  factory CatalogCompany.fromMap(Map<String, dynamic> map) {
    return CatalogCompany(
      id: (map['company_id'] as num).toInt(),
      name: map['name'] as String,
      iconUrl: map['icon_url'] as String?,
    );
  }
}
