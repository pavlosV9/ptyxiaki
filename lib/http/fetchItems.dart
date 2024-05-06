import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> fetchItems() async {
  var url = Uri.parse('http://localhost/loadItems.php'); // Ensure the URL is correct
  var client = http.Client();
  try {
    var response = await client.get(url);
    if (response.statusCode == 200) {
      print('Items fetched successfully');
      // Check for empty response body before decoding
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      } else {
        throw Exception('Empty response body');
      }
    } else {
      // Consider using a custom Exception for better error handling
      throw Exception('Failed to fetch items: ${response.statusCode}');
    }
  } catch (e) {
    // Printing the error to console is helpful for debugging but consider better error handling strategy for production
    print('Error: $e');
    return []; // Return an empty list in case of error
  } finally {
    client.close(); // Ensuring the client is closed after operation
  }
}
