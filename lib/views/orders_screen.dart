import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/order_widget.dart';

class OrdersScreen extends StatelessWidget {

  Future<void> _refreshOrders(BuildContext context) {
    return Provider.of<Orders>(context, listen: false).loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Meus pedidos')),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => _refreshOrders(context),
        child: FutureBuilder(
          future: Provider.of<Orders>(context, listen: false).loadOrders(),
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.error != null) {
              return Center(child: Text('Ocorreu um erro!'));
            } else {
              return Consumer<Orders>(
                builder: (context, orders, child) {
                  return ListView.builder(
                    itemCount: orders.itemsCount,
                    itemBuilder: (_, i) => OrderWidget(orders.items[i]));
                }
              );
            }
          }
        ),
      )
    );
  }
}
