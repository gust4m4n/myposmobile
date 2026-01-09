import 'package:sqflite/sqflite.dart';

import '../../shared/database/database_helper.dart';

class PaymentOfflineService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Save multiple payments (bulk insert for sync)
  Future<void> savePayments(List<Map<String, dynamic>> paymentsData) async {
    if (paymentsData.isEmpty) return;

    final db = await _dbHelper.database;
    final batch = db.batch();

    for (var paymentJson in paymentsData) {
      // Prepare payment data
      final paymentData = {
        'order_id': paymentJson['order_id'] as int?,
        'tenant_id': paymentJson['tenant_id'] as int?,
        'branch_id': paymentJson['branch_id'] as int?,
        'user_id': paymentJson['user_id'] as int?,
        'amount': (paymentJson['amount'] as num?)?.toDouble() ?? 0.0,
        'payment_method': paymentJson['payment_method'] as String? ?? '',
        'payment_status': paymentJson['status'] as String? ?? 'pending',
        'reference_number': paymentJson['reference_number'] as String?,
        'notes': paymentJson['notes'] as String?,
        'paid_at': paymentJson['paid_at'] as String?,
        'created_at':
            paymentJson['created_at'] as String? ??
            DateTime.now().toUtc().toIso8601String(),
        'updated_at': paymentJson['updated_at'] as String?,
        'synced': 1,
        'last_synced_at': DateTime.now().toUtc().toIso8601String(),
        'server_id': paymentJson['id'] as int?,
      };

      batch.insert(
        'payments',
        paymentData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Get all payments
  Future<List<Map<String, dynamic>>> getAllPayments() async {
    final db = await _dbHelper.database;
    return await db.query('payments', orderBy: 'created_at DESC');
  }

  /// Get payments by order ID
  Future<List<Map<String, dynamic>>> getPaymentsByOrderId(int orderId) async {
    final db = await _dbHelper.database;
    return await db.query(
      'payments',
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'created_at DESC',
    );
  }

  /// Get unsynced payments
  Future<List<Map<String, dynamic>>> getUnsyncedPayments() async {
    final db = await _dbHelper.database;
    return await db.query(
      'payments',
      where: 'synced = ?',
      whereArgs: [0],
      orderBy: 'created_at ASC',
    );
  }

  /// Clear all payments
  Future<void> clearAllPayments() async {
    final db = await _dbHelper.database;
    await db.delete('payments');
  }

  /// Get total payments count
  Future<int> getPaymentsCount() async {
    final db = await _dbHelper.database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) as count FROM payments'),
        ) ??
        0;
  }
}
