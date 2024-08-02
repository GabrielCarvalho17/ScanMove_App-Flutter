class Autenticacao {
  final String accessToken;
  final String refreshToken;

  Autenticacao({required this.accessToken, required this.refreshToken});

  factory Autenticacao.fromJson(Map<String, dynamic> json) {
    return Autenticacao(
      accessToken: json['access'],
      refreshToken: json['refresh'],
    );
  }
}
