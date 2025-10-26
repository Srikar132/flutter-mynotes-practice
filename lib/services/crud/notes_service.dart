import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenExcepton implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class DatabaseNotOpened implements Exception {}

class CouldNotDeleteUser implements Exception {}

class CouldNotFindUser implements Exception {}

class CouldNotUpdateUser implements Exception {}

class UserEmailAlreadyExists implements Exception {}

class NotesService {
  Database? _db;

  DatabaseUser? _user;

  List<DatabaseNotes> _notes = [];

  /// MAKING NOTES SERVICE 'SINGLETON'
  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }
  factory NotesService() => _shared;

  /// CACHE NOTES
  late final StreamController<List<DatabaseNotes>> _notesStreamController;

  Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;

  Future<void> _cacheNotesForUser({required int userId}) async {
    // GET ALL NOTES FOR SPECIFIC USER
    final notes = await getAllNotesForUser(userId: userId);

    // UPDATE CACHE
    _notes = notes;

    // NOTIFY STREAM CONTROLLER
    _notesStreamController.add(_notes);
  }

  Database _getDatabaseOrThrow() {
    final db = _db;

    if (db == null) {
      throw DatabaseNotOpened();
    }

    return db;
  }

  Future<void> _ensureDatabase() async {
    try {
      await open();
      // ignore: empty_catches
    } on DatabaseAlreadyOpenExcepton {}
  }

  /// Opening the databse connection
  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenExcepton();
    }

    try {
      final docPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute('PRAGMA foreign_keys = ON');

      // create user table
      await db.execute(createUserTable);

      // create notes table
      await db.execute(createNotesTable);

      // cache notes all notes first for specific user
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  /// Closing the databse connection
  Future<void> close() async {
    final db = _db;

    if (db == null) {
      throw DatabaseNotOpened();
    }

    await db.close();
    _db = null;
  }

  /// USER REALTED CRUD
  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    try {
      final user = await getUser(email: email);
      if (setAsCurrentUser) _user = user;
      _cacheNotesForUser(userId: user.id);
      return user;
    } on CouldNotFindUser {
      final newUser = await createUser(email: email);
      if (setAsCurrentUser) _user = newUser;
      _cacheNotesForUser(userId: newUser.id);
      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();

    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      throw CouldNotFindUser();
    }

    return DatabaseUser.fromRow(result.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    final userId = await db.insert(userTable, {'email': email.toLowerCase()});

    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  /**
   * NOTES REPOSITORY
   */

  /// CREATE NEW NOTE
  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();

    // make sure owner exists in the database with the correct id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    // create the note
    final noteId = await db.insert(notesTable, {
      'user_id': owner.id,
      'text': '',
      'title': '',
    });

    final note = DatabaseNotes(
      id: noteId,
      userId: owner.id,
      text: '',
      title: '',
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }

  /// GET ALL NOTES FOR USER
  Future<List<DatabaseNotes>> getAllNotesForUser({required int userId}) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();

    final result = await db.query(
      notesTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((note) => DatabaseNotes.fromRow(note)).toList();
  }

  /// GET NOTE BY ID
  Future<DatabaseNotes> getNote({required int id}) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();

    final notes = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    }

    final note = DatabaseNotes.fromRow(notes.first);

    _notes.removeWhere((note) => note.id == id);
    _notes.add(note);

    _notesStreamController.add(_notes);

    return note;
  }

  /// UPDATE NOTE
  Future<DatabaseNotes> updateNote({
    required DatabaseNotes note,
    required String title,
    required String text,
  }) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);

    final updatedCount = await db.update(
      notesTable,
      {'text': text, 'title': title},
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatedCount == 0) {
      throw CouldNotUpdateNote();
    }

    return await getNote(id: note.id);
  }

  /// DELETE NOTE BY ID
  Future<void> deleteNote({required int id}) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();

    final deletedCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }

    _notes.removeWhere((note) => note.id == id);
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNotes() async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();

    final numberOfDeletions = await db.delete(
      notesTable,
      where: 'user_id = ?',
      whereArgs: [_user?.id],
    );

    _notes = [];
    _notesStreamController.add(_notes);

    return numberOfDeletions;
  }

  // search notes
  Future<List<DatabaseNotes>> searchNotes({
    required  String email,
    required String query,
  }) async {
    await _ensureDatabase();
    final db = _getDatabaseOrThrow();

    final user = await getUser(email: email);
    final userId = user.id;

    final result = await db.query(
      notesTable,
      where: 'user_id = ? AND (title LIKE ? OR text LIKE ?)',
      whereArgs: [userId, '%$query%', '%$query%'],
    );

    return result.map((note) => DatabaseNotes.fromRow(note)).toList();
  }


}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({required this.id, required this.email});

  DatabaseUser.fromRow(Map<String, Object?> map)
    : id = map['id'] as int,
      email = map['email'] as String;

  @override
  String toString() => 'User, ID = $id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final String title;

  const DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.title,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
    : id = map['id'] as int,
      userId = map['user_id'] as int,
      text = map['text'] as String,
      title = map['title'] as String;

  @override
  String toString() => 'Note, ID = $id, userId = $userId, text = $text';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// CONSTANTS
const dbName = 'notes.db';
const notesTable = 'note';
const userTable = 'user';

// SCHEMAS
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
    "id"	INTEGER NOT NULL,
    "email"	TEXT NOT NULL UNIQUE,
    PRIMARY KEY("id" AUTOINCREMENT)
  );''';
const createNotesTable = '''CREATE TABLE IF NOT EXISTS "note" (
    "id"	INTEGER NOT NULL,
    "user_id"	INTEGER NOT NULL,
    "text"	TEXT,
    "title" TEXT,
    PRIMARY KEY("id" AUTOINCREMENT),
    FOREIGN KEY("user_id") REFERENCES "user"("id")
  );''';