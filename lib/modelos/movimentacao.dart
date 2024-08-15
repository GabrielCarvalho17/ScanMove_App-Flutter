import 'package:AppEstoqueMP/modelos/peca.dart';
// Classe MovimentacaoModel
class MovimentacaoModel {
  final int movServidor;
  final String dataInicio;
  final String dataModificacao;
  final String status;
  final String usuario;
  final String origem;
  final String destino;
  final int totalPecas;
  final List<PecaModel> pecas;

  MovimentacaoModel({
    required this.movServidor,
    required this.dataInicio,
    required this.dataModificacao,
    required this.status,
    required this.usuario,
    required this.origem,
    required this.destino,
    required this.totalPecas,
    required this.pecas,
  });

  // Método para criar um objeto MovimentacaoModel a partir de um JSON
  factory MovimentacaoModel.fromJson(Map<String, dynamic> json) {
    return MovimentacaoModel(
      movServidor: json['movimentacao'],
      dataInicio: json['data_inicio'],
      dataModificacao: json['data_modificacao'],
      status: json['status'],
      usuario: json['usuario'],
      origem: json['origem'],
      destino: json['destino'],
      totalPecas: json['total_pecas'],
      pecas: (json['pecas'] as List<dynamic>)
          .map((item) => PecaModel.fromJson(item))
          .toList(),
    );
  }

  // Método toJson para enviar dados de volta ao servidor ou para outros propósitos
  Map<String, dynamic> toJson() {
    return {
      'movimentacao': movServidor,
      'data_inicio': dataInicio,
      'data_modificacao': dataModificacao,
      'status': status,
      'usuario': usuario,
      'origem': origem,
      'destino': destino,
      'total_pecas': totalPecas,
      'pecas': pecas.map((item) => item.toJson()).toList(),
    };
  }
}
