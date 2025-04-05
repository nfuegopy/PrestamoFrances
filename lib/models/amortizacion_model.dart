import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
  double _capital = 5000000;
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

  // Setters que recalculan la tabla de amortización
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
    // Convertir el capital si cambia la moneda
    if (value != _moneda) {
      if (value == 'guaranies' && _capital < 1000) {
        _capital = _capital * 7000; // Convertir de USD a PYG (aproximado)
      } else if (value == 'dolares' && _capital > 1000) {
        _capital = _capital / 7000; // Convertir de PYG a USD (aproximado)
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
    // Setter para fecha de vencimiento
    _fechaVencimiento = value;
    notifyListeners();
  }

  // Formateador de moneda
  // Formateador de moneda
// Formateador de moneda (ya ajustado anteriormente)
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
  double calcularCuotaMensual(
      double capital, double tasaAnual, int plazoMeses) {
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

  // Constructor que inicializa la tabla de amortización
  AmortizacionModel() {
    calcularAmortizacion();
  }

  // Método para limpiar el formulario
  void reset() {
    _capital = 100000000;
    _tasa = 10.0;
    _plazo = 12;
    _moneda = 'guaranies';
    _nombreCliente = '';
    _esInnominado = false;
    _identificacion = '';
    _fechaEmision = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fechaVencimiento = null;
    calcularAmortizacion();
    notifyListeners();
  }
}
