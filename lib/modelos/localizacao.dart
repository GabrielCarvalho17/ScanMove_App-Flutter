class Localizacao {
  final String localizacao;
  final String filial;

  Localizacao({
    required this.localizacao,
    required this.filial,
  });

  factory Localizacao.fromJson(Map<String, dynamic> json) {
    return Localizacao(
      localizacao: json['localizacao'],
      filial: json['filial'],
    );
  }
}
