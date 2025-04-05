import 'dart:math';

// Funciones utilitarias para cálculos
class CalculadoraUtils {
  // Función para calcular la cuota mensual (Sistema Francés)
  static double calcularCuotaMensual(double capital, double tasaAnual, int plazoMeses) {
    final tasaMensual = tasaAnual / 100 / 12;
    return capital * tasaMensual * pow(1 + tasaMensual, plazoMeses) / 
           (pow(1 + tasaMensual, plazoMeses) - 1);
  }
}