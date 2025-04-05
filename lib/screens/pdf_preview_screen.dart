import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String fileName;

  const PdfPreviewScreen({
    super.key,
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista Previa del PDF'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final tempDir = await getTemporaryDirectory();
              final file = File('${tempDir.path}/$fileName');
              await file.writeAsBytes(pdfBytes);
              await Share.shareXFiles(
                [XFile(file.path)],
                text: 'Proforma de Préstamo',
              );
            },
            tooltip: 'Compartir PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
            },
            tooltip: 'Descargar PDF',
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) => pdfBytes,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
        pdfFileName: fileName,
      ),
    );
  }
}