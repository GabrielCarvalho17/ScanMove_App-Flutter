// Classe ItemMovimentacaoModel
class PecaModel {
  final String peca;
  final String partida;
  final String material;
  final String descMaterial;
  final String corMaterial;
  final String descCorMaterial;
  final String unidade;
  final double quantidade;

  PecaModel({
    required this.peca,
    required this.partida,
    required this.material,
    required this.descMaterial,
    required this.corMaterial,
    required this.descCorMaterial,
    required this.unidade,
    required this.quantidade,
  });

  // Método para criar um objeto ItemMovimentacaoModel a partir de um JSON
  factory PecaModel.fromJson(Map<String, dynamic> json) {
    return PecaModel(
      peca: json['peca'],
      partida: json['partida'],
      material: json['material'],
      descMaterial: json['desc_material'],
      corMaterial: json['cor_material'],
      descCorMaterial: json['desc_cor_material'],
      unidade: json['unidade'],
      quantidade: double.parse(
          json['quantidade'].toString()), // Garanta que seja um double
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'peca': peca,
      'partida': partida,
      'material': material,
      'desc_material': descMaterial,
      'cor_material': corMaterial,
      'desc_cor_material': descCorMaterial,
      'unidade': unidade,
      'quantidade': quantidade,
    };
  }
}
