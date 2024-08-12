class MovimentacaoItem {
  final String peca;
  final String partida;
  final String material;
  final String corMaterial;
  final String unidade;
  final double quantidade;

  MovimentacaoItem({
    required this.peca,
    required this.partida,
    required this.material,
    required this.corMaterial,
    required this.unidade,
    required this.quantidade,
  });

  factory MovimentacaoItem.fromJson(Map<String, dynamic> json) {
    return MovimentacaoItem(
      peca: json['peca'],
      partida: json['partida'],
      material: json['material'],
      corMaterial: json['cor_material'],
      unidade: json['unidade'],
      quantidade: (json['quantidade'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peca': peca,
      'partida': partida,
      'material': material,
      'cor_material': corMaterial,
      'unidade': unidade,
      'quantidade': quantidade,
    };
  }
}

class Movimentacao {
  final int movimentacao;
  final DateTime data;
  final String usuario;
  final String origem;
  final String destino;
  final int totalPecas;
  final List<MovimentacaoItem> itens;

  Movimentacao({
    required this.movimentacao,
    required this.data,
    required this.usuario,
    required this.origem,
    required this.destino,
    required this.totalPecas,
    required this.itens,
  });

  factory Movimentacao.fromJson(Map<String, dynamic> json) {
    return Movimentacao(
      movimentacao: json['movimentacao'],
      data: DateTime.parse(json['data']),
      usuario: json['usuario'],
      origem: json['origem'],
      destino: json['destino'],
      totalPecas: json['total_pecas'],
      itens: (json['itens'] as List)
          .map((item) => MovimentacaoItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movimentacao': movimentacao,
      'data': data.toIso8601String(),
      'usuario': usuario,
      'origem': origem,
      'destino': destino,
      'total_pecas': totalPecas,
      'itens': itens.map((item) => item.toJson()).toList(),
    };
  }
}
