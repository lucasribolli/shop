import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/utils/validator.dart';

enum AuthMode { Signup, Login }

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> 
 with TickerProviderStateMixin {
  GlobalKey<FormState> _form = GlobalKey();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final _passwordController = TextEditingController();

  final Map<String, String?> _authData = {
    'email': '', 
    'password': ''
  };

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _passwordController.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ocorreu um erro!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fechar')
          )
        ],
      )
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _form.currentState!.save();

    Auth auth = Provider.of(context, listen: false);

    try {
      if (_authMode == AuthMode.Login) {
        await auth.login(
          _authData["email"],
          _authData["password"],
        );
      } else if (_authMode == AuthMode.Signup) {
        await auth.signup(
          _authData["email"],
          _authData["password"],
        );
      }
    } on AuthException catch(error) {
      _showErrorDialog(error.toString());
    } catch(error) {
      _showErrorDialog('Ocorreu um erro inesperado');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _animationController.forward();
    } else if (_authMode == AuthMode.Signup) {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: AnimatedSize(
        vsync: this,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeIn,
        child: Container(
          width: deviceSize.width * 0.75,
          height: _authMode == AuthMode.Login ? 290 : 350,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) => Validator.validateEmail(email!),
                  onSaved: (value) => _authData['email'] = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Senha'),
                  controller: _passwordController,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  validator: (password) => Validator.validatePassword(password!),
                  onSaved: (value) => _authData['password'] = value,
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.linear,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Confirmar senha'),
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        validator: _authMode == AuthMode.Signup
                            ? (password) {
                                if (password != _passwordController.text) {
                                  return 'Senha são diferentes';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      minimumSize: Size(88, 36),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: TextStyle(
                        color: Theme.of(context).primaryTextTheme.button!.color
                      ),
                    ),
                    child: Text(
                      _authMode == AuthMode.Login ? 'Entrar' : 'Registrar',
                    ),
                    onPressed: _submit,
                  ),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    "Alterar para ${_authMode == AuthMode.Login ? 'Registrar' : 'Login'}",
                  ),
                  style: TextButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}
