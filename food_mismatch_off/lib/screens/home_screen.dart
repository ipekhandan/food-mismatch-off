import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'saved_images_screen.dart';
import 'camera_screen.dart';
import 'result_screen.dart';
import '../services/saved_images_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

if (image == null) return;

// ✅ Uygulama içine kopyala/kaydet
final savedPath = await SavedImagesService.saveToAppFolder(image.path);

if (!context.mounted) return;

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ResultScreen(imagePath: savedPath),
  ),
);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Galeri hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final green = Colors.green.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 100,
                color: green,
              ),
              const SizedBox(height: 32),
              Text(
                'Gıda Ambalaj Analizi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Ürün ambalajını tarayın ve görsel-içerik uyumunu analiz edin',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CameraScreen()),
                  );
                },
                icon: const Icon(Icons.camera_alt, size: 28),
                label: const Text(
                  'Fotoğraf Çek',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () => _pickImageFromGallery(context),
                icon: Icon(Icons.photo_library, size: 28, color: green),
                label: Text(
                  'Galeriden Seç',
                  style: TextStyle(fontSize: 18, color: green),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  side: BorderSide(color: green, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

TextButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedImagesScreen()),
    );
  },
  icon: const Icon(Icons.history),
  label: const Text('Kayıtlarım'),
),
            ],
          ),
        ),
      ),
    );
  }
}