  class LocalizacaoModel {
    final String localizacao;
    final String filial;

    LocalizacaoModel({
      required this.localizacao,
      required this.filial,
    });

    factory LocalizacaoModel.fromJson(Map<String, dynamic> json) {
      return LocalizacaoModel(
        localizacao: json['localizacao'],
        filial: json['filial'],
      );
    }
  }
