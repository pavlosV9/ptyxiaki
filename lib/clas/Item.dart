import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
class Item {

  File? image;
  DateTime? dateTime;
  String? type;
  double? long;
  double? lat;
  String? id; // UUID

  Item({this.lat, this.long, this.dateTime, this.image, this.type, this.id});
}

class ItemBrain with ChangeNotifier {
  List<Item> itemList = [];

  List<Item> getList() {
    return itemList;
  }



  void removeItem(int index) async {
    if (index >= 0 && index < itemList.length) {
      Item itemToRemove = itemList[index];
      // Ensure there is a unique 'id' for this item

      // Attempt to remove the item from the remote server
      var url = Uri.parse('https://cis.cut.ac.cy/~pk.valiantis/ptyxiaki_bak/deleteitem.php');
      try {
        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: {
            'latitude': itemToRemove.lat.toString().trim(),
            'longitude': itemToRemove.long.toString().trim(),
            'type': itemToRemove.type!.trim(),
          },
        );

        if (response.statusCode != 200) {
          print("Failed to remove item from server. Status Code: ${response.statusCode}. Response: ${response.body}");
          return; // Optionally, stop the local deletion if server-side deletion fails
        }
      } catch (e) {
        print("Error contacting server to remove item: $e");
        return; // Optionally, stop the local deletion if there's an error contacting the server
      }

      // Proceed with local deletion as the server-side deletion was successful
      final db = await _getDatabase();
      try {
        // Use the 'id' for deletion if your local DB schema supports it
        await db.delete(
          'items',
          where: 'dateTime = ?',
          whereArgs: [itemToRemove.dateTime!.toIso8601String()],
        );
        itemList.removeAt(index);
        notifyListeners();
        print("Item removed successfully from both server and local database.");
      } catch (e) {
        print("Error removing item from local database: $e");
      }
    } else {
      print("Invalid index, item not found.");
    }
  }







  void removeList() async {
    var url = Uri.parse('https://cis.cut.ac.cy/~pk.valiantis/ptyxiaki_bak/remove.php'); // Your new PHP script URL for deletion

    var response = await http.post(url); // Assuming no additional data is needed

    if (response.statusCode == 200) {
      // Success
      print('All items removed successfully');
      // Update local database and UI accordingly
      removeList(); // Calling your existing local delete function
    } else {
      // Error
      print('Failed to remove items');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
    }
    final db = await _getDatabase();
    try {
      await db.delete(
        'items', // Assuming 'items' is your table name
        // No 'where' clause means delete all rows
      );

      itemList.clear();
      notifyListeners();
      print("All items removed successfully.");
    } catch (e) {
      print("Error removing all items: $e");
      // Optionally, handle the error in your UI, e.g., by showing a SnackBar
    }
  }


  Future<void> addToListHybrid(File? image, DateTime? dateTime, String? type, double? lat, double? long) async {
    String newId = uuid.v4();

    var url = Uri.parse('https://cis.cut.ac.cy/~pk.valiantis/ptyxiaki_bak/back.php'); // Your PHP script URL

    var isDuplicate = itemList.any((item) => item.dateTime == dateTime && item.type == type);
    if (!isDuplicate) {

      // Attempt to insert into the remote database firs
      var response = await http.post(
        url,
        body: {
          'id': newId,
          'type': type,
          'latitude': lat.toString(),
          'longitude': long.toString(),
          'dateTime': dateTime!.toIso8601String(),
          'imagepath': image!.path
        },
        // headers: {'Content-Type': 'application/x-www-form-urlencoded'}, // Uncomment if needed
      );

      if (response.statusCode == 200) {
        // Success
        print('Item added successfully');
      } else {
        // Error
        print('Failed to add item');
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }
      // Proceed with local database insertion if remote insertion was successful
      final db = await _getDatabase();
      await db.insert(
        'items',
        {
          'image_path': image?.path,
          'dateTime': dateTime?.toIso8601String(),
          'type': type,
          'latitude': lat,
          'longitude': long,
        },
        conflictAlgorithm: sql.ConflictAlgorithm.replace,
      );

      final newItem = Item(
        id: newId,
        image: image,
        dateTime: dateTime,
        type: type,
        lat: lat,
        long: long,
      );

      itemList.add(newItem);
      notifyListeners();
      print('Item added to both databases successfully');


    }
  }



  Future<void> uploadImage(File imageFile) async {
    try {
      var uri = Uri.parse('https://cis.cut.ac.cy/~pk.valiantis/ptyxiaki_bak/upload_image.php'); // Your PHP script URL for uploading images
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath(
          'fileToUpload', // The field name must match the name expected by your PHP script
          imageFile.path,
          filename: path.basename(imageFile.path), // Extracts the file name from the path
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        // Optionally, receive the response from the server
        String responseBody = await response.stream.bytesToString();
        print('File uploaded successfully: $responseBody');
      } else {
        print('File upload failed with status code: ${response.statusCode}');
        // Optionally, read the response body if the upload failed
        String responseBody = await response.stream.bytesToString();
        print('Failure response: $responseBody');
      }
    } catch (e) {
      print('Error during file upload: $e');
    }
  }



  Future<Database> _getDatabase() async {
    final dbPath = await sql.getDatabasesPath();
    print('Database path: $dbPath'); // Debugging database path

    return sql.openDatabase(
      path.join(dbPath, 'items.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE items(dateTime TEXT PRIMARY KEY, image_path TEXT, type TEXT, latitude REAL, longitude REAL)',
        );
      },
      version: 1, // Adjusted version to 1 for simplicity, modify as per your versioning strategy
    );
    print('Database opened or created successfully'); // Confirm database is ready

  }

  Future<void> loadList() async {
    final db = await _getDatabase();
    final data = await db.query('items');
    itemList = data.map((row) {
      final dateTimeStr = row['dateTime'] as String;
      final dateTime = DateTime.parse(dateTimeStr);
      final imagePath = row['image_path'] as String?;
      File? image = imagePath != null ? File(imagePath) : null;
      final type = row['type'] as String?;
      final latitude = row['latitude'] as double?;
      final longitude = row['longitude'] as double?;

      return Item(
        dateTime: dateTime,
        image: image,
        type: type,
        lat: latitude,
        long: longitude,
      );
    }).toList();
    print('Loaded ${data.length} items from database');

    notifyListeners();
  }
}
