import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_side_menu.dart';
import 'favorites_screen.dart';
import 'account_screen.dart';
import 'additive_guide_screen.dart';
import 'visual_analysis_upload_screen.dart';
import 'saved_images_screen.dart';
import 'barcode_search_screen.dart';
import 'result_screen.dart';
import 'analysis_guide_screen.dart';
import 'about_screen.dart';
import '../services/saved_images_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _recentFuture;

  @override
  void initState() {
    super.initState();
    _recentFuture = SavedImagesService.getSavedItems();
  }

  void _refreshRecent() {
    setState(() {
      _recentFuture = SavedImagesService.getSavedItems();
    });
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final savedPath = await SavedImagesService.saveToAppFolder(image.path);

      if (!context.mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(imagePath: savedPath),
        ),
      );

      _refreshRecent();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Galeri hatası: $e')),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

 void _showProductSearchOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF7FA),
              Color(0xFFF2ECFF),
              Color(0xFFEAF6EA),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nasıl analiz etmek istersin?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B223B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Barkod girerek veya ürün fotoğrafı yükleyerek analiz başlat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF666C7A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            _BottomOptionCard(
              icon: Icons.qr_code_scanner_rounded,
              title: 'Barkodla Ara',
              subtitle: 'Ürünün barkod numarasını gir',
              color: Colors.white.withValues(alpha: 0.75),
              iconColor: const Color(0xFF8B73D8),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BarcodeSearchScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _BottomOptionCard(
              icon: Icons.camera_alt_rounded,
              title: 'Görseli Tara',
              subtitle: 'Ön yüz ve içindekiler kısmını yükle',
              color: Colors.white.withValues(alpha: 0.75),
              iconColor: const Color(0xFFE58AB4),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VisualAnalysisUploadScreen(),
                  ),
                );
                _refreshRecent();
              },
            ),
          ],
        ),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
   final primaryLilac = const Color(0xFF8E73D8);
final darkLilac = const Color(0xFF6F61A8);
final softBg = const Color(0xFFFFFBFC);
    return Scaffold(
      backgroundColor: softBg,

drawer: CustomSideMenu(
  userName: user?.displayName?.split(' ').first ?? 'Kullanıcı',
  onHome: () => Navigator.pop(context),
  onSearch: () {
    Navigator.pop(context);
    _showProductSearchOptions(context);
  },
  onSaved: () async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SavedImagesScreen()),
    );
    _refreshRecent();
  },
  onFavorites: () async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
    _refreshRecent();
  },
  onAdditives: () {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdditiveGuideScreen()),
    );
  },
  onAccount: () async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AccountScreen()),
    );
    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;
    setState(() {});
  },
  onLogout: () => _signOut(context),
),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (context) {
                          return _TopIconButton(
                            icon: Icons.menu_rounded,
                            color: darkLilac,
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                          );
                        },
                      ),
                      
                      Row(
                        children: [
                          _TopIconButton(
                            icon: Icons.notifications_none_rounded,
                            color: darkLilac,
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _TopIconButton(
                            icon: Icons.logout_rounded,
                            color: Colors.black87,
                            onTap: () => _signOut(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Merhaba, ${user?.displayName?.split(' ').first ?? "Kullanıcı"}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bugün ne analiz etmek istersin?',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 22),
                 
FutureBuilder<List<Map<String, dynamic>>>(
  future: _recentFuture,
  builder: (context, snapshot) {
    final count = snapshot.data?.length ?? 0;

    return _PastelHeroCard(
      analysisCount: count,
      onTap: () => _showProductSearchOptions(context),
    );
  },
),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Son Analizler',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SavedImagesScreen(),
                            ),
                          );
                          _refreshRecent();
                        },
                        child: Text(
                          'Tümünü Gör',
                          style: TextStyle(
                            color: darkLilac,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _recentFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final items = snapshot.data ?? [];

                      if (items.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Text(
                            'Henüz analiz yok. Ürün Ara butonuyla ilk analizini başlatabilirsin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }

                      final recentItems = items.take(2).toList();

                      return Column(
                        children: recentItems.map((item) {
                          final imagePath =
                              item['frontImagePath'] ?? item['path'];
                          final risk = item['healthRisk'] ?? 'Bilinmiyor';
                          final score = item['misleadingScore'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _RecentAnalysisCard(
                              title:
                                  item['productName'] ?? 'Analiz Edilen Ürün',
                              date:
                                  'Analiz tarihi: ${_formatDate(item['createdAt'])}',
                              score: score != null
                                  ? 'Yanıltıcılık skoru: $score'
                                  : 'Skor hazırlanıyor',
                              chipText: risk.toString().toUpperCase(),
                              chipColor: _riskBgColor(risk.toString()),
                              imagePath: imagePath,
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ResultScreen(imagePath: imagePath),
                                  ),
                                );
                                _refreshRecent();
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            _BottomHomeBar(
              onHomeTap: () => _refreshRecent(),
              onCenterTap: () => _showProductSearchOptions(context),
              onSavedTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SavedImagesScreen()),
                );
                _refreshRecent();
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null) return 'Bilinmiyor';
    final date = DateTime.tryParse(iso);
    if (date == null) return 'Bilinmiyor';
    return '${date.day}.${date.month}.${date.year}';
  }

  Color _riskBgColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'düşük':
        return const Color(0xFFDDF0DD);
      case 'orta':
        return const Color(0xFFF3D8B2);
      case 'yüksek':
        return const Color(0xFFF5C4C4);
      default:
        return const Color(0xFFECECEC);
    }
  }
}

class _TopIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TopIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: color),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentAnalysisCard extends StatelessWidget {
  final String title;
  final String date;
  final String score;
  final String chipText;
  final Color chipColor;
  final String? imagePath;
  final VoidCallback onTap;

  const _RecentAnalysisCard({
    required this.title,
    required this.date,
    required this.score,
    required this.chipText,
    required this.chipColor,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final file = imagePath != null ? File(imagePath!) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: file != null && file.existsSync()
                  ? Image.file(
                      file,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: const Color(0xFFFCE7EE),
                      child: const Icon(
                        Icons.local_drink_rounded,
                        size: 36,
                        color: Color(0xFFE8578A),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          score,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: chipColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          chipText,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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

class _BottomHomeBar extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onCenterTap;
  final VoidCallback onSavedTap;

  const _BottomHomeBar({
    required this.onHomeTap,
    required this.onCenterTap,
    required this.onSavedTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryLilac = Color(0xFF8E73D8);
    const softLilac = Color(0xFFD8C8FF);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onHomeTap,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_rounded,
                    color: primaryLilac,
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ana Sayfa',
                    style: TextStyle(
                      color: primaryLilac,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onCenterTap,
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    softLilac,
                    primaryLilac,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryLilac.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: onSavedTap,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    color: Colors.grey,
                    size: 28,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Kayıtlarım',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _BottomOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _BottomOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B223B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? const Color(0xFF4D7C57),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}
class _PastelHeroCard extends StatelessWidget {
  final VoidCallback onTap;
  final int analysisCount;

  const _PastelHeroCard({
    required this.onTap,
    required this.analysisCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFEAF6EA),
            Color(0xFFF2ECFF),
            Color(0xFFFFEEF4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB7A9E6),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
  right: -28,
  bottom: -12,
  child: Opacity(
    opacity: 0.75,
    child: Image.asset(
      'assets/images/product2.png',
      width: 175,
      fit: BoxFit.contain,
    ),
  ),
),

          Positioned(
            top: 20,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'GıdAI ✨',
                style: TextStyle(
                  color: Color(0xFF6F61A8),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
  '$analysisCount\nanaliz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6F61A8),
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
            ),
          ),

          const Positioned(
            left: 22,
            top: 76,
            child: Text(
              'Ürünün gerçek\nhikayesini keşfet',
              style: TextStyle(
                color: Color(0xFF1B223B),
                fontSize: 28,
                height: 1.12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const Positioned(
            left: 22,
            top: 156,
            child: Text(
              'İçeriğini analiz et, sağlık risklerini öğren.',
              style: TextStyle(
                color: Color(0xFF555A6F),
                fontSize: 15,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Positioned(
            left: 22,
            bottom: 22,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                width: 230,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.document_scanner_rounded,
                      color: Color(0xFF8E79D6),
                      size: 30,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ürün Ara',
                            style: TextStyle(
                              color: Color(0xFF1B223B),
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Barkod veya fotoğraf ile tara',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF8E79D6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}