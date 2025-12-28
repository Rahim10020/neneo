class UserModel {
  final String id;
  final String phoneNumber;
  final bool isPro;
  final DateTime? proExpiresAt;
  final String preferredLanguage; // 'fr' or 'ewe'
  final String defaultVehicle; // 'moto' or 'taxi'
  final bool historyEnabled;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  UserModel({
    required this.id,
    required this.phoneNumber,
    this.isPro = false,
    this.proExpiresAt,
    this.preferredLanguage = 'fr',
    this.defaultVehicle = 'moto',
    this.historyEnabled = false,
    required this.createdAt,
    this.lastLoginAt,
  });

  // Check if Pro subscription is active
  bool get isProActive {
    if (!isPro || proExpiresAt == null) return false;
    return DateTime.now().isBefore(proExpiresAt!);
  }

  // Days remaining in Pro subscription
  int get proRemainingDays {
    if (!isProActive) return 0;
    return proExpiresAt!.difference(DateTime.now()).inDays;
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'isPro': isPro,
      'proExpiresAt': proExpiresAt?.toIso8601String(),
      'preferredLanguage': preferredLanguage,
      'defaultVehicle': defaultVehicle,
      'historyEnabled': historyEnabled,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      isPro: json['isPro'] as bool? ?? false,
      proExpiresAt: json['proExpiresAt'] != null
          ? DateTime.parse(json['proExpiresAt'] as String)
          : null,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'fr',
      defaultVehicle: json['defaultVehicle'] as String? ?? 'moto',
      historyEnabled: json['historyEnabled'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  // Copy with updated fields
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    bool? isPro,
    DateTime? proExpiresAt,
    String? preferredLanguage,
    String? defaultVehicle,
    bool? historyEnabled,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isPro: isPro ?? this.isPro,
      proExpiresAt: proExpiresAt ?? this.proExpiresAt,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      defaultVehicle: defaultVehicle ?? this.defaultVehicle,
      historyEnabled: historyEnabled ?? this.historyEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // Create guest user
  factory UserModel.guest() {
    return UserModel(
      id: 'guest',
      phoneNumber: '',
      isPro: false,
      preferredLanguage: 'fr',
      defaultVehicle: 'moto',
      historyEnabled: false,
      createdAt: DateTime.now(),
    );
  }
}
