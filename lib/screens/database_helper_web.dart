import 'package:hive_flutter/hive_flutter.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<void> ensureInitialized() async {
    if (!Hive.isBoxOpen('users_box')) {
      await Hive.openBox('users_box');
    }
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    await ensureInitialized();
    final box = Hive.box('users_box');
    final email = user['email'] as String;
    await box.put(email, user);
    return 1;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    await ensureInitialized();
    final box = Hive.box('users_box');
    final data = box.get(email);
    if (data == null) return null;
    return Map<String, dynamic>.from(data as Map);
  }

  // Diagnostic helpers
  Future<String> getDatabasePath() async => 'hive://users_box';
  Future<List<Map<String, dynamic>>> getUsersTableInfo() async => [
        {'name': 'id'},
        {'name': 'fullName'},
        {'name': 'email'},
        {'name': 'password'},
      ];
  Future<int> getUserCount() async {
    await ensureInitialized();
    return Hive.box('users_box').length;
  }
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    await ensureInitialized();
    final box = Hive.box('users_box');
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
} 