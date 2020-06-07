import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/subscriber.dart';

Future<void> addProfile(Subscriber subscriber, Database db) async {
  await db.insert(
    'profile',
    subscriber.toJson(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> initDB(Subscriber subscriber) async {
  final Future<Database> database = openDatabase(
    join(await getDatabasesPath(), 'subscriber.db'),
    onCreate: (db, version) {
      return db.execute('DROP TABLE IF EXISTS profile;'
          'CREATE TABLE profile('
          'id TEXT PRIMARY KEY, '
          'name TEXT, '
          'owner TEXT,'
          'email TEXT, '
          'phone TEXT, '
          'address TEXT, '
          'latitude REAL, '
          'longitude REAL, '
          'verified INTEGER, '
          'category TEXT, '
          'expiry TEXT'
          'refreshToken TEXT)');
    },
    version: 1,
  );
  await addProfile(subscriber, await database);
}

Future<Subscriber> getProfileFromDB() async {
  final Database database =
      await openDatabase(join(await getDatabasesPath(), 'subscriber.db'));
  final List<Map<String, dynamic>> maps = await database.query('profile');
  return Subscriber.fromJson(maps[0]);
}

Future<void> updateProfile(Subscriber subscriber) async {
  final Database db =
      await openDatabase(join(await getDatabasesPath(), 'subscriber.db'));
  await db.update('profile', subscriber.toJson(),
      where: "id = ?", whereArgs: [subscriber.id]);
}
