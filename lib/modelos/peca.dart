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
  final String filial;

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
    required this.filial,
  });

  PecaModel copyWith({
    String? peca,
    String? partida,
    String? material,
    String? descMaterial,
    String? corMaterial,
    String? descCorMaterial,
    String? localizacao,
    String? unidade,
    double? quantidade,
    String? filial,
  }) {
    return PecaModel(
      peca: peca ?? this.peca,
      partida: partida ?? this.partida,
      material: material ?? this.material,
      descMaterial: descMaterial ?? this.descMaterial,
      corMaterial: corMaterial ?? this.corMaterial,
      descCorMaterial: descCorMaterial ?? this.descCorMaterial,
      localizacao: localizacao ?? this.localizacao,
      unidade: unidade ?? this.unidade,
      quantidade: quantidade ?? this.quantidade,
      filial: filial ?? this.filial,
    );
  }

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
      filial: json['filial'],
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
      'filial': filial,
    };
  }
}
