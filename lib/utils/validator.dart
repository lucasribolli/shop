class Validator {

  static const String REGEX_EMAIL_EXPRESSION = r'[\w-\.]+@([\w-]+\.)+[\w-]{2,4}';

  static String? validateEmail(String email) {
    bool isEmpty = email.isEmpty;
    bool isEmail = email.contains(new RegExp(REGEX_EMAIL_EXPRESSION, multiLine: false));
    if(isEmpty || !isEmail) {
      return "Informe um e-mail válido";
    }
    return null;
  } 

  static String? validatePassword(String password) {
    bool isEmpty = password.isEmpty;
    bool isLessThan5 = password.length < 5;
    if(isEmpty || isLessThan5) {
      return "Informe uma senha válida";
    }
    return null;
  } 
}