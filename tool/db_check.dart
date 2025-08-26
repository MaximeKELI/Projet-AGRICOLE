import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:app_agrigeo/screens/database_helper.dart';

Future<void> main() async {
  // Init FFI for desktop run
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbh = DatabaseHelper();
  final path = await dbh.getDatabasePath();
  await dbh.database; // ensure init

  final info = await dbh.getUsersTableInfo();
  final count = await dbh.getUserCount();
  final users = await dbh.getAllUsers();

  stdout.writeln('DB Path: ' + path);
  stdout.writeln('users schema: ' + info.toString());
  stdout.writeln('users count: ' + count.toString());
  stdout.writeln('sample users: ' + users.toString());
} 