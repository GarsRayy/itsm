class ServiceCatalog {
  final int id;
  final String code;
  final String name;
  final String provider;

  const ServiceCatalog({
    required this.id,
    required this.code,
    required this.name,
    required this.provider,
  });

  factory ServiceCatalog.fromMap(Map<String, dynamic> map) {
    return ServiceCatalog(
      id: map['id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
      provider: map['provider'] as String,
    );
  }
}

class ServiceItem {
  final int id;
  final int catalogId;
  final String code;
  final String name;
  final String requestType;

  const ServiceItem({
    required this.id,
    required this.catalogId,
    required this.code,
    required this.name,
    required this.requestType,
  });

  factory ServiceItem.fromMap(Map<String, dynamic> map) {
    return ServiceItem(
      id: map['id'] as int,
      catalogId: map['catalog_id'] as int,
      code: map['code'] as String,
      name: map['name'] as String,
      requestType: map['request_type'] as String,
    );
  }
}
