import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static Database? database;

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }
  Future<Database?> get db async {
    database ??= await initializeDatabase();
    return database;
  }

  // Removed erroneous code block here.
  Future<Database> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'chat_app.db');
    database = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        // enable foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDatabase,
    );
    return database!;
  }

  void _createDatabase(Database db, int newVersion) async {
    await db.execute('''
          CREATE TABLE IF NOT EXISTS user(
            id INTEGER PRIMARY KEY,
            username TEXT DEFAULT '',
            email TEXT DEFAULT '',
            password TEXT DEFAULT '',
            first_name TEXT DEFAULT '',
            last_name TEXT DEFAULT '',
            avatar TEXT DEFAULT NULL,
            bio TEXT DEFAULT '',
            birthday TEXT DEFAULT '',
            gender TEXT DEFAULT '',
            phone_number TEXT DEFAULT '',
            date_joined TEXT DEFAULT CURRENT_TIMESTAMP,
            last_login TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
    await db.execute('''
          CREATE TABLE IF NOT EXISTS Chat (
            id INTEGER PRIMARY KEY,
            user1_id INTEGER NOT NULL,
            user2_id INTEGER NOT NULL,
            last_message TEXT DEFAULT '',
            unread_count INTEGER DEFAULT 0,
            last_message_time TEXT DEFAULT CURRENT_TIMESTAMP,
            avatar TEXT DEFAULT NULL,

            FOREIGN KEY (user1_id) REFERENCES user(id) ON DELETE CASCADE,
            FOREIGN KEY (user2_id) REFERENCES user(id) ON DELETE CASCADE
          )
        ''');
    await db.execute('''
          CREATE TABLE IF NOT EXISTS Message (
            id INTEGER PRIMARY KEY,
            chat_id INTEGER NOT NULL,
            sender_id INTEGER NOT NULL,
            content TEXT DEFAULT '',
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
            is_read INTEGER DEFAULT 0,
            FOREIGN KEY (chat_id) REFERENCES Chat(id) ON DELETE CASCADE,
            FOREIGN KEY (sender_id) REFERENCES user(id) ON DELETE CASCADE
          )
        ''');
    await db.execute('''
          CREATE TABLE IF NOT EXISTS FeveritChat (
          id INTEGER PRIMARY KEY,
          FOREIGN KEY (id) REFERENCES Chat(id) ON DELETE CASCADE
          )
        ''');
  }

  Future<List<Map<String, dynamic>>> getall(String table) async {
    Database? db = await this.db;
    var result = await db!.query(table);

    return result.isNotEmpty ? result : [];
  }

  Future<List<Map<String, dynamic>>> getallmessage(String table, int id) async {
    Database? db = await this.db;
    var result = await db!.query(table, where: 'chat_id = ?', whereArgs: [id]);
    return result;
  }

  Future<int> InsertOrUpadate(Map<String, dynamic> row, String table) async {
    Database? db = await this.db;
    int result;
    if (!(await idExists(table, row['id']))) {
      result = await db!.insert(
        table,
        row,
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } else {
      result = await db!.update(
        table,
        row,
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
    return result;
  }

  Future<bool> idExists(String table, int id) async {
    final db = await this.db;
    final result = await db!.query(table, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  Future<int> update(Map<String, dynamic> row, String table) async {
    Database? db = await this.db;
    int id = row['id'];
    return await db!.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    Database? db = await this.db;
    return await db!.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearTable(String table) async {
    Database? db = await this.db;
    return await db!.delete(table);
  }

  Future<void> BulkInsert(List<Map<String, dynamic>> rows, String table) async {
    final db = await this.db;
    final batch = db!.batch();
    for (var row in rows) {
      final exists = await idExists(table, row['id']);
      if (!exists) {
        batch.insert(table, row, conflictAlgorithm: ConflictAlgorithm.replace);
      } else {
        batch.update(table, row, where: 'id = ?', whereArgs: [row['id']]);
      }
    }
    await batch.commit(noResult: true);
  }

  Future<Map<String, dynamic>?> getById(String table, int id) async {
    final db = await this.db;
    final result = await db!.query(table, where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getChatsWithUsers() async {
    final db = await this.db;
    // This query joins the Chat table with the user table twice to get details for both users.
    final List<Map<String, dynamic>> result = await db!.rawQuery('''
      SELECT
        C.id AS chat_id,
        C.last_message,
        C.last_message_time,
        U1.id AS user1_id,
        U1.username AS user1_username,
        U1.avatar AS user1_avatar,
        U1.first_name AS user1_first_name,
        U1.last_name AS user1_last_name,
        U1.bio AS user1_bio,
        U1.email AS user1_email,
        U1.birthday AS user1_birthday,
        U1.gender AS user1_gender,
        U1.phone_number AS user1_phone_number,

        U2.id AS user2_id,
        U2.username AS user2_username,
        U2.avatar AS user2_avatar,
        U2.first_name AS user2_first_name,
        U2.last_name AS user2_last_name,
        U2.bio AS user2_bio,
        U2.email AS user2_email,
        U2.birthday AS user2_birthday,
        U2.gender AS user2_gender,
        U2.phone_number AS user2_phone_number

      FROM Chat AS C
      INNER JOIN user AS U1 ON C.user1_id = U1.id
      INNER JOIN user AS U2 ON C.user2_id = U2.id
    ''');
    return result;
  }

  Future<List<Map<String, dynamic>>> getMessagesWithUsers(int chatId) async {
    final db = await this.db;
    // This query joins Message with User (for sender) and Chat (for chat details).
    final List<Map<String, dynamic>> result = await db!.rawQuery(
      '''
      SELECT
        M.id AS message_id,
        M.chat_id,
        M.content,
        M.timestamp,
        M.is_read,

        S.id AS sender_id,
        S.username AS sender_username,
        S.email AS sender_email,
        S.avatar AS sender_avatar,
        S.first_name AS sender_first_name,
        S.last_name AS sender_last_name,
        S.bio AS sender_bio,
        S.birthday AS sender_birthday,
        S.gender AS sender_gender,
        S.phone_number AS sender_phone_number,

        C.id AS chat_id,
        C.user1_id AS chat_user1_id,
        C.user2_id AS chat_user2_id,
        C.last_message AS chat_last_message,
        C.unread_count AS chat_unread_count,
        C.last_message_time AS chat_last_message_time,
        C.avatar AS chat_avatar

      FROM Message M
      LEFT JOIN user S ON M.sender_id = S.id
      LEFT JOIN Chat C ON M.chat_id = C.id
      WHERE M.chat_id = ?
      ORDER BY M.timestamp ASC
      ''',
      [chatId],
    );
    return result;
  }

  Future<List<Map<String, dynamic>>> getFavoriteChats() async {
    final db = await this.db;
    final List<Map<String, dynamic>> result = await db!.rawQuery('''
      SELECT
        C.id AS chat_id,
        C.last_message,
        C.unread_count,
        C.last_message_time,
        C.avatar,

        U1.id AS user1_id,
        U1.username AS user1_username,
        U1.email AS user1_email,
        U1.avatar AS user1_avatar,
        U1.first_name AS user1_first_name,
        U1.last_name AS user1_last_name,
        U1.bio AS user1_bio,
        U1.birthday AS user1_birthday,
        U1.gender AS user1_gender,
        U1.phone_number AS user1_phone_number,
        U1.date_joined AS user1_date_joined,
        U1.last_login AS user1_last_login,

        U2.id AS user2_id,
        U2.username AS user2_username,
        U2.email AS user2_email,
        U2.avatar AS user2_avatar,
        U2.first_name AS user2_first_name,
        U2.last_name AS user2_last_name,
        U2.bio AS user2_bio,
        U2.birthday AS user2_birthday,
        U2.gender AS user2_gender,
        U2.phone_number AS user2_phone_number,
        U2.date_joined AS user2_date_joined,
        U2.last_login AS user2_last_login

      FROM Chat C
      INNER JOIN FeveritChat FC ON C.id = FC.id
      INNER JOIN user U1 ON C.user1_id = U1.id
      INNER JOIN user U2 ON C.user2_id = U2.id
    ''');
    return result;
  }

  Future<void> addToFeverite(int chatId) async {
    final db = await this.db;
    await db!.insert('FeveritChat', {
      'id': 5,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeFromFeverite(int chatId) async {
    final db = await this.db;
    await db!.delete('FeveritChat', where: 'id = ?', whereArgs: [chatId]);
  }
}
