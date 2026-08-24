/// Matches the API response structure exactly.
class RequestModel {
  final String id;
  final String ref;
  final String status; // approved | complete | rejected | pending
  final String serviceName;

  // â”€â”€ Approved â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final String? sector;
  final String? approvedAt;
  final String? deliveryLocation;
  final String? pickupTime;

  // â”€â”€ Completed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final String? receivedAt;

  // â”€â”€ Rejected â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final String? rejectionReason;

  // â”€â”€ Pending â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final String? createdAt;

  // â”€â”€ Detail fields â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final String? orgName;
  final String? orgLogo;
  final String? serviceType;
  final int? familyMembers;
  final String? imageUrl;

  const RequestModel({
    required this.id,
    required this.ref,
    required this.status,
    required this.serviceName,
    this.sector,
    this.approvedAt,
    this.deliveryLocation,
    this.pickupTime,
    this.receivedAt,
    this.rejectionReason,
    this.createdAt,
    this.orgName,
    this.orgLogo,
    this.serviceType,
    this.familyMembers,
    this.imageUrl,
  });

  factory RequestModel.fromJson(Map<String, dynamic> j) => RequestModel(
        id: j['id']?.toString() ?? '${DateTime.now().millisecondsSinceEpoch}',
        ref: j['ref']?.toString() ?? '',
        status: _norm(j['status']?.toString() ?? ''),
        serviceName: j['service_name']?.toString() ?? '',
        sector: j['sector']?.toString(),
        approvedAt: j['approved_at']?.toString(),
        deliveryLocation:
            j['delivery_location']?.toString() ?? j['sector']?.toString(),
        pickupTime: j['pickup_time']?.toString(),
        receivedAt: j['received_at']?.toString(),
        rejectionReason: j['rejection_reason']?.toString(),
        createdAt: j['created_at']?.toString(),
        orgName: j['org_name']?.toString(),
        orgLogo: j['org_logo']?.toString(),
        serviceType: j['service_type']?.toString(),
        familyMembers: j['family_members'] is int
            ? j['family_members'] as int
            : int.tryParse(
                j['family_members']?.toString() ?? '',
              ),
        imageUrl: j['image_url']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ref': ref,
        'status': status,
        'service_name': serviceName,
        if (sector != null) 'sector': sector,
        if (approvedAt != null) 'approved_at': approvedAt,
        if (deliveryLocation != null) 'delivery_location': deliveryLocation,
        if (pickupTime != null) 'pickup_time': pickupTime,
        if (receivedAt != null) 'received_at': receivedAt,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (createdAt != null) 'created_at': createdAt,
        if (orgName != null) 'org_name': orgName,
        if (orgLogo != null) 'org_logo': orgLogo,
        if (serviceType != null) 'service_type': serviceType,
        if (familyMembers != null) 'family_members': familyMembers,
        if (imageUrl != null) 'image_url': imageUrl,
      };

  RequestModel copyWith({
    String? id,
    String? ref,
    String? status,
    String? serviceName,
    String? sector,
    String? approvedAt,
    String? deliveryLocation,
    String? pickupTime,
    String? receivedAt,
    String? rejectionReason,
    String? createdAt,
    String? orgName,
    String? orgLogo,
    String? serviceType,
    int? familyMembers,
    String? imageUrl,
  }) =>
      RequestModel(
        id: id ?? this.id,
        ref: ref ?? this.ref,
        status: status ?? this.status,
        serviceName: serviceName ?? this.serviceName,
        sector: sector ?? this.sector,
        approvedAt: approvedAt ?? this.approvedAt,
        deliveryLocation: deliveryLocation ?? this.deliveryLocation,
        pickupTime: pickupTime ?? this.pickupTime,
        receivedAt: receivedAt ?? this.receivedAt,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        createdAt: createdAt ?? this.createdAt,
        orgName: orgName ?? this.orgName,
        orgLogo: orgLogo ?? this.orgLogo,
        serviceType: serviceType ?? this.serviceType,
        familyMembers: familyMembers ?? this.familyMembers,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  static String _norm(String s) {
    final v = s.toLowerCase().trim();
    return v == 'completed' ? 'complete' : v;
  }

  // Legacy getters kept for compatibility
  String get refNumber => ref.replaceAll('REF: ', 'REF-');

  String? get aidType => serviceName.isNotEmpty ? serviceName : null;

  String? get center => deliveryLocation ?? sector;

  String? get pickupDate => approvedAt ?? receivedAt;

  String? get submittedTime => createdAt?.replaceAll('Submitted ', '');

  int? get sufficesFor => familyMembers;

  String? get organizationName => orgName;

  String? get organizationLogo => orgLogo;

  String? get title => serviceName.isNotEmpty ? serviceName : 'Aid Request';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is RequestModel && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'RequestModel(ref:$ref status:$status service:$serviceName)';
}
