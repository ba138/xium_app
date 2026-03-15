import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:xium_app/constants/app_colors.dart';

class FullScreenPdfView extends StatelessWidget {
  final String pdfUrl;

  const FullScreenPdfView({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
