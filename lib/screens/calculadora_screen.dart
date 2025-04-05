import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/amortizacion_model.dart';
import '../utils/pdf_generator.dart';
import 'pdf_preview_screen.dart';

class CalculadoraScreen extends StatefulWidget {
  const CalculadoraScreen({super.key});

  @override
  _CalculadoraScreenState createState() => _CalculadoraScreenState();
}

class _CalculadoraScreenState extends State<CalculadoraScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _mostrarTabla = false;

  // Controladores para los campos de texto
  final TextEditingController _capitalController = TextEditingController();
  final TextEditingController _tasaController = TextEditingController();
  final TextEditingController _plazoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _identificacionController =
      TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _fechaVencimientoController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los valores del modelo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final model = Provider.of<AmortizacionModel>(context, listen: false);
      _capitalController.text = model.capital.toString();
      _tasaController.text = model.tasa.toString();
      _plazoController.text = model.plazo.toString();
      _fechaController.text = model.fechaEmision;
      _fechaVencimientoController.text = model.fechaVencimiento ?? '';
    });
  }

  @override
  void dispose() {
    // Liberamos los controladores
    _capitalController.dispose();
    _tasaController.dispose();
    _plazoController.dispose();
    _nombreController.dispose();
    _identificacionController.dispose();
    _fechaController.dispose();
    _fechaVencimientoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<AmortizacionModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora de Préstamos'),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de datos del cliente
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos del Cliente',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12.0),

                      // Checkbox para cliente innominado
                      Row(
                        children: [
                          Checkbox(
                            value: model.esInnominado,
                            onChanged: (value) {
                              if (value != null) {
                                model.esInnominado = value;
                                if (value) {
                                  _nombreController.clear();
                                  _identificacionController.clear();
                                }
                              }
                            },
                          ),
                          const Text('Cliente Innominado'),
                        ],
                      ),

                      // Nombre del cliente
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del Cliente',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        enabled: !model.esInnominado,
                        onChanged: (value) => model.nombreCliente = value,
                      ),
                      const SizedBox(height: 12.0),

                      // Identificación
                      TextFormField(
                        controller: _identificacionController,
                        decoration: const InputDecoration(
                          labelText: 'Identificación / RUC',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        enabled: !model.esInnominado,
                        onChanged: (value) => model.identificacion = value,
                      ),
                      const SizedBox(height: 12.0),

                      // Fecha de emisión
                      InkWell(
                        onTap: () async {
                          if (!model.esInnominado) {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (fecha != null) {
                              final fechaStr =
                                  DateFormat('yyyy-MM-dd').format(fecha);
                              setState(() {
                                _fechaController.text = fechaStr;
                                model.fechaEmision = fechaStr;
                              });
                            }
                          }
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            controller: _fechaController,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Emisión',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12.0),

                      // Checkbox para omitir fecha de vencimiento
                      Row(
                        children: [
                          Checkbox(
                            value: model.fechaVencimiento == null,
                            onChanged: (value) {
                              if (value != null && value) {
                                setState(() {
                                  _fechaVencimientoController.clear();
                                  model.fechaVencimiento = null;
                                });
                              }
                            },
                          ),
                          const Text('Omitir Fecha de Vencimiento'),
                        ],
                      ),

                      // Fecha de vencimiento
                      InkWell(
                        onTap: () async {
                          if (model.fechaVencimiento != null ||
                              _fechaVencimientoController.text.isNotEmpty) {
                            final fecha = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (fecha != null) {
                              final fechaStr =
                                  DateFormat('yyyy-MM-dd').format(fecha);
                              setState(() {
                                _fechaVencimientoController.text = fechaStr;
                                model.fechaVencimiento = fechaStr;
                              });
                            }
                          }
                        },
                        child: IgnorePointer(
                          child: TextFormField(
                            controller: _fechaVencimientoController,
                            decoration: const InputDecoration(
                              labelText: 'Fecha de Vencimiento',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            enabled: model.fechaVencimiento != null ||
                                _fechaVencimientoController.text.isNotEmpty,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sección de parámetros del préstamo
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parámetros del Préstamo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12.0),

                      // Selector de moneda
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Moneda',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: model.moneda,
                        items: const [
                          DropdownMenuItem(
                            value: 'guaranies',
                            child: Text('Guaraníes (₲)'),
                          ),
                          DropdownMenuItem(
                            value: 'dolares',
                            child: Text('Dólares (USD)'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            model.moneda = value;
                            _capitalController.text = model.capital.toString();
                          }
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Capital
                      TextFormField(
                        controller: _capitalController,
                        decoration: InputDecoration(
                          labelText: 'Capital',
                          border: const OutlineInputBorder(),
                          prefixText:
                              model.moneda == 'guaranies' ? '₲ ' : '\$ ',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el capital';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Por favor ingrese un número válido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final capital = double.tryParse(value);
                          if (capital != null) {
                            model.capital = capital;
                          }
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Tasa de interés
                      TextFormField(
                        controller: _tasaController,
                        decoration: const InputDecoration(
                          labelText: 'Tasa de interés anual (%)',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese la tasa de interés';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Por favor ingrese un número válido';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final tasa = double.tryParse(value);
                          if (tasa != null) {
                            model.tasa = tasa;
                          }
                        },
                      ),
                      const SizedBox(height: 12.0),

                      // Plazo
                      TextFormField(
                        controller: _plazoController,
                        decoration: const InputDecoration(
                          labelText: 'Plazo (meses)',
                          border: OutlineInputBorder(),
                          suffixText: 'meses',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el plazo';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Por favor ingrese un número entero';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          final plazo = int.tryParse(value);
                          if (plazo != null) {
                            model.plazo = plazo;
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Resumen del préstamo
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12.0),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen del Préstamo',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildResumenItem(context, 'Cuota Mensual',
                              model.formatoMoneda(model.cuotaMensual)),
                          _buildResumenItem(context, 'Total a Pagar',
                              model.formatoMoneda(model.totalPagado)),
                          _buildResumenItem(context, 'Total Intereses',
                              model.formatoMoneda(model.totalIntereses)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Tabla de amortización
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'Tabla de Amortización',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _mostrarTabla = !_mostrarTabla;
                              });
                            },
                            icon: Icon(
                              _mostrarTabla
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                            ),
                            label: Text(
                              _mostrarTabla ? 'Ocultar' : 'Mostrar',
                              style: const TextStyle(fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      if (_mostrarTabla)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columnSpacing: 16,
                            columns: const [
                              DataColumn(
                                  label: Text('Mes',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Cuota',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Interés',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Capital',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                              DataColumn(
                                  label: Text('Saldo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold))),
                            ],
                            rows: model.tablaAmortizacion.map((fila) {
                              return DataRow(cells: [
                                DataCell(Text(fila.mes.toString())),
                                DataCell(Text(model.formatoMoneda(fila.cuota))),
                                DataCell(
                                    Text(model.formatoMoneda(fila.interes))),
                                DataCell(
                                    Text(model.formatoMoneda(fila.capital))),
                                DataCell(Text(model.formatoMoneda(fila.saldo))),
                              ]);
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Botón para generar PDF
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Mostrar indicador de progreso
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );

                      try {
                        final pdfGenerator = PdfGenerator();
                        final pdfBytes = await pdfGenerator.generarPdf(model);

                        // Cerrar diálogo de progreso
                        Navigator.pop(context);

                        // Navegar a la pantalla de previsualización y descarga del PDF
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPreviewScreen(
                              pdfBytes: pdfBytes,
                              fileName:
                                  'Proforma_Prestamo_${model.esInnominado ? 'Innominado' : model.nombreCliente.replaceAll(' ', '_')}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.pdf',
                            ),
                          ),
                        );
                      } catch (e) {
                        // Cerrar diálogo de progreso
                        Navigator.pop(context);

                        // Mostrar mensaje de error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al generar el PDF: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Generar y Descargar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'Desarrollado por Antonio Barrios',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResumenItem(BuildContext context, String titulo, String valor) {
    return Column(
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
