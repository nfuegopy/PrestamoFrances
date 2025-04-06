import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/product.dart';

class ProductService {
  static const String boxName = 'products';

  // Cargar productos desde un archivo JSON
  Future<List<Product>> loadProductsFromJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('No se seleccionó ningún archivo JSON.');
        return [];
      }

      final file = result.files.single;
      String jsonString;

      // Intentar leer el archivo desde bytes o desde la path
      if (file.bytes != null) {
        debugPrint('Leyendo archivo desde bytes...');
        jsonString = utf8.decode(file.bytes!, allowMalformed: true);
      } else if (file.path != null) {
        debugPrint('Leyendo archivo desde path: ${file.path}');
        final fileContent = await File(file.path!).readAsString();
        jsonString = fileContent;
      } else {
        debugPrint(
            'No se pudieron leer los datos del archivo JSON. Ni bytes ni path están disponibles.');
        return [];
      }

      debugPrint('Contenido del JSON: $jsonString');

      // Parsear el JSON
      final List<dynamic> jsonData = jsonDecode(jsonString);

      final products = <Product>[];
      for (var item in jsonData) {
        try {
          final name = item['nombre'].toString().trim();
          final price = double.tryParse(item['precio'].toString().trim());
          final currency = item['moneda'].toString().trim().toUpperCase();

          // Validar el precio
          if (price == null) {
            debugPrint('Precio inválido en item $item: ${item['precio']}');
            continue;
          }

          // Validar la moneda
          if (currency != 'GS' && currency != 'USD') {
            debugPrint('Moneda inválida en item $item: $currency');
            continue;
          }

          products.add(Product(
            name: name,
            price: price,
            currency: currency,
          ));
        } catch (e) {
          debugPrint('Error al parsear item $item: $e');
        }
      }

      // Guardar en Hive
      final box = await Hive.openBox<Product>(boxName);
      await box.clear(); // Limpiar productos anteriores
      await box.addAll(products);
      debugPrint('Productos guardados en Hive: ${products.length}');

      return products;
    } catch (e) {
      debugPrint('Error al cargar productos desde JSON: $e');
      return [];
    }
  }

  // Obtener todos los productos desde Hive
  Future<List<Product>> getProducts() async {
    final box = await Hive.openBox<Product>(boxName);
    final products = box.values.toList();
    debugPrint('Productos recuperados de Hive: ${products.length}');
    return products;
  }
}
