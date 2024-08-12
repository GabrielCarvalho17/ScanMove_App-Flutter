import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:AppEstoqueMP/modelos/movimentacao.dart'; // Importar o arquivo com os modelos

class MovimentacaoService {
  final String apiUrl = "https://sua-api.com/api/movimentacoes/";

  Future<List<Movimentacao>> fetchMovimentacoes() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Movimentacao.fromJson(data)).toList();
    } else {
      throw Exception('Falha ao carregar as movimentações');
    }
  }

  Future<Movimentacao> fetchMovimentacao(int id) async {
    final response = await http.get(Uri.parse("$apiUrl$id/"));

    if (response.statusCode == 200) {
      return Movimentacao.fromJson(json.decode(response.body));
    } else {
      throw Exception('Falha ao carregar a movimentação');
    }
  }

  Future<http.Response> createMovimentacao(Movimentacao movimentacao) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(movimentacao.toJson()),
    );
    return response;
  }

  Future<http.Response> updateMovimentacao(
      int id, Movimentacao movimentacao) async {
    final response = await http.put(
      Uri.parse("$apiUrl$id/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(movimentacao.toJson()),
    );
    return response;
  }

  Future<http.Response> deleteMovimentacao(int id) async {
    final response = await http.delete(Uri.parse("$apiUrl$id/"));
    return response;
  }
}
