class UserModel {
  final String id;
  final String name;
  final double dailyWaterGoal; // Water goal in milliliters

  UserModel({
    required this.id,
    required this.name,
    required this.dailyWaterGoal,
  });

  // Convert UserModel to a Map (for Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dailyWaterGoal': dailyWaterGoal,
    };
  }

  // Create UserModel from a Map (for Firebase)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      dailyWaterGoal: (map['dailyWaterGoal'] ?? 0).toDouble(),
    );
  }
}
