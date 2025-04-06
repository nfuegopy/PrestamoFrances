import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'product.dart';

class FilaAmortizacion {
  final int mes;
  final double cuota;
  final double interes;
  final double capital;
  final double saldo;

  FilaAmortizacion({
    required this.mes,
    required this.cuota,
    required this.interes,
    required this.capital,
    required this.saldo,
  });
}

class AmortizacionModel extends ChangeNotifier {
  double _capital = 0; // Ahora el capital será dinámico
  double _tasa = 10.0;
  int _plazo = 12;
  String _moneda = 'guaranies';
  String _nombreCliente = '';
  bool _esInnominado = false;
  String _identificacion = '';
  String _fechaEmision = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String? _fechaVencimiento;
  List<FilaAmortizacion> _tablaAmortizacion = [];
  double _cuotaMensual = 0;
  double _totalPagado = 0;
  double _totalIntereses = 0;
  List<Product> _selectedProducts = []; // Lista de productos seleccionados

  // Getters
  double get capital => _capital;
  double get tasa => _tasa;
  int get plazo => _plazo;
  String get moneda => _moneda;
  String get nombreCliente => _nombreCliente;
  bool get esInnominado => _esInnominado;
  String get identificacion => _identificacion;
  String get fechaEmision => _fechaEmision;
  String? get fechaVencimiento => _fechaVencimiento;
  List<FilaAmortizacion> get tablaAmortizacion => _tablaAmortizacion;
  double get cuotaMensual => _cuotaMensual;
  double get totalPagado => _totalPagado;
  double get totalIntereses => _totalIntereses;
  List<Product> get selectedProducts => _selectedProducts;

  // Setters
  set capital(double value) {
    _capital = value;
    calcularAmortizacion();
    notifyListeners();
  }

  set tasa(double value) {
    _tasa = value;
    calcularAmortizacion();
    notifyListeners();
  }

  set plazo(int value) {
    _plazo = value;
    calcularAmortizacion();
    notifyListeners();
  }

  set moneda(String value) {
    if (value != _moneda) {
      if (value == 'guaranies' && _capital < 1000) {
        _capital = _capital * 7000;
      } else if (value == 'dolares' && _capital > 1000) {
        _capital = _capital / 7000;
      }
    }
    _moneda = value;
    calcularAmortizacion();
    notifyListeners();
  }

  set nombreCliente(String value) {
    _nombreCliente = value;
    notifyListeners();
  }

  set esInnominado(bool value) {
    _esInnominado = value;
    if (value) {
      _nombreCliente = '';
      _identificacion = '';
    }
    notifyListeners();
  }

  set identificacion(String value) {
    _identificacion = value;
    notifyListeners();
  }

  set fechaEmision(String value) {
    _fechaEmision = value;
    notifyListeners();
  }

  set fechaVencimiento(String? value) {
    _fechaVencimiento = value;
    notifyListeners();
  }

  // Método para actualizar los productos seleccionados y recalcular el capital
  void updateSelectedProducts(List<Product> products) {
    _selectedProducts = products;

    // Calcular el capital sumando los precios de los productos seleccionados
    double total = 0;
    String? detectedCurrency;

    for (var product in products) {
      if (detectedCurrency == null) {
        detectedCurrency = product.currency;
      }

      if (product.currency == detectedCurrency) {
        total += product.price;
      } else {
        // Convertir a la moneda base (GS) si hay monedas mixtas
        if (product.currency == 'GS' && detectedCurrency == 'USD') {
          total += product.price / 7000;
        } else if (product.currency == 'USD' && detectedCurrency == 'GS') {
          total += product.price * 7000;
        }
      }
    }

    // Actualizar la moneda del préstamo según la moneda detectada
    _moneda = detectedCurrency == 'USD' ? 'dolares' : 'guaranies';
    _capital = total;

    // Aplicar tasa de interés predeterminada según la moneda
    _tasa = _moneda == 'guaranies' ? 18.0 : 13.0;

    calcularAmortizacion();
    notifyListeners();
  }

  // Formateador de moneda
  String formatoMoneda(double valor) {
    if (_moneda == 'guaranies') {
      final formatter = NumberFormat("#,##0", "es_PY");
      return '₲ ${formatter.format(valor)}'.replaceAll(',', '.');
    } else {
      return NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
      ).format(valor);
    }
  }

  // Cálculo de la cuota mensual (Sistema Francés)
  double calcularCuotaMensual(double capital, double tasaAnual, int plazoMeses) {
    final tasaMensual = tasaAnual / 100 / 12;
    return capital *
        tasaMensual *
        pow(1 + tasaMensual, plazoMeses) /
        (pow(1 + tasaMensual, plazoMeses) - 1);
  }

  // Método para calcular la tabla de amortización
  void calcularAmortizacion() {
    final tasaMensual = _tasa / 100 / 12;
    final cuota = calcularCuotaMensual(_capital, _tasa, _plazo);

    double saldoPendiente = _capital;
    final List<FilaAmortizacion> tabla = [];
    double totalInteresesPagados = 0;

    for (int mes = 1; mes <= _plazo; mes++) {
      final interesMes = saldoPendiente * tasaMensual;
      final capitalAmortizado = cuota - interesMes;
      saldoPendiente -= capitalAmortizado;

      totalInteresesPagados += interesMes;

      tabla.add(FilaAmortizacion(
        mes: mes,
        cuota: cuota,
        interes: interesMes,
        capital: capitalAmortizado,
        saldo: saldoPendiente > 0 ? saldoPendiente : 0,
      ));
    }

    _cuotaMensual = cuota;
    _totalPagado = cuota * _plazo;
    _totalIntereses = totalInteresesPagados;
    _tablaAmortizacion = tabla;
  }

  AmortizacionModel() {
    calcularAmortizacion();
  }

  void reset() {
    _capital = 0;
    _tasa = 10.0;
    _plazo = 12;
    _moneda = 'guaranies';
    _nombreCliente = '';
    _esInnominado = false;
    _identificacion = '';
    _fechaEmision = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fechaVencimiento = null;
    _selectedProducts = [];
    calcularAmortizacion();
    notifyListeners();
  }
}