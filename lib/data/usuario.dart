class Usuario {
  final bool autenticado;
  final String email;
  final String? password;
  final String mensaje;
  final int idUsuario;
  final String? token;
  final String? idUsuarioFirebase;
  final String? authProvider;

  Usuario({
    this.autenticado = false,
    required this.email,
    this.password,
    this.mensaje = '',
    this.idUsuario = 0,
    this.token,
    this.idUsuarioFirebase,
    this.authProvider,
  });

  factory Usuario.fromAuthResponse(Map<String, dynamic> json) {
    return Usuario(
      autenticado: json['success'] as bool? ?? false,
      email: json['email'] as String? ?? '',
      mensaje: json['mensaje'] as String? ?? '',
      idUsuario: json['idUsuario'] is String 
          ? int.tryParse(json['idUsuario'] as String) ?? 0 
          : (json['idUsuario'] as num?)?.toInt() ?? 0,
      token: json['token'] as String?,
    );
  }

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

  Usuario copyWithAuthData({
    required bool authenticated,
    required String message,
    required int userId,
    String? token,
  }) {
    return Usuario(
      autenticado: authenticated,
      email: this.email,
      password: this.password,
      mensaje: message,
      idUsuario: userId,
      token: token,
      idUsuarioFirebase: this.idUsuarioFirebase,
      authProvider: this.authProvider,
    );
  }

   void validarParaRegistroLocal() {
    if (password == null || password!.isEmpty) {
      throw Exception('La contraseña es requerida para registro local');
    }
  }
}


