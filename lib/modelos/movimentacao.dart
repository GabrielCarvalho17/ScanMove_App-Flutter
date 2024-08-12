class ItemMovimentacao {
  final String peca;
  final String partida;
  final String material;
  final String descMaterial;
  final String corMaterial;
  final String descCorMaterial;
  final String unidade;
  final double quantidade;
  final int movSqlite; // Campo para gerenciamento interno no app

  ItemMovimentacao({
    required this.peca,
    required this.partida,
    required this.material,
    required this.descMaterial,
    required this.corMaterial,
    required this.descCorMaterial,
    required this.unidade,
    required this.quantidade,
    required this.movSqlite, // Inicializa o campo movSqlite
  });

  // Método toJson com parâmetro opcional para incluir movSqlite
  Map<String, dynamic> toJson({bool includeMovSqlite = false}) {
    final Map<String, dynamic> json = {
      'peca': peca,
      'partida': partida,
      'material': material,
      'desc_material': descMaterial,
      'cor_material': corMaterial,
      'desc_cor_material': descCorMaterial,
      'unidade': unidade,
      'quantidade': quantidade,
    };

    if (includeMovSqlite) {
      json['mov_sqlite'] = movSqlite;
    }

    return json;
  }
}

class Movimentacao {
  final String dataInicio;
  final String dataModificacao;
  final String status;
  final String usuario;
  final String origem;
  final String destino;
  final int totalPecas;
  final List<ItemMovimentacao> itens;

  Movimentacao({
    required this.dataInicio,
    required this.dataModificacao,
    required this.status,
    required this.usuario,
    required this.origem,
    required this.destino,
    required this.totalPecas,
    required this.itens,
  });

  // Método toJson para converter Movimentacao e seus itens em JSON
  Map<String, dynamic> toJson() {
    return {
      'data_inicio': dataInicio,
      'data_modificacao': dataModificacao,
      'status': status,
      'usuario': usuario,
      'origem': origem,
      'destino': destino,
      'total_pecas': totalPecas,
      'itens': itens.map((item) => item.toJson()).toList(),
    };
  }
}
