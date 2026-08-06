class ProposalEntity {
  final String id;
  final String slug;
  final String title;
  final String clientName;
  final String? companyName;
  final double totalValue;
  final String status;
  final DateTime createdAt;
  final int viewCount;

  ProposalEntity({
    required this.id,
    required this.slug,
    required this.title,
    required this.clientName,
    this.companyName,
    required this.totalValue,
    required this.status,
    required this.createdAt,
    required this.viewCount,
  });

  factory ProposalEntity.fromJson(Map<String, dynamic> json) {
    final views = json['views'] as List<dynamic>? ?? [];
    final company = json['company'] as Map<String, dynamic>?;
    return ProposalEntity(
      id: json['id'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      companyName: company?['name'] as String?,
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'DRAFT',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      viewCount: views.length,
    );
  }
}
