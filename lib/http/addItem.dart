import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

Future<void> addItem(String type, double latitude, double longitude, DateTime dateTime) async {
  var uri = Uri.parse('http://192.168.1.4:43506/addItem.php'); // Ensure this points to your PHP script correctly
  var request = http.MultipartRequest('POST', uri)
    ..fields['type'] = type
    ..fields['latitude'] = latitude.toString()
    ..fields['longitude'] = longitude.toString()
    ..fields['dateTime'] = DateFormat("yyyy-MM-dd HH:mm:ss").format(dateTime); // Formatting dateTime

  try {
    var streamedResponse = await request.send();
    if (streamedResponse.statusCode == 200) {
      var response = await http.Response.fromStream(streamedResponse);
      var responseData = jsonDecode(response.body);
      print('Server response: ${responseData['message']}');
    } else {
      print('Failed to add item: ${streamedResponse.reasonPhrase}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
