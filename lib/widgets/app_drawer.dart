import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/utils/app_routes.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Bem-vindo!'),
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Loja'),
            onTap: () {
              Navigator.pushReplacementNamed(
                context, 
                AppRoutes.AUTH_HOME
              );
            }
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('Pedidos'),
            onTap: () {
              Navigator.pushReplacementNamed(
                context, 
                AppRoutes.ORDERS
              );
            }
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Gerenciar Produtos'),
            onTap: () {
              Navigator.pushReplacementNamed(
                context, 
                AppRoutes.PRODUCTS
              );
            }
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Sair'),
            onTap: () async {
              await Provider.of<Auth>(context, listen: false).logout();
              await Navigator.of(context)
                .pushReplacementNamed(AppRoutes.AUTH_HOME);
            }
          ),
        ],
      )
    );
  }
}