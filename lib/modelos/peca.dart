class PecaModel {
  final String peca;
  final String partida;
  final String filial;
  final String localizacao;
  final String material;
  final String descMaterial;
  final String cor;
  final String descCor;
  final String unidade;
  final double qtde;

  PecaModel({
    required this.peca,
    required this.partida,
    required this.filial,
    required this.localizacao,
    required this.material,
    required this.descMaterial,
    required this.cor,
    required this.descCor,
    required this.unidade,
    required this.qtde,
  });

  factory PecaModel.fromJson(Map<String, dynamic> json) {
    return PecaModel(
      peca: json['peca'],
      partida: json['partida'],
      filial: json['filial'],
      localizacao: json['localizacao'],
      material: json['material'],
      descMaterial: json['desc_material'],
      cor: json['cor_material'],
      descCor: json['desc_cor_material'],
      unidade: json['unid_estoque'],
      qtde: double.parse(json['qtde'].toString().replaceAll(',', '.')), // Convertendo string para double
    );
  }
}
