import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static Future<double> getRate(String from, String to) async {
    if (from == to) return 1.0;

    final url = Uri.parse(
      'https://api.frankfurter.dev/v2/rate/$from/$to',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('د اسعارو نرخ ترلاسه نه شو');
    }

    final data = jsonDecode(response.body);
    return (data['rate'] as num).toDouble();
  }
}
 
