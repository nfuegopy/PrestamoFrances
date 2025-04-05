import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/amortizacion_model.dart';
import 'screens/calculadora_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AmortizacionModel(),
      child: MaterialApp(
        title: 'Calculadora de Préstamos',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const CalculadoraScreen(),
      ),
    );
  }
}