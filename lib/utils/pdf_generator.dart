import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/amortizacion_model.dart';

class PdfGenerator {
  Future<Uint8List> generarPdf(AmortizacionModel model) async {
    // Crear documento PDF
    final pdf = pw.Document();

    // Definir estilos
    final baseTextStyle = pw.TextStyle(fontSize: 10);
    final boldTextStyle =
        pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold);
    final titleStyle =
        pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold);
    final subtitleStyle =
        pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold);

    // Agregar página
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Título
            pw.Center(
              child: pw.Text(
                'Proforma de Préstamo',
                style: titleStyle,
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Sistema de Amortización Francés',
                style: pw.TextStyle(fontSize: 14),
              ),
            ),
            pw.SizedBox(height: 20),

            // Datos del cliente
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 1, color: PdfColors.grey300)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Datos del Cliente', style: subtitleStyle),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Cliente: ${model.esInnominado ? 'Cliente Innominado' : model.nombreCliente}',
                              style: baseTextStyle),
                          if (!model.esInnominado &&
                              model.identificacion.isNotEmpty)
                            pw.Text('Identificación: ${model.identificacion}',
                                style: baseTextStyle),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Fecha de Emisión: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(model.fechaEmision))}',
                              style: baseTextStyle),
                          if (model.fechaVencimiento !=
                              null) // Mostrar solo si está definida
                            pw.Text(
                                'Fecha de Vencimiento: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(model.fechaVencimiento!))}',
                                style: baseTextStyle),
                          pw.Text(
                              'Moneda: ${model.moneda == 'guaranies' ? 'Guaraníes (₲)' : 'Dólares (USD)'}',
                              style: baseTextStyle),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Detalles del préstamo
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 10),
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    bottom: pw.BorderSide(width: 1, color: PdfColors.grey300)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Detalles del Préstamo', style: subtitleStyle),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Capital: ${model.formatoMoneda(model.capital)}',
                              style: baseTextStyle),
                          pw.Text('Tasa de Interés Anual: ${model.tasa}%',
                              style: baseTextStyle),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Plazo: ${model.plazo} meses',
                              style: baseTextStyle),
                          pw.Text(
                              'Cuota Mensual: ${model.formatoMoneda(model.cuotaMensual)}',
                              style: baseTextStyle),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Resumen financiero
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Resumen Financiero', style: subtitleStyle),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildResumenBox(
                      'Capital Prestado',
                      model.formatoMoneda(model.capital),
                      baseTextStyle,
                      boldTextStyle,
                    ),
                    _buildResumenBox(
                      'Total Intereses',
                      model.formatoMoneda(model.totalIntereses),
                      baseTextStyle,
                      boldTextStyle,
                    ),
                    _buildResumenBox(
                      'Monto Total a Pagar',
                      model.formatoMoneda(model.totalPagado),
                      baseTextStyle,
                      boldTextStyle,
                      highlight: true,
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Tabla de amortización
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Tabla de Amortización', style: subtitleStyle),
                pw.SizedBox(height: 10),
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(40),
                    1: const pw.FlexColumnWidth(),
                    2: const pw.FlexColumnWidth(),
                    3: const pw.FlexColumnWidth(),
                    4: const pw.FlexColumnWidth(),
                  },
                  children: [
                    // Encabezado de la tabla
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Mes',
                              style: boldTextStyle,
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Cuota',
                              style: boldTextStyle,
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Interés',
                              style: boldTextStyle,
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Capital',
                              style: boldTextStyle,
                              textAlign: pw.TextAlign.center),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text('Saldo',
                              style: boldTextStyle,
                              textAlign: pw.TextAlign.center),
                        ),
                      ],
                    ),
                    // Filas de la tabla
                    ...model.tablaAmortizacion.map((fila) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              fila.mes.toString(),
                              style: baseTextStyle,
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              model.formatoMoneda(fila.cuota),
                              style: baseTextStyle,
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              model.formatoMoneda(fila.interes),
                              style: baseTextStyle,
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              model.formatoMoneda(fila.capital),
                              style: baseTextStyle,
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              model.formatoMoneda(fila.saldo),
                              style: baseTextStyle,
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Espacio para firmas
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1)),
                      ),
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text(
                        'Firma del Cliente',
                        style: baseTextStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Container(
                      width: 150,
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 1)),
                      ),
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text(
                        'Firma del Oficial de Crédito',
                        style: baseTextStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Pie de página
            pw.Center(
              child: pw.Text(
                'Este documento es una proforma y no constituye un compromiso contractual.',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Center(
              child: pw.Text(
                'Términos y condiciones sujetos a aprobación final de crédito.',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                textAlign: pw.TextAlign.center,
              ),
            ),
          ];
        },
      ),
    );

    // Generar PDF
    return pdf.save();
  }

  // Widget para los cuadros de resumen
  pw.Widget _buildResumenBox(String titulo, String valor,
      pw.TextStyle baseStyle, pw.TextStyle boldStyle,
      {bool highlight = false}) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        color: highlight ? PdfColors.grey200 : PdfColors.white,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            titulo,
            style: baseStyle,
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            valor,
            style: boldStyle,
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
}
