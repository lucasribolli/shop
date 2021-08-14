import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop/providers/orders.dart';

class OrderWidget extends StatefulWidget {
  final Order order;
  OrderWidget(this.order);

  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  bool _expanded = false;
  static const int _expandedDuration = 300;

  @override
  Widget build(BuildContext context) {
    final itemsHeight = (widget.order.products!.length * 25.0) + 10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: _expandedDuration),
      height: _expanded ? itemsHeight + 92 : 92,
      child: Card(
          margin: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('R\$${widget.order.total!.toStringAsFixed(2)}'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy hh:mm').format(widget.order.date!),
                ),
                trailing: IconButton(
                  icon: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    child: Icon(_expanded ? Icons.expand_more : Icons.expand_less),
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: _expandedDuration),
                height: _expanded ? itemsHeight : 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4,
                ),
                child: ListView(
                  children: widget.order.products!.map((product) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          product.title!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${product.quantity}x R\$${product.price}',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
            ],
          )),
    );
  }
}
