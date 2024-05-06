import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> deleteItem(String dateTime) async {
  try {
    final response = await http.post(
      Uri.parse('http://172.28.64.35/ptyxiaki_bak/removeItem.php'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'dateTime': dateTime,
      },
    );

    // Parse the response body for more nuanced feedback
    final responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      if (responseData['success'] == true) { // Assuming the response contains a success flag
        print('Item deleted successfully');
      } else {
        // Handle the case where the server responds with 200 OK but action wasn't successful
        print('Failed to delete item: ${responseData['message']}'); // Assuming the response contains a message
      }
    } else {
      // The server may send a response body with more details about the failure
      print('Failed to delete item: ${response.statusCode}');
      print('Reason: ${response.body}');
    }
  } catch (e) {
    print('Network Error: $e');
    // It's a good practice to differentiate network errors from HTTP errors
  }
}
