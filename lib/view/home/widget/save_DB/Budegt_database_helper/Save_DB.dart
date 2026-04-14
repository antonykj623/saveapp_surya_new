import 'dart:convert';
import 'package:new_project_2025/model/receipt.dart';
import 'package:new_project_2025/view/home/dream_page/model_dream_page/model_dream.dart';
import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:async';

 class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  static Database? _database;

  static bool isRestoring = false;
  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'save.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE TABLE_TARGETCATEGORY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        iconimage BLOB,
        isCustom TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_PAYMENTVOUCHER (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        voucherdata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE INSURANCE_NO (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        insuranceNO TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE INVESTNAMES_TABLE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        investname TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE CASHBALANCE_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        cashbalancedata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE LOAN_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE RECEIPT_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        receipt_data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_DOCUMENT (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_WALLET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_PASSWORD (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_VISITCARD_IMAGE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data BLOB
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_APP_PIN (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_MILESTONE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ACCOUNTS (
        ACCOUNTS_id INTEGER PRIMARY KEY AUTOINCREMENT,
        ACCOUNTS_VoucherType INTEGER,
        ACCOUNTS_entryid TEXT,
        ACCOUNTS_date TEXT,
        ACCOUNTS_setupid TEXT,
        ACCOUNTS_amount TEXT,
        ACCOUNTS_type TEXT,
        ACCOUNTS_remarks TEXT,
        ACCOUNTS_year TEXT,
        ACCOUNTS_month TEXT,
        ACCOUNTS_cashbanktype TEXT,
        ACCOUNTS_billId TEXT,
        ACCOUNTS_billVoucherNumber TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ACCOUNTS_RECEIPT (
        ACCOUNTS_id INTEGER PRIMARY KEY AUTOINCREMENT,
        ACCOUNTS_entryid TEXT,
        ACCOUNTS_date TEXT,
        ACCOUNTS_setupid TEXT,
        ACCOUNTS_amount TEXT,
        ACCOUNTS_type TEXT,
        ACCOUNTS_remarks TEXT,
        ACCOUNTS_year TEXT,
        ACCOUNTS_month TEXT,
        ACCOUNTS_cashbanktype TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ASSET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_LIABILITY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_INSURANCE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ACCOUNTSETTINGS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE DIARYSUBJECT_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_BUDGET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE DIARY_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE INVESTMENT_table (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_TASK (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_VISITCARD (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT,
        logoimage BLOB,
        cardimg BLOB
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_TARGET (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_ADDEDAMOUNT_MILESTONE (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_BACKUP (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_RENEWALMSG (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_WEBLINKS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_EMERGENCY (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE TABLE_BILLDETAILS (
        keyid INTEGER PRIMARY KEY AUTOINCREMENT,
        data TEXT
      )
    ''');
  }
  // Dream-related methods
  Future<int> insertDream(Dream dream) async {
    try {
      final db = await database;
      Map<String, dynamic> dreamData = {
        "targetname": dream.name,
        "targetamount": dream.targetAmount,
        "savedamount": dream.savedAmount,
        "target_date": dream.targetDate.toIso8601String(),
        "note": dream.notes,
        "investment": dream.investment,
        "category": dream.category,
      };

      Map<String, dynamic> dbData = {"data": jsonEncode(dreamData)};
      return await db.insert('TABLE_TARGET', dbData);
    } catch (e) {
      print("Error inserting dream: $e");
      return 0;
    }
  }

  // Enhanced Dream insertion with milestone support
  Future<int> insertDreamWithId(Dream dream) async {
    try {
      final db = await database;
      Map<String, dynamic> dreamData = {
        "targetname": dream.name,
        "targetamount": dream.targetAmount,
        "savedamount": dream.savedAmount,
        "target_date": dream.targetDate.toIso8601String(),
        "note": dream.notes,
        "investment": dream.investment,
        "category": dream.category,
      };

      Map<String, dynamic> dbData = {"data": jsonEncode(dreamData)};
      int targetId = await db.insert('TABLE_TARGET', dbData);

      return targetId;
    } catch (e) {
      print("Error inserting dream: $e");
      return 0;
    }
  }

  Future<int> addData(String table, String data) async {
    int insertedId = 0;
    try {
      final db = await database;
      Map<String, dynamic> values = {'data': data};
      insertedId = await db.insert(table, values);
      print("Inserted id is $insertedId");
      print("Inserted Values are $values");
    } catch (e) {
      print("Database insert error: $e");
    }
    return insertedId;
  }
  Future<int> addwwalletData(String table, String data) async {
    int insertedId = 0;
    try {
      final db = await database;
      Map<String, dynamic> values = {'data': data};
      insertedId = await db.insert(table, values);
    } catch (e) {
      print("Database insert error: $e");
    }
    return insertedId;
  }
  Future<void> updateweblink(
      String weblink1,
      String username1,
      String password1,
      String description1,
      String keyid,
      ) async {
    Database db = await database;

    Map<String, dynamic> weblinkData = {
      "weblink1": weblink1,
      "username1": username1,
      "password1": password1,
      "description1": description1,

    };

    Map<String, dynamic> datatoupdata = {
      "keyid": keyid,
      "data": jsonEncode(weblinkData),
    };

    var res = await db.update(
      'TABLE_WEBLINKS',
      datatoupdata,
      where: 'keyid = ?',
      whereArgs: [keyid],
    );

    if (res == 1) {
      print("Res is: $res.");
      print("updatedRes is: $res.");
    } else {
      print("not updated");
    }
  }

  //
  // Future<void> clearAll() async {
  //   final db = await database;
  //   await db.delete("mytable");
  // }

  // Future<void> insertBulk(List items) async {
  //   final db = await database;
  //
  //   for (var item in items) {
  //     await db.insert("mytable", item);
  //   }
  // }
  // restore all rows into a table safely
  Future<void> restoreTable(
      String tableName,
      List<Map<String, dynamic>> rows,
      ) async {
    final db = await database;

    await db.transaction((txn) async {
      // Clear old data; ensures full snapshot restore
      await txn.delete(tableName);

      final batch = txn.batch();
      for (var row in rows) {
        // Convert base64 → bytes for blob columns if needed
        final processedRow = _decodeBlobColumns(row);
print("Processed rows are $processedRow");
        batch.insert(
          tableName,
          processedRow,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    });
  }

// Auto-detect base64 encoded blobs & decode
   Map<String, dynamic> _decodeBlobColumns(Map<String, dynamic> row) {
     final newRow = Map<String, dynamic>.from(row);

     newRow.forEach((key, value) {
       if (value is String && value.startsWith("/9j/")) {
         // JPEG base64 detection
         newRow[key] = base64Decode(value);
       } else if (value is String && _isBase64(value)) {
         // generic base64
         try {
           newRow[key] = base64Decode(value);
         } catch (_) {}
       }
     });

     return newRow;
   }

   bool _isBase64(String str) {
     final base64RegEx = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
     return base64RegEx.hasMatch(str);
   }
  Future<void> _clearAllTables(Database db) async {
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

    for (var t in tables) {
      final tableName = t['name'] as String;
      print("🧹 Clearing table: $tableName");
      await db.delete(tableName);
    }
  }

  /// Close DB when app is shutting down (optional)

  Future<void> insertIntoTable(String tableName, Map<String, dynamic> row) async {
    final db = await database;
    await db.insert(
      tableName,
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  Future<void> updateDiary(
      String startdate,
      String subject,
      String remarks,
      String language,
      String keyid,
      ) async {
    Database db = await database;

    Map<String, dynamic> diaryData = {
      "startdate": startdate,
      "subject": subject,
      "remarks": remarks,
"language":language,


    };

    Map<String, dynamic> datatoupdata = {
      "keyid": keyid,
      "data": jsonEncode(diaryData),
    };

    var res = await db.update(
      'DIARY_table',
      datatoupdata,
      where: 'keyid = ?',
      whereArgs: [keyid],
    );

    if (res == 1) {
      print("Res is: $res.");
      print("updatedRes is: $res.");
    } else {
      print("not updated");
    }
  }
  Future<void> updateaccountdet(
    String accountname,
    String catogory,
    String openingbalance,
    String accountype,
    String year,
    String keyid,
  ) async {
    Database db = await database;

    Map<String, dynamic> accountData = {
      "Accountname": accountname,
      "Accounttype": catogory,
      "Amount": openingbalance,
      "Type": accountype,
      "year": year,
    };

    Map<String, dynamic> datatoupdata = {
      "keyid": keyid,
      "data": jsonEncode(accountData),
    };

    var res = await db.update(
      'TABLE_ACCOUNTSETTINGS',
      datatoupdata,
      where: 'keyid = ?',
      whereArgs: [keyid],
    );

    if (res == 1) {
      print("Res is: $res.");
      print("updatedRes is: $res.");
    } else {
      print("not updated");
    }
  }

  Future<String> exportDatabaseToJsonContent() async {
    final dbPath = join(await getDatabasesPath(), 'save.db');
    final db = await openDatabase(dbPath);

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
    );

    Map<String, dynamic> allData = {};

    for (var table in tables) {
      final tableName = table['name'] as String;
      final rows = await db.query(tableName);

      final encodedRows = rows.map((row) {
        final updatedRow = Map<String, dynamic>.from(row);
        updatedRow.forEach((key, value) {
          if (value is Uint8List) {
            updatedRow[key] = base64Encode(value);
          }
        });
        return updatedRow;
      }).toList();

      allData[tableName] = encodedRows;
    }

    await db.close();

    return const JsonEncoder.withIndent('  ').convert(allData);
  }


  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
  Future<List<String>> getAccountNames() async {
    final db = await database;
    final result = await db.query('savedb', columns: ['DISTINCT account_name']);
    return result.map((e) => e['account_name'] as String).toList();
  }

  Future<int> insertData(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(tableName, data);
  }

  Future<List<Map<String, dynamic>>> queryallacc() async {
    Database db = await database;
    var res = await db.query('TABLE_ACCOUNTSETTINGS');

    List<Map<String, dynamic>> s = res.toList();
    print("queryallacc datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> subjData() async {
    Database db = await database;
    var res = await db.query('DIARYSUBJECT_table');

    List<Map<String, dynamic>> s = res.toList();
    print("subject datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> docdatas() async {
    Database db = await database;
    var res = await db.query('TABLE_DOCUMENT');

    List<Map<String, dynamic>> s = res.toList();
    print("queryallacc datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> getWalletData() async {
    Database db = await database;
    var res = await db.query('TABLE_WALLET');

    List<Map<String, dynamic>> s = res.toList();
    print("Wallet datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> fetchAllData() async {
    Database db = await database;
    var res = await db.query('TABLE_WEBLINKS');

    List<Map<String, dynamic>> s = res.toList();
    print("Weblink datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> fetchAllDocData() async {
    Database db = await database;
    var res = await db.query('TABLE_DOCUMENT');

    List<Map<String, dynamic>> s = res.toList();
    print("Document datas are: $s");

    return s;
  }
  Future<Map<String, dynamic>?> getDataByKeyId(String table, int keyid) async {
    final db = await database;
    final result = await db.query(
      table,
      where: 'keyid = ?',
      whereArgs: [keyid],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
  Future<int> deleteByKeyId(String table, int keyid) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'keyid = ?',
      whereArgs: [keyid],
    );
  }
  Future<List<Map<String, dynamic>>> getAllData(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }
  Future<List<Map<String, dynamic>>> fetchAllpassData() async {
    Database db = await database;
    var res = await db.query('TABLE_PASSWORD');

    List<Map<String, dynamic>> s = res.toList();
    print("Password datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> fetchAllDiaryData() async {
    Database db = await database;
    var res = await db.query('DIARY_table');

    List<Map<String, dynamic>> s = res.toList();
    print("Diary datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> fetchAllTaskData() async {
    Database db = await database;
    var res = await db.query('TABLE_TASK');

    List<Map<String, dynamic>> s = res.toList();
    print("Diary datas are: $s");

    return s;
  }
  Future<List<Map<String, dynamic>>> getAllData1(String tableName) async {
    final db = await database;
    return await db.query(tableName);
  }


  Future<int> updateData(
    String tableName,
    Map<String, dynamic> data,
    int id,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
       data,
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }
  Future<int> updateTaskData(
      String tableName,
      Map<String, dynamic> data,
      int id,
      ) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCategoryByName(
    String tableName,
    Map<String, dynamic> data,
    String oldName,
  ) async {
    final db = await database;
    return await db.update(
      tableName,
      data,
      where: 'data = ?',
      whereArgs: [oldName],
    );
  }

  Future<int> deleteData(String tableName,id) async {
    final db = await database;
    return await db.delete(tableName, where: 'keyid = ?', whereArgs: [id]);
  }

  Future<int> deletedocData(String tableName, String id) async {
    final db = await database;
    return await db.delete(tableName, where: 'fileid = ?', whereArgs: [id]);
  }
  Future<int> deleteByFieldId(String tableName, dynamic fieldId) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'keyid = ?',
      whereArgs: [fieldId],
    );
  }

  Future<List<Dream>> getAllDreams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('dreams_table');

    return List.generate(maps.length, (i) {
      return Dream(
        name: maps[i]['name'],
        category: maps[i]['category'],
        investment: maps[i]['investment'],
        targetAmount: maps[i]['targetAmount'],
        savedAmount: maps[i]['savedAmount'],
        targetDate: DateTime.parse(maps[i]['targetDate']),
        notes: maps[i]['notes'],
      );
    });
  }

  Future<bool> _isCategoryUsed(String categoryName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool isTargetAdded = prefs.getBool('target_$categoryName') ?? false;
      return isTargetAdded;
    } catch (e) {
      print('Error checking if category is used: $e');
      return false;
    }
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await database;

    Map<String, dynamic> paymentData = {
      "date": payment.date,
      "accountName": payment.accountName,
      "amount": payment.amount,
      "paymentMode": payment.paymentMode,
      "remarks": payment.remarks,
    };

    return await db.insert('TABLE_PAYMENTVOUCHER', {
      'voucherdata': jsonEncode(paymentData),
    });
  }

  Future<int> updatePayment(Payment payment) async {
    final db = await database;

    Map<String, dynamic> paymentData = {
      "date": payment.date,
      "accountName": payment.accountName,
      "amount": payment.amount,
      "paymentMode": payment.paymentMode,
      "remarks": payment.remarks,
    };

    return await db.update(
      'TABLE_PAYMENTVOUCHER',
      {'voucherdata': jsonEncode(paymentData)},
      where: 'keyid = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> insertReceipt(Receipt receipt) async {
    final db = await database;
    Map<String, dynamic> receiptData = {
      "date": receipt.date,
      "accountName": receipt.accountName,
      "amount": receipt.amount.toString(),
      "paymentMode": receipt.paymentMode,
      "remarks": receipt.remarks ?? '',
    };
    return await db.insert('RECEIPT_table', {
      'receipt_data': jsonEncode(receiptData),
    });
  }

  Future<int> updateReceipt(Receipt receipt) async {
    final db = await database;
    Map<String, dynamic> receiptData = {
      "date": receipt.date,
      "accountName": receipt.accountName,
      "amount": receipt.amount.toString(),
      "paymentMode": receipt.paymentMode,
      "remarks": receipt.remarks ?? '',
    };
    return await db.update(
      'RECEIPT_table',
      {'receipt_data': jsonEncode(receiptData)},
      where: 'keyid = ?',
      whereArgs: [receipt.id],
    );
  }

  Future<List<Receipt>> getReceiptsByMonth(String yearMonth) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RECEIPT_table',
      where: 'receipt_data LIKE ?',
      whereArgs: ['%$yearMonth%'],
    );

    List<Receipt> receipts = [];
    for (var map in maps) {
      try {
        Map<String, dynamic> data = jsonDecode(map['receipt_data']);
        receipts.add(
          Receipt(
            id: map['keyid'],
            date: data['date'],
            accountName: data['accountName'],
            amount: double.parse(data['amount']),
            paymentMode: data['paymentMode'],
            remarks: data['remarks'] ?? '',
          ),
        );
      } catch (e) {
        print('Error parsing receipt data: $e');
      }
    }
    return receipts;
  }

  Future<int> deleteReceipt(int id) async {
    final db = await database;
    // Delete associated double-entry records from TABLE_ACCOUNTS
    await db.delete(
      'TABLE_ACCOUNTS',
      where: 'ACCOUNTS_entryid = ? AND ACCOUNTS_VoucherType = ?',
      whereArgs: [id.toString(), 2],
    );
    // Delete the receipt from RECEIPT_table
    return await db.delete(
      'RECEIPT_table',
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<List<Payment>> getPaymentsByMonth(String yearMonth) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'TABLE_PAYMENTVOUCHER',
    );

    List<Payment> payments = [];
    for (var map in maps) {
      try {
        Map<String, dynamic> paymentData = jsonDecode(map['voucherdata']);
        String paymentDate = paymentData['date'];
        if (paymentDate.startsWith(yearMonth)) {
          payments.add(
            Payment(
              id: map['keyid'],
              date: paymentData['date'],
              accountName: paymentData['accountName'],
              amount: double.parse(paymentData['amount'].toString()),
              paymentMode: paymentData['paymentMode'],
              remarks: paymentData['remarks'],
            ),
          );
        }
      } catch (e) {
        print('Error parsing payment data: $e');
      }
    }
    return payments;
  }

  Future<int> deletePayment(int id) async {
    final db = await database;
    return await db.delete(
      'TABLE_PAYMENTVOUCHER',
      where: 'keyid = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertAccountEntry(Map<String, dynamic> accountData) async {
    final db = await database;
    return await db.insert('TABLE_ACCOUNTS', accountData);
  }

  Future<List<Map<String, dynamic>>> getAllAccountEntries() async {
    final db = await database;
    return await db.query('TABLE_ACCOUNTS', orderBy: 'ACCOUNTS_id DESC');
  }

  Future<List<Map<String, dynamic>>> getAccountEntriesByEntryId(
    String entryId,
  ) async {
    final db = await database;
    return await db.query(
      'TABLE_ACCOUNTS',
      where: 'ACCOUNTS_entryid = ?',
      whereArgs: [entryId],
    );
  }

  Future<List<Map<String, dynamic>>> getAccountEntriesByMonth(
    String month,
    String year,
  ) async {
    final db = await database;
    return await db.query(
      'TABLE_ACCOUNTS',
      where: 'ACCOUNTS_month = ? AND ACCOUNTS_year = ?',
      whereArgs: [month, year],
      orderBy: 'ACCOUNTS_id DESC',
    );
  }

  Future<double> getTotalDebitAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(CAST(ACCOUNTS_amount AS REAL)) as total FROM TABLE_ACCOUNTS WHERE ACCOUNTS_type = ?',
      ['debit'],
    );
    return result.first['total'] as double? ?? 0.0;
  }
  // Future<void> restoreDatabaseFromJson(Map<String, dynamic> data) async {
  //   final db = await database;  // IMPORTANT: Ensures DB is reopened
  //
  //   await db.transaction((txn) async {
  //     for (var tableName in data.keys) {
  //       final List<dynamic> rows = data[tableName];
  //
  //       await txn.delete(tableName);
  //
  //       for (var row in rows) {
  //         Map<String, dynamic> fixedRow = {};
  //
  //         row.forEach((key, value) {
  //           if (value is String && _isBase64(value)) {
  //             fixedRow[key] = Uint8List.fromList(base64Decode(value));
  //           } else {
  //             fixedRow[key] = value;
  //           }
  //         });
  //
  //         await txn.insert(tableName, fixedRow,
  //             conflictAlgorithm: ConflictAlgorithm.replace);
  //       }
  //     }
  //   });
  // }
  //

  // /// Detect if string is Base64 (for BLOB restoration)
  // bool _isBase64(String str) {
  //   final base64RegExp = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
  //   return base64RegExp.hasMatch(str) && str.length % 4 == 0;
  // }
  Future<void> _(Database db) async {
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");

    for (var t in tables) {
      final tableName = t['name'] as String;
      print("🧹 Clearing table: $tableName");
      await db.delete(tableName);
    }
  }
  Future<double> getTotalCreditAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(CAST(ACCOUNTS_amount AS REAL)) as total FROM TABLE_ACCOUNTS WHERE ACCOUNTS_type = ?',
      ['credit'],
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<bool> validateDoubleEntry() async {
    final debitTotal = await getTotalDebitAmount();
    final creditTotal = await getTotalCreditAmount();
    return debitTotal == creditTotal;
  }
}

class TargetCategory {
  final int? id;
  final String name;
  final Uint8List? iconImage;
  final IconData? iconData;
  final bool isCustom;

  TargetCategory({
    this.id,
    required this.name,
    this.iconImage,
    this.iconData,
    this.isCustom = false,
  });
}
