import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI untuk macOS/desktop
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    final String path = join(appDocumentsDir.path, 'mypos_offline.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabel Tenants
    await db.execute('''
      CREATE TABLE tenants (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        address TEXT,
        city TEXT,
        province TEXT,
        postal_code TEXT,
        logo TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        last_synced_at TEXT
      )
    ''');

    // Tabel Branches
    await db.execute('''
      CREATE TABLE branches (
        id INTEGER PRIMARY KEY,
        tenant_id INTEGER,
        name TEXT NOT NULL,
        code TEXT,
        address TEXT,
        city TEXT,
        province TEXT,
        postal_code TEXT,
        phone TEXT,
        email TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        created_by INTEGER,
        created_by_name TEXT,
        updated_by INTEGER,
        updated_by_name TEXT,
        synced INTEGER DEFAULT 0,
        last_synced_at TEXT,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id)
      )
    ''');

    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        tenant_id INTEGER,
        branch_id INTEGER,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT,
        role TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        created_by INTEGER,
        created_by_name TEXT,
        updated_by INTEGER,
        updated_by_name TEXT,
        synced INTEGER DEFAULT 0,
        last_synced_at TEXT,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id),
        FOREIGN KEY (branch_id) REFERENCES branches (id)
      )
    ''');

    // Tabel Categories
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        tenant_id INTEGER,
        name TEXT NOT NULL,
        description TEXT,
        image TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT,
        created_by INTEGER,
        created_by_name TEXT,
        updated_by INTEGER,
        updated_by_name TEXT,
        synced INTEGER DEFAULT 0,
        last_synced_at TEXT
      )
    ''');

    // Tabel Products
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category_id INTEGER,
        description TEXT,
        sku TEXT,
        stock INTEGER,
        is_active INTEGER DEFAULT 1,
        image TEXT,
        category_detail TEXT,
        synced INTEGER DEFAULT 0,
        last_synced_at TEXT,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    // Tabel Orders
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT UNIQUE,
        tenant_id INTEGER,
        branch_id INTEGER,
        user_id INTEGER,
        customer_name TEXT,
        customer_phone TEXT,
        total_amount REAL NOT NULL,
        discount REAL DEFAULT 0,
        tax REAL DEFAULT 0,
        grand_total REAL NOT NULL,
        payment_method TEXT,
        payment_status TEXT,
        order_status TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        last_synced_at TEXT,
        server_id INTEGER
      )
    ''');

    // Tabel Order Items
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        notes TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    // Tabel Payments
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        tenant_id INTEGER,
        branch_id INTEGER,
        user_id INTEGER,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_status TEXT DEFAULT 'pending',
        reference_number TEXT,
        notes TEXT,
        paid_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        last_synced_at TEXT,
        server_id INTEGER,
        FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (tenant_id) REFERENCES tenants (id),
        FOREIGN KEY (branch_id) REFERENCES branches (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tabel Sync Queue untuk track pending sync
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    // Tabel untuk menyimpan metadata sync
    await db.execute('''
      CREATE TABLE sync_metadata (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT
      )
    ''');

    // Create indexes untuk performa
    await db.execute('CREATE INDEX idx_tenants_active ON tenants(is_active)');
    await db.execute('CREATE INDEX idx_branches_tenant ON branches(tenant_id)');
    await db.execute('CREATE INDEX idx_branches_active ON branches(is_active)');
    await db.execute('CREATE INDEX idx_users_tenant ON users(tenant_id)');
    await db.execute('CREATE INDEX idx_users_branch ON users(branch_id)');
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute(
      'CREATE INDEX idx_categories_tenant ON categories(tenant_id)',
    );
    await db.execute(
      'CREATE INDEX idx_products_category ON products(category_id)',
    );
    await db.execute('CREATE INDEX idx_products_synced ON products(synced)');
    await db.execute('CREATE INDEX idx_orders_tenant ON orders(tenant_id)');
    await db.execute('CREATE INDEX idx_orders_branch ON orders(branch_id)');
    await db.execute('CREATE INDEX idx_orders_user ON orders(user_id)');
    await db.execute('CREATE INDEX idx_orders_synced ON orders(synced)');
    await db.execute(
      'CREATE INDEX idx_orders_created_at ON orders(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_order_items_order ON order_items(order_id)',
    );
    await db.execute('CREATE INDEX idx_payments_order ON payments(order_id)');
    await db.execute('CREATE INDEX idx_payments_synced ON payments(synced)');
    await db.execute(
      'CREATE INDEX idx_sync_queue_table ON sync_queue(table_name)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades di sini
    if (oldVersion < 2) {
      // Upgrade dari versi 1 ke 2: Tambah tabel tenants, branches, users, payments
      await db.execute('''
        CREATE TABLE IF NOT EXISTS tenants (
          id INTEGER PRIMARY KEY,
          name TEXT NOT NULL,
          email TEXT,
          phone TEXT,
          address TEXT,
          city TEXT,
          province TEXT,
          postal_code TEXT,
          logo TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          last_synced_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS branches (
          id INTEGER PRIMARY KEY,
          tenant_id INTEGER,
          name TEXT NOT NULL,
          code TEXT,
          address TEXT,
          city TEXT,
          province TEXT,
          postal_code TEXT,
          phone TEXT,
          email TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          created_by INTEGER,
          created_by_name TEXT,
          updated_by INTEGER,
          updated_by_name TEXT,
          synced INTEGER DEFAULT 0,
          last_synced_at TEXT,
          FOREIGN KEY (tenant_id) REFERENCES tenants (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY,
          tenant_id INTEGER,
          branch_id INTEGER,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          phone TEXT,
          role TEXT,
          is_active INTEGER DEFAULT 1,
          created_at TEXT,
          updated_at TEXT,
          created_by INTEGER,
          created_by_name TEXT,
          updated_by INTEGER,
          updated_by_name TEXT,
          synced INTEGER DEFAULT 0,
          last_synced_at TEXT,
          FOREIGN KEY (tenant_id) REFERENCES tenants (id),
          FOREIGN KEY (branch_id) REFERENCES branches (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS payments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          order_id INTEGER NOT NULL,
          tenant_id INTEGER,
          branch_id INTEGER,
          user_id INTEGER,
          amount REAL NOT NULL,
          payment_method TEXT NOT NULL,
          payment_status TEXT DEFAULT 'pending',
          reference_number TEXT,
          notes TEXT,
          paid_at TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          synced INTEGER DEFAULT 0,
          last_synced_at TEXT,
          server_id INTEGER,
          FOREIGN KEY (order_id) REFERENCES orders (id) ON DELETE CASCADE,
          FOREIGN KEY (tenant_id) REFERENCES tenants (id),
          FOREIGN KEY (branch_id) REFERENCES branches (id),
          FOREIGN KEY (user_id) REFERENCES users (id)
        )
      ''');

      // Tambah indexes untuk tabel baru
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_tenants_active ON tenants(is_active)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_branches_tenant ON branches(tenant_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_branches_active ON branches(is_active)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_users_tenant ON users(tenant_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_users_branch ON users(branch_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_users_email ON users(email)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_categories_tenant ON categories(tenant_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_orders_tenant ON orders(tenant_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_orders_branch ON orders(branch_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_payments_synced ON payments(synced)',
      );
    }
  }

  // Helper methods untuk transactions
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('payments');
      await txn.delete('order_items');
      await txn.delete('orders');
      await txn.delete('products');
      await txn.delete('categories');
      await txn.delete('users');
      await txn.delete('branches');
      await txn.delete('tenants');
      await txn.delete('sync_queue');
      await txn.delete('sync_metadata');
    });
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Get database info
  Future<Map<String, dynamic>> getDatabaseInfo() async {
    final db = await database;
    final tenantsCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM tenants'),
        ) ??
        0;
    final branchesCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM branches'),
        ) ??
        0;
    final usersCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM users'),
        ) ??
        0;
    final categoriesCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM categories'),
        ) ??
        0;
    final productsCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM products'),
        ) ??
        0;
    final ordersCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM orders'),
        ) ??
        0;
    final paymentsCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM payments'),
        ) ??
        0;
    final syncQueueCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM sync_queue'),
        ) ??
        0;

    return {
      'tenants_count': tenantsCount,
      'branches_count': branchesCount,
      'users_count': usersCount,
      'categories_count': categoriesCount,
      'products_count': productsCount,
      'orders_count': ordersCount,
      'payments_count': paymentsCount,
      'pending_sync_count': syncQueueCount,
      'database_path': db.path,
    };
  }
}
