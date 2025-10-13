import 'dart:convert';
import 'package:http/http.dart' as http;

class GraphQLService {
  static const String endpoint = 'http://localhost:3000/rpc/execute_graphql';
  static int kError = 1;
  static int kSuccess = 0;

  static Future<List<Map<String, dynamic>>> query(String query) async {
    List<Map<String, dynamic>> results = [{}, {}];

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'query': query}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        results[kSuccess] = jsonResponse;
      } else {
        results[kError] = {
          'message': 'Error en la solicitud: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      results[kError] = {
        'message': 'Error al procesar la solicitud: $e',
        'statusCode': 500,
      };
    }

    return results;
  }
}
