import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal(); // Singleton instance
  factory DbHelper() => _instance;
  static Database? _database;

  DbHelper._internal();

  // Get database instance (singleton)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // -------------------------
  // CATEGORY METHODS
  // -------------------------

  // Insert new category
  Future<void> insertCateg(String categ_name) async {
    final db = await database;
    await db.insert('category', {
      'categ_name': categ_name,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get all categories
  Future<List<Map<String, dynamic>>> getCategs() async {
    final db = await database;
    return db.query('category');
  }

  // Update category by id
  Future<void> updateCateg(int id, String newName) async {
    final db = await database;
    await db.update(
      'category',
      {'categ_name': newName},
      where: 'categ_id = ?',
      whereArgs: [id],
    );
  }

  // Delete category by id
  Future<void> deleteCateg(int id) async {
    final db = await database;
    await db.delete('category', where: 'categ_id = ?', whereArgs: [id]);
  }

  // -------------------------
  // CONTACT METHODS
  // -------------------------

  Future<void> insertContact(
    String firstname,
    String lastname,
    String phone,
    String? photo,
    int? categ_id,
  ) async {
    final db = await database;
    await db.insert('contact', {
      'firstname': firstname,
      'lastname': lastname,
      'phone': phone,
      'photo': photo,
      'categ_id': categ_id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    final db = await database;
    return db.rawQuery('''
      SELECT contact.contact_id, 
             contact.firstname, 
             contact.lastname, 
             contact.phone,
             contact.photo, 
             contact.categ_id, 
             category.categ_name
      FROM contact
      LEFT JOIN category 
        ON contact.categ_id = category.categ_id
    ''');
  }

  Future<void> updateContact(
    int id,
    String firstname,
    String lastname,
    String phone,
    String? photo,
    int? categ_id,
  ) async {
    final db = await database;
    await db.update(
      'contact',
      {
        'firstname': firstname,
        'lastname': lastname,
        'phone': phone,
        'photo': photo,
        'categ_id': categ_id,
      },
      where: 'contact_id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteContact(int id) async {
    final db = await database;
    await db.delete('contact', where: 'contact_id = ?', whereArgs: [id]);
  }
}

// -------------------------
// DATABASE INITIALIZATION
// -------------------------
Future<Database> _initDatabase() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'contacts'); // Database name: contacts

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      // Create category table
      await db.execute(
        'CREATE TABLE category ('
        'categ_id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'categ_name TEXT NOT NULL'
        ')',
      );

      // Create contact table
      await db.execute(
        'CREATE TABLE contact ('
        'contact_id INTEGER PRIMARY KEY AUTOINCREMENT, '
        'firstname TEXT NOT NULL, '
        'lastname TEXT NOT NULL, '
        'photo TEXT,'
        'phone TEXT, '
        'categ_id INTEGER, '
        'FOREIGN KEY (categ_id) REFERENCES category(categ_id)'
        ')',
      );
    },
  );
}
