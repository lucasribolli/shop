class AuthException implements Exception {
  static const Map<String, String> errors = {
    "EMAIL_NOT_FOUND": "E-mail ou senha inválidos",
    "INVALID_PASSWORD": "E-mail ou senha inválidos",
    "USER_DISABLED": "Usuário desativado",
    "EMAIL_EXISTS": "E-mail já utilizado em outra conta",
    "OPERATION_NOT_ALLOWED": "Operação não permitida",
    "TOO_MANY_ATTEMPTS_TRY_LATER": "Tente mais tarde!",
  };

  final String key;

  const AuthException(this.key);

  @override
  String toString() {
    if(errors.containsKey(key)) {
      return errors[key];
    } else {
      return 'Ocorreu um erro na autenticação';
    }
  }

}