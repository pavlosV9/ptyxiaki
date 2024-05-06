import 'package:http/http.dart' as http;

Future<void> deleteAllItems() async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost/removeAllItems.php'),
      // If you need to send data in the body or headers, add them here
      // body: { 'key': 'value' },
      // headers: { 'Authorization': 'Bearer your_token_here' },
    );

    if (response.statusCode == 200) {
      print('All items deleted successfully');
      // Optionally, you can decode and use the response body if needed
      // var responseData = json.decode(response.body);
    } else {
      print('Failed to delete all items: ${response.statusCode}');
      // Handle different status codes or errors differently if needed
    }
  } catch (e) {
    print('Error: $e');
    // Properly handle exceptions, like showing an error message to the user
  }
}
