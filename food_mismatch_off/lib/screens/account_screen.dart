import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'profile_info_screen.dart';
import 'favorites_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  User? user;

  static const Color primaryLilac = Color(0xFF8E73D8);
  static const Color darkLilac = Color(0xFF2B2146);
  static const Color softLilac = Color(0xFFF4EDFF);
  static const Color salmon = Color(0xFFE58AB4);

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fullName = user?.displayName ?? 'Kullanıcı';
    final email = user?.email ?? 'E-posta yok';

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FB),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFF9FB),
              Color(0xFFF4EDFF),
              Color(0xFFFFEEF7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Row(
                  children: [
                    _TopCircleButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Hesabım',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkLilac,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 52),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 24, 18, 26),
                  children: [
                    _ProfileCard(
                      fullName: fullName,
                      email: email,
                    ),
                    const SizedBox(height: 20),

                    _AccountItem(
                      icon: Icons.badge_outlined,
                      title: 'Bilgilerim',
                      subtitle: 'Ad, soyad ve e-posta bilgilerin',
                      color: primaryLilac,
                      onTap: () async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileInfoScreen(),
                          ),
                        );

                        if (updated == true) {
                          await FirebaseAuth.instance.currentUser?.reload();

                          if (!mounted) return;

                          setState(() {
                            user = FirebaseAuth.instance.currentUser;
                          });
                        }
                      },
                    ),

                    _AccountItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favoriler',
                      subtitle: 'Kaydettiğin ürünler',
                      color: salmon,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),

                    _AccountItem(
                      icon: Icons.description_outlined,
                      title: 'Kullanım Koşulları',
                      subtitle: 'Uygulama kullanım kuralları',
                      color: const Color(0xFF9B7BE8),
                      onTap: () {},
                    ),

                    _AccountItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Veri Politikası',
                      subtitle: 'Verilerinin nasıl işlendiği',
                      color: const Color(0xFFB58BE8),
                      onTap: () {},
                    ),

                    const SizedBox(height: 14),

                    _LogoutItem(
                      onTap: () => _signOut(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(19),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E73D8).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(
          icon,
          color: const Color(0xFF6F61A8),
          size: 28,
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String fullName;
  final String email;

  const _ProfileCard({
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEDE4FF),
            Color(0xFFD9C8FF),
            Color(0xFFFFEEF7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E73D8).withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E73D8).withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 46,
              color: Color(0xFF8E73D8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF2B2146),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF2B2146).withValues(alpha: 0.58),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'gıdAI kullanıcısı ✨',
                    style: TextStyle(
                      color: Color(0xFF6F61A8),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AccountItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const darkLilac = Color(0xFF2B2146);

    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8E73D8).withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(19),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
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
                          color: darkLilac,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: darkLilac.withValues(alpha: 0.52),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: color,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutItem({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const salmon = Color(0xFFE58AB4);

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: salmon.withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: salmon.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: salmon,
                  size: 28,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Çıkış Yap',
                    style: TextStyle(
                      color: salmon,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: salmon,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}