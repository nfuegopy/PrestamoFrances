import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/amortizacion_model.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Product> _products = [];
  List<Product> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final productService = ProductService();
    final products = await productService.getProducts();
    setState(() {
      _products = products;
    });
  }

  Future<void> _loadJson() async {
    final productService = ProductService();
    final products = await productService.loadProductsFromJson(); // Cambiar a loadProductsFromJson
    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cargar el JSON. Verifica el formato del archivo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _products = products;
      _selectedProducts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _loadJson,
            tooltip: 'Cargar JSON',
          ),
        ],
      ),
      body: _products.isEmpty
          ? const Center(child: Text('No hay productos cargados. Carga un JSON.'))
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final isSelected = _selectedProducts.contains(product);
                return CheckboxListTile(
                  title: Text(product.name),
                  subtitle: Text(
                      '${product.currency == 'GS' ? '₲' : '\$'} ${product.price.toStringAsFixed(2)}'),
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedProducts.add(product);
                      } else {
                        _selectedProducts.remove(product);
                      }
                    });
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<AmortizacionModel>(context, listen: false)
              .updateSelectedProducts(_selectedProducts);
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}