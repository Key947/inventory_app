import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'kasir_complex.db'); // Ganti nama DB lagi
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Tabel Barang
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        price INTEGER,
        stock INTEGER,
        imagePath TEXT
      )
    ''');

    // 2. Tabel Users (Tambah kolom ROLE)
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT 
      )
    ''');

    // 3. Tabel Orders (Riwayat Transaksi)
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        totalAmount INTEGER,
        itemSummary TEXT,
        transactionDate TEXT
      )
    ''');

    // INSERT ADMIN DEFAULT (Biar kamu gak terkunci)
    // Username: admin, Pass: admin, Role: admin
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin',
      'role': 'admin'
    });
  }

  // --- ITEM CRUD ---
  Future<int> insertItem(Item item) async {
    Database db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getItemList() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items', orderBy: "id DESC");
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
  }

  Future<int> updateItem(Item item) async {
    Database db = await database;
    return await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(int id) async {
    Database db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // --- USER AUTH (LOGIN & REGISTER) ---
  
  // Register (Default jadi 'cashier' / kasir)
  Future<int> registerUser(String username, String password) async {
    Database db = await database;
    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
        'role': 'cashier' // User biasa dianggap kasir
      });
    } catch (e) {
      return -1;
    }
  }

  // Login (Sekarang mengembalikan Map user biar tau role-nya)
  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  // --- TRANSAKSI ---
  Future<int> createOrder(int total, String summary) async {
    Database db = await database;
    return await db.insert('orders', {
      'totalAmount': total,
      'itemSummary': summary, // Contoh: "Ayam x2, Nasi x1"
      'transactionDate': DateTime.now().toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getOrderHistory() async {
    Database db = await database;
    return await db.query('orders', orderBy: "id DESC");
  }
}