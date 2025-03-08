class Usuario {
  final String email;
  final String? password;
  final String? idUsuarioFirebase;
  final String? authProvider;

  Usuario({
    required this.email,
    this.password,
    this.idUsuarioFirebase,
    this.authProvider,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      email: json['email'] as String? ?? '',
      password: json['password'] as String?,
      idUsuarioFirebase: json['idUsuarioFirebase'] as String?,
      authProvider: json['authProvider'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      if (password != null) 'password': password,
      if (idUsuarioFirebase != null) 'idUsuarioFirebase': idUsuarioFirebase,
      if (authProvider != null) 'authProvider': authProvider,
    };
  }
}
