import 'package:flutter/material.dart';

import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../services/saved_images_service.dart';
import 'result_screen.dart';
import 'visual_analysis_upload_screen.dart';

class BarcodeSearchScreen extends StatefulWidget {
  const BarcodeSearchScreen({super.key});

  @override
  State<BarcodeSearchScreen> createState() => _BarcodeSearchScreenState();
}

class _BarcodeSearchScreenState extends State<BarcodeSearchScreen> {
  final TextEditingController barcodeController = TextEditingController();

  bool isLoading = false;
  bool isAnalyzing = false;
  Map<String, dynamic>? product;

  @override
  void dispose() {
    barcodeController.dispose();
    super.dispose();
  }

  Future<void> searchBarcode() async {
    final barcode = barcodeController.text.trim();

    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen barkod numarası girin')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      product = null;
    });

    try {
      final result = await ApiService.getProductByBarcode(barcode);

      if (!mounted) return;

      setState(() {
        product = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barkod aranırken hata oluştu: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> analyzeBarcode() async {
    final barcode = barcodeController.text.trim();

    if (barcode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen barkod numarası girin')),
      );
      return;
    }

    setState(() {
      isAnalyzing = true;
    });

    try {
      final AnalysisResult result = await ApiService.analyzeBarcode(barcode);

      try {
        await SavedImagesService.saveBarcodeAnalysis(
          barcode: barcode,
          analysisResult: result,
        );
      } catch (saveError) {
        debugPrint('Barkod analizi kaydedilemedi: $saveError');
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            analysisResult: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Barkod analizi başarısız: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = const Color(0xFF7CB68A);
    final darkGreen = const Color(0xFF4D7C57);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBFC),
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          'Barkodla Ara',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ürün barkodunu gir',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Barkod numarasını yazınca ürün bilgisi OpenFoodFacts üzerinden sorgulanır.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: green.withValues(alpha: 0.55),
                ),
              ),
              child: TextField(
                controller: barcodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Barkod numarası',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 18,
                  ),
                  suffixIcon: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: darkGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading || isAnalyzing ? null : searchBarcode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Ara',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 22),
            if (product != null)
              _ProductResultCard(
                product: product!,
                isAnalyzing: isAnalyzing,
                onAnalyzeTap: analyzeBarcode,
              ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EA),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Ürün bulunamazsa fotoğrafla analiz ekranına geçip ambalaj ve içindekiler görsellerini yükleyebilirsin.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.35,
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(
                    Icons.qr_code_2_rounded,
                    size: 56,
                    color: darkGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductResultCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isAnalyzing;
  final VoidCallback onAnalyzeTap;

  const _ProductResultCard({
    required this.product,
    required this.isAnalyzing,
    required this.onAnalyzeTap,
  });

  @override
  Widget build(BuildContext context) {
    final found = product['found'] == true;
    final productName = (product['product_name'] ?? 'Ürün bulunamadı').toString();
    final brand = (product['brand'] ?? '').toString();
    final needsPhoto = product['needs_photo_analysis'] == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            found ? productName : 'Ürün bulunamadı',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (brand.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Marka: $brand',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            found
                ? needsPhoto
                    ? 'Ürün bilgisi bulundu ancak veri eksik olabilir. İstersen fotoğrafla daha detaylı analiz yapabilirsin.'
                    : 'Ürün bilgisi bulundu. Barkod verisiyle doğrudan analiz yapabilirsin.'
                : 'Bu barkod veri tabanında bulunamadı. Fotoğraf analizi ile devam edebilirsin.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (found)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAnalyzing ? null : onAnalyzeTap,
                icon: isAnalyzing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.analytics_rounded),
                label: Text(
                  isAnalyzing ? 'Analiz ediliyor...' : 'Analizi Gör',
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VisualAnalysisUploadScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Fotoğrafla Analize Devam Et'),
              ),
            ),
        ],
      ),
    );
  }
}
