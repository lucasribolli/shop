import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:http/http.dart' as http;

class ProductFormScreen extends StatefulWidget {
  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  // https://cdn.pixabay.com/photo/2013/07/13/10/51/football-157930_960_720.png
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  final _formData = Map<String, Object?>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _imageUrlFocusNode.addListener(_updateImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_formData.isEmpty) {
      final product = ModalRoute.of(context)!.settings.arguments as Product?;

      if (product != null) {
        _formData['id'] = product.id;
        _formData['title'] = product.title;
        _formData['description'] = product.description;
        _formData['price'] = product.price;
        _formData['imageUrl'] = product.imageUrl;

        _imageUrlController.text = _formData['imageUrl'] as String;
      } else {
        _formData['price'] = '';
      }
    }
  }

  void _updateImage() {
    if (isValidImageUrl(_imageUrlController.text)) {
      setState(() {});
    }
  }

  bool isValidImageUrl(String url) {
    bool isValidProtocol = url.toLowerCase().startsWith('http://') ||
        url.toLowerCase().startsWith('https://');
    bool endsWithPng = url.toLowerCase().endsWith('.png');
    bool endsWithJpg = url.toLowerCase().endsWith('.jpg');
    bool endsWithJpeg = url.toLowerCase().endsWith('.jpeg');
    return ((isValidProtocol) && (endsWithPng || endsWithJpg || endsWithJpeg));
  }

  @override
  void dispose() {
    super.dispose();
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImage);
    _imageUrlFocusNode.dispose();
  }

  Future<void> _saveForm() async {
    bool isValid = _form.currentState!.validate();

    if (isValid) {
      _form.currentState!.save();

      final product = Product(
        id: _formData['id'] as String?,
        title: _formData['title'] as String?,
        price: _formData['price'] as double?,
        description: _formData['description'] as String?,
        imageUrl: _formData['imageUrl'] as String?,
        client: http.Client(),
      );

      setState(() {
        _isLoading = true;
      });

      final products = Provider.of<Products>(context, listen: false);
      
        try {
          if (_formData['id'] == null) {
            await products.addProduct(product);
          } else {
            await products.updateProduct(product);
          }
          Navigator.of(context).pop();
        } catch(error) {
          await showDialog<Null>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Ocorreu um erro!'),
              content: Text('Erro ao salvar produto'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            )
          );
        } finally {
          setState(() => _isLoading = false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Formul??rio'),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.save), onPressed: () => _saveForm())
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _formData['title'] as String?,
                      decoration: InputDecoration(
                        labelText: 'T??tulo',
                      ),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                      },
                      onSaved: (value) => _formData['title'] = value,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Informe um t??tulo v??lido';
                        }

                        return null;
                      },
                    ),
                    TextFormField(
                        initialValue: _formData['price'].toString(),
                        decoration: InputDecoration(labelText: 'Pre??o'),
                        textInputAction: TextInputAction.next,
                        focusNode: _priceFocusNode,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onFieldSubmitted: (_) {
                          FocusScope.of(context)
                              .requestFocus(_descriptionFocusNode);
                        },
                        onSaved: (value) =>
                            _formData['price'] = double.tryParse(value!) ?? 0.0,
                        validator: (value) {
                          bool isEmpty = value!.trim().isEmpty;
                          var newPrice = double.tryParse(value) ?? 0.0;
                          bool isInvalid = newPrice <= 0;

                          if (isEmpty || isInvalid) {
                            return 'Informe um pre??o v??lido!';
                          }

                          return null;
                        }),
                    TextFormField(
                        initialValue: _formData['description'] as String?,
                        decoration: InputDecoration(labelText: 'Descri????o'),
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        onSaved: (value) => _formData['description'] = value,
                        validator: (value) {
                          bool isEmpty = value!.trim().isEmpty;
                          bool isInvalid = value.trim().length < 5;

                          if (isEmpty || isInvalid) {
                            return 'Informe uma descri????o v??lida!';
                          }

                          return null;
                        }),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'URL da imagem'),
                            keyboardType: TextInputType.url,
                            focusNode: _imageUrlFocusNode,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) => _formData['imageUrl'] = value,
                            validator: (value) {
                              bool emptyUrl = value!.trim().isEmpty;
                              bool invalidUrl = !isValidImageUrl(value);
                              if (emptyUrl || invalidUrl) {
                                return 'Informe uma URL v??lida!';
                              }
                              return null;
                            },
                          ),
                        ),
                        Container(
                          height: 100,
                          width: 100,
                          margin: const EdgeInsets.only(top: 8, left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: SizedBox.expand(
                            child: _imageUrlController.text.isEmpty
                                ? Text('Informe a URL')
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
