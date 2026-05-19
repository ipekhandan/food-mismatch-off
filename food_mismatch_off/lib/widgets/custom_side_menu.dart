import 'package:flutter/material.dart';

class CustomSideMenu extends StatelessWidget {
  final String userName;
  final VoidCallback onHome;
  final VoidCallback onSearch;
  final VoidCallback onSaved;
  final VoidCallback onFavorites;
  final VoidCallback onAdditives;
  final VoidCallback onAccount;
  final VoidCallback onLogout;

  const CustomSideMenu({
    super.key,
    required this.userName,
    required this.onHome,
    required this.onSearch,
    required this.onSaved,
    required this.onFavorites,
    required this.onAdditives,
    required this.onAccount,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 18, 0, 18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF9FB),
              Color(0xFFF4EDFF),
              Color(0xFFFFEEF7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF8E73D8).withValues(alpha: 0.14),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 28),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8E73D8).withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD7B6FF),
                          Color(0xFF8E73D8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8E73D8)
                              .withValues(alpha: 0.22),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.document_scanner_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 13),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'gıdAI',
                          style: TextStyle(
                            fontSize: 28,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2B2146),
                            letterSpacing: -0.8,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Ambalaj analiz asistanın',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF8A7A9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.58),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  'Merhaba, $userName',
                  style: const TextStyle(
                    color: Color(0xFF6F61A8),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            _MenuItem(
              icon: Icons.home_rounded,
              title: 'Ana Sayfa',
              selected: true,
              onTap: onHome,
            ),
            _MenuItem(
              icon: Icons.document_scanner_rounded,
              title: 'Ürün Ara',
              onTap: onSearch,
            ),
            _MenuItem(
              icon: Icons.folder_open_rounded,
              title: 'Kayıtlarım',
              onTap: onSaved,
            ),
            _MenuItem(
              icon: Icons.favorite_border_rounded,
              title: 'Favoriler',
              onTap: onFavorites,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: Color(0xFFE0D6F5),
                thickness: 1,
              ),
            ),

            _MenuItem(
              icon: Icons.menu_book_rounded,
              title: 'Katkı Rehberi',
              onTap: onAdditives,
            ),
            _MenuItem(
              icon: Icons.person_rounded,
              title: 'Hesabım',
              onTap: onAccount,
            ),

            const Spacer(),

            _LogoutButton(onTap: onLogout),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryLilac = Color(0xFF8E73D8);
    const darkText = Color(0xFF2B2146);

    final iconColor = selected ? primaryLilac : const Color(0xFF7F748D);
    final textColor = selected ? primaryLilac : darkText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? Colors.white.withValues(alpha: 0.76)
            : Colors.white.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(23),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(23),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(23),
              border: Border.all(
                color: selected
                    ? primaryLilac.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFF1EAFF)
                        : Colors.white.withValues(alpha: 0.62),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: primaryLilac,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFEEF3),
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: const Color(0xFFE58AB4).withValues(alpha: 0.18),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Color(0xFFE58AB4),
              ),
              SizedBox(width: 12),
              Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: Color(0xFFE58AB4),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}