import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../shared/database/database_helper.dart';

class OrderOfflineModel {
  final int? id;
  final String orderNumber;
  final int? tenantId;
  final int? branchId;
  final int? userId;
  final String? customerName;
  final String? customerPhone;
  final double totalAmount;
  final double discount;
  final double tax;
  final double grandTotal;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final String? notes;
  final String createdAt;
  final String? updatedAt;
  final bool synced;
  final String? lastSyncedAt;
  final int? serverId; // ID dari server setelah sync
  final List<OrderItemOfflineModel> items;

  OrderOfflineModel({
    this.id,
    required this.orderNumber,
    this.tenantId,
    this.branchId,
    this.userId,
    this.customerName,
    this.customerPhone,
    required this.totalAmount,
    this.discount = 0,
    this.tax = 0,
    required this.grandTotal,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.synced = false,
    this.lastSyncedAt,
    this.serverId,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_number': orderNumber,
      'tenant_id': tenantId,
      'branch_id': branchId,
      'user_id': userId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'grand_total': grandTotal,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'notes': notes,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'synced': synced ? 1 : 0,
      'last_synced_at': lastSyncedAt,
      'server_id': serverId,
    };
  }

  factory OrderOfflineModel.fromMap(Map<String, dynamic> map) {
    return OrderOfflineModel(
      id: map['id'] as int?,
      orderNumber: map['order_number'] as String,
      tenantId: map['tenant_id'] as int?,
      branchId: map['branch_id'] as int?,
      userId: map['user_id'] as int?,
      customerName: map['customer_name'] as String?,
      customerPhone: map['customer_phone'] as String?,
      totalAmount: (map['total_amount'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      tax: (map['tax'] as num?)?.toDouble() ?? 0,
      grandTotal: (map['grand_total'] as num).toDouble(),
      paymentMethod: map['payment_method'] as String,
      paymentStatus: map['payment_status'] as String,
      orderStatus: map['order_status'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String?,
      synced: map['synced'] == 1,
      lastSyncedAt: map['last_synced_at'] as String?,
      serverId: map['server_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (serverId != null) 'id': serverId,
      'order_number': orderNumber,
      'tenant_id': tenantId,
      'branch_id': branchId,
      'user_id': userId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'total_amount': totalAmount,
      'discount': discount,
      'tax': tax,
      'grand_total': grandTotal,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItemOfflineModel {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double subtotal;
  final String? notes;
  final bool synced;

  OrderItemOfflineModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.notes,
    this.synced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'notes': notes,
      'synced': synced ? 1 : 0,
    };
  }

  factory OrderItemOfflineModel.fromMap(Map<String, dynamic> map) {
    return OrderItemOfflineModel(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      price: (map['price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
      notes: map['notes'] as String?,
      synced: map['synced'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'notes': notes,
    };
  }
}

class OrderOfflineService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Generate order number
  String generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    return 'ORD-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-$timestamp';
  }

  // Create new order
  Future<OrderOfflineModel> createOrder(OrderOfflineModel order) async {
    final db = await _dbHelper.database;

    return await db.transaction((txn) async {
      // Insert order
      final orderId = await txn.insert('orders', order.toMap());

      // Insert order items
      for (var item in order.items) {
        final itemData = item.toMap();
        itemData['order_id'] = orderId;
        await txn.insert('order_items', itemData);
      }

      // Add to sync queue
      await txn.insert('sync_queue', {
        'table_name': 'orders',
        'record_id': orderId,
        'operation': 'CREATE',
        'data': jsonEncode(order.toJson()),
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'retry_count': 0,
      });

      // Get complete order with items
      return await _getOrderById(orderId, txn);
    });
  }

  // Get order by ID
  Future<OrderOfflineModel?> getOrderById(int id) async {
    final db = await _dbHelper.database;
    return await _getOrderById(id, db);
  }

  Future<OrderOfflineModel> _getOrderById(int id, DatabaseExecutor db) async {
    final orderMaps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (orderMaps.isEmpty) {
      throw Exception('Order not found');
    }

    final order = OrderOfflineModel.fromMap(orderMaps.first);

    // Get order items
    final itemMaps = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [id],
    );

    final items = itemMaps
        .map((map) => OrderItemOfflineModel.fromMap(map))
        .toList();

    return OrderOfflineModel(
      id: order.id,
      orderNumber: order.orderNumber,
      tenantId: order.tenantId,
      branchId: order.branchId,
      userId: order.userId,
      customerName: order.customerName,
      customerPhone: order.customerPhone,
      totalAmount: order.totalAmount,
      discount: order.discount,
      tax: order.tax,
      grandTotal: order.grandTotal,
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      orderStatus: order.orderStatus,
      notes: order.notes,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
      synced: order.synced,
      lastSyncedAt: order.lastSyncedAt,
      serverId: order.serverId,
      items: items,
    );
  }

  // Get all orders
  Future<List<OrderOfflineModel>> getAllOrders({
    int? limit,
    int? offset,
    String? orderBy = 'created_at DESC',
  }) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    List<OrderOfflineModel> orders = [];
    for (var map in maps) {
      final order = await _getOrderById(map['id'] as int, db);
      orders.add(order);
    }

    return orders;
  }

  // Get orders by date range
  Future<List<OrderOfflineModel>> getOrdersByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'created_at DESC',
    );

    List<OrderOfflineModel> orders = [];
    for (var map in maps) {
      final order = await _getOrderById(map['id'] as int, db);
      orders.add(order);
    }

    return orders;
  }

  // Get unsynced orders
  Future<List<OrderOfflineModel>> getUnsyncedOrders() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );

    List<OrderOfflineModel> orders = [];
    for (var map in maps) {
      final order = await _getOrderById(map['id'] as int, db);
      orders.add(order);
    }

    return orders;
  }

  // Get today's orders
  Future<List<OrderOfflineModel>> getTodayOrders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getOrdersByDateRange(startOfDay, endOfDay);
  }

  // Update order status
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    final db = await _dbHelper.database;
    await db.update(
      'orders',
      {
        'order_status': newStatus,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'synced': 0,
      },
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // Mark order as synced
  Future<void> markOrderAsSynced(int localOrderId, int serverId) async {
    final db = await _dbHelper.database;
    await db.update(
      'orders',
      {
        'synced': 1,
        'server_id': serverId,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localOrderId],
    );

    // Mark order items as synced
    await db.update(
      'order_items',
      {'synced': 1},
      where: 'order_id = ?',
      whereArgs: [localOrderId],
    );
  }

  // Get sales summary
  Future<Map<String, dynamic>> getSalesSummary(DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(*) as total_orders,
        SUM(grand_total) as total_sales,
        SUM(discount) as total_discount,
        SUM(tax) as total_tax
      FROM orders
      WHERE created_at >= ? AND created_at <= ?
    ''',
      [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
    );

    return {
      'total_orders': result[0]['total_orders'] ?? 0,
      'total_sales': result[0]['total_sales'] ?? 0.0,
      'total_discount': result[0]['total_discount'] ?? 0.0,
      'total_tax': result[0]['total_tax'] ?? 0.0,
      'date': date.toIso8601String(),
    };
  }

  // Delete order
  Future<void> deleteOrder(int id) async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('order_items', where: 'order_id = ?', whereArgs: [id]);
      await txn.delete('orders', where: 'id = ?', whereArgs: [id]);
    });
  }

  // Clear all orders
  Future<void> clearAllOrders() async {
    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await txn.delete('order_items');
      await txn.delete('orders');
    });
  }

  /// Save multiple orders (bulk insert for sync)
  Future<void> saveOrders(List<Map<String, dynamic>> ordersData) async {
    if (ordersData.isEmpty) return;

    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var orderJson in ordersData) {
      // Prepare order data
      final orderData = {
        'order_number': orderJson['order_number'] as String?,
        'tenant_id': orderJson['tenant_id'] as int?,
        'branch_id': orderJson['branch_id'] as int?,
        'user_id': orderJson['user_id'] as int?,
        'customer_name': orderJson['customer_name'] as String?,
        'customer_phone': orderJson['customer_phone'] as String?,
        'total_amount': (orderJson['total_amount'] as num?)?.toDouble() ?? 0.0,
        'discount': (orderJson['discount'] as num?)?.toDouble() ?? 0.0,
        'tax': (orderJson['tax'] as num?)?.toDouble() ?? 0.0,
        'grand_total': (orderJson['grand_total'] as num?)?.toDouble() ?? 0.0,
        'payment_method': orderJson['payment_method'] as String? ?? '',
        'payment_status': orderJson['payment_status'] as String? ?? 'pending',
        'order_status': orderJson['order_status'] as String? ?? 'pending',
        'notes': orderJson['notes'] as String?,
        'created_at':
            orderJson['created_at'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
        'updated_at': orderJson['updated_at'] as String?,
        'synced': 1,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
        'server_id': orderJson['id'] as int?,
      };

      batch.insert(
        'orders',
        orderData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Save order items if available
      final items =
          orderJson['order_items'] as List? ?? orderJson['items'] as List?;
      if (items != null && items.isNotEmpty) {
        for (var itemJson in items) {
          final itemData = {
            'order_id':
                orderJson['id'] as int?, // Use server order id temporarily
            'product_id': itemJson['product_id'] as int?,
            'product_name': itemJson['product_name'] as String? ?? '',
            'quantity': itemJson['quantity'] as int? ?? 0,
            'price': (itemJson['price'] as num?)?.toDouble() ?? 0.0,
            'subtotal': (itemJson['subtotal'] as num?)?.toDouble() ?? 0.0,
            'notes': itemJson['notes'] as String?,
            'synced': 1,
          };

          batch.insert(
            'order_items',
            itemData,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }

    await batch.commit(noResult: true);
  }

  /// Get total orders count
  Future<int> getOrdersCount() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM orders');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
