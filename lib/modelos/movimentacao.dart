import 'package:AppEstoqueMP/modelos/peca.dart';

class MovimentacaoModel {
  final int movSqlite; // Permitir que seja nulo inicialmente
  final int movServidor;
  final String dataInicio;
  final String dataModificacao;
  String status;
  final String usuario;
  String origem;
  String destino;
  int totalPecas;
  String filialOrigem;
  String filialDestino;
  List<PecaModel> pecas;

  MovimentacaoModel({
    required this.movSqlite,
    required this.movServidor,
    required this.dataInicio,
    required this.dataModificacao,
    required this.status,
    required this.usuario,
    required this.origem,
    required this.destino,
    required this.totalPecas,
    required this.filialOrigem,
    required this.filialDestino,
    required this.pecas,
  });

  MovimentacaoModel copyWith({
    int? movSqlite,
    int? movServidor,
    String? dataInicio,
    String? dataModificacao,
    String? status,
    String? usuario,
    String? origem,
    String? destino,
    int? totalPecas,
    String? filialOrigem,
    String? filialDestino,
    List<PecaModel>? pecas,
  }) {
    return MovimentacaoModel(
      movSqlite: movSqlite ?? this.movSqlite,
      movServidor: movServidor ?? this.movServidor,
      dataInicio: dataInicio ?? this.dataInicio,
      dataModificacao: dataModificacao ?? this.dataModificacao,
      status: status ?? this.status,
      usuario: usuario ?? this.usuario,
      origem: origem ?? this.origem,
      destino: destino ?? this.destino,
      totalPecas: totalPecas ?? this.totalPecas,
      filialOrigem: filialOrigem ?? this.filialOrigem,
      filialDestino: filialDestino ?? this.filialDestino,
      pecas: pecas ?? this.pecas,
    );
  }

  factory MovimentacaoModel.fromJson(Map<String, dynamic> json) {
    return MovimentacaoModel(
      movSqlite: json['mov_sqlite'],
      movServidor: json['movimentacao'],
      dataInicio: json['data_inicio'],
      dataModificacao: json['data_modificacao'],
      status: json['status'],
      usuario: json['usuario'],
      origem: json['origem'],
      destino: json['destino'],
      totalPecas: json['total_pecas'],
      filialOrigem: json['filial_origem'],
      filialDestino: json['filial_destino'],
      pecas: (json['pecas'] as List<dynamic>)
          .map((item) => PecaModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mov_sqlite': movSqlite,
      'movimentacao': movServidor,
      'data_inicio': dataInicio,
      'data_modificacao': dataModificacao,
      'status': status,
      'usuario': usuario,
      'origem': origem,
      'destino': destino,
      'total_pecas': totalPecas,
      'filial_origem': filialOrigem,
      'filial_destino': filialDestino,
      'pecas': pecas.map((item) => item.toJson()).toList(),
    };
  }

}
