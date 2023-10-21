import 'package:http/http.dart' as http;

class Http{

  static Future<http.Response> getImageFromApi(String uri) async {
    var response = await http.get(Uri.parse(uri));
    return response;
  }
}