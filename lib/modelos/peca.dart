class PecaModel {
  final String peca;
  final String partida;
  final String material;
  final String descMaterial;
  final String corMaterial;
  final String descCorMaterial;
  final String localizacao;
  final String unidade;
  final double quantidade;
  final String filialOrigem;

  PecaModel({
    required this.peca,
    required this.partida,
    required this.material,
    required this.descMaterial,
    required this.corMaterial,
    required this.descCorMaterial,
    required this.localizacao,
    required this.unidade,
    required this.quantidade,
    required this.filialOrigem,
  });


  factory PecaModel.fromJson(Map<String, dynamic> json) {
    return PecaModel(
      peca: json['peca'],
      partida: json['partida'],
      material: json['material'],
      descMaterial: json['desc_material'],
      corMaterial: json['cor_material'],
      descCorMaterial: json['desc_cor_material'],
      localizacao: json['localizacao'],
      unidade: json['unidade'],
      quantidade: double.parse(json['quantidade'].toString()),
      filialOrigem: json['filial_origem'],
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
      'localizacao': localizacao,
      'unidade': unidade,
      'quantidade': quantidade,
      'filial_origem': filialOrigem,
    };
  }
}
