import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileInfoScreen extends StatefulWidget {
  const ProfileInfoScreen({super.key});

  @override
  State<ProfileInfoScreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isEditing = false;
  bool isLoading = false;
  bool obscurePassword = true;

  String originalEmail = '';

  static const Color primaryLilac = Color(0xFF8E73D8);
  static const Color darkLilac = Color(0xFF2B2146);
  static const Color softLilac = Color(0xFFF4EDFF);
  static const Color salmon = Color(0xFFE9A6A6);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final user = FirebaseAuth.instance.currentUser;

    final fullName = user?.displayName ?? '';
    final parts = fullName.trim().split(' ');

    nameController.text =
        parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : '';

    surnameController.text =
        parts.length > 1 ? parts.sublist(1).join(' ') : '';

    emailController.text = user?.email ?? '';
    originalEmail = user?.email ?? '';
  }

  Future<void> _saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Kullanıcı bulunamadı');
      return;
    }

    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final newEmail = emailController.text.trim();
    final currentPassword = passwordController.text.trim();

    if (name.isEmpty || surname.isEmpty || newEmail.isEmpty) {
      _showMessage('Ad, soyad ve e-posta boş olamaz');
      return;
    }

    if (!newEmail.contains('@') || !newEmail.contains('.')) {
      _showMessage('Geçerli bir e-posta adresi gir');
      return;
    }

    final emailChanged = newEmail != originalEmail;

    if (emailChanged && currentPassword.isEmpty) {
      _showMessage('E-postayı değiştirmek için mevcut şifreni girmelisin');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await user.updateDisplayName('$name $surname');

      if (emailChanged) {
        final credential = EmailAuthProvider.credential(
          email: originalEmail,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updateEmail(newEmail);
      }

      await FirebaseAuth.instance.currentUser?.reload();

      if (!mounted) return;

      setState(() {
        isEditing = false;
        isLoading = false;
        originalEmail = newEmail;
        passwordController.clear();
      });

      _showMessage('Bilgiler güncellendi');

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      String message = 'Bilgiler güncellenemedi';

      if (e.code == 'wrong-password') {
        message = 'Mevcut şifre hatalı';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta adresi';
      } else if (e.code == 'email-already-in-use') {
        message = 'Bu e-posta başka bir hesapta kullanılıyor';
      } else if (e.code == 'requires-recent-login') {
        message = 'Güvenlik için tekrar giriş yapman gerekiyor';
      } else if (e.code == 'network-request-failed') {
        message = 'İnternet bağlantını kontrol et';
      }

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(message);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage('Beklenmeyen hata: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailChanged = emailController.text.trim() != originalEmail;

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
                    _TopButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Bilgilerim',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: darkLilac,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                    _TopButton(
                      icon: isEditing
                          ? Icons.close_rounded
                          : Icons.edit_rounded,
                      onTap: () {
                        setState(() {
                          if (isEditing) {
                            _loadUserInfo();
                            passwordController.clear();
                          }

                          isEditing = !isEditing;
                        });
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
                  children: [
                    _InfoHeaderCard(
                      isEditing: isEditing,
                    ),

                    const SizedBox(height: 22),

                    _ProfileField(
                      controller: nameController,
                      label: 'Ad',
                      icon: Icons.person_outline_rounded,
                      enabled: isEditing,
                    ),

                    const SizedBox(height: 14),

                    _ProfileField(
                      controller: surnameController,
                      label: 'Soyad',
                      icon: Icons.badge_outlined,
                      enabled: isEditing,
                    ),

                    const SizedBox(height: 14),

                    _ProfileField(
                      controller: emailController,
                      label: 'E-posta',
                      icon: Icons.mail_outline_rounded,
                      enabled: isEditing,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                    ),

                    if (isEditing && emailChanged) ...[
                      const SizedBox(height: 14),
                      _PasswordField(
                        controller: passwordController,
                        obscurePassword: obscurePassword,
                        onToggle: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'E-posta değişikliği için mevcut şifren gerekir.',
                        style: TextStyle(
                          color: darkLilac.withValues(alpha: 0.56),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],

                    const SizedBox(height: 26),

                    if (isEditing)
                      GestureDetector(
                        onTap: isLoading ? null : _saveChanges,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFD7B6FF),
                                primaryLilac,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryLilac.withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text(
                                    'Kaydet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: primaryLilac.withValues(alpha: 0.10),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: primaryLilac,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bilgilerini değiştirmek için sağ üstteki edit butonuna basınız.',
                                style: TextStyle(
                                  color: darkLilac.withValues(alpha: 0.62),
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _TopButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _TopButton({
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

class _InfoHeaderCard extends StatelessWidget {
  final bool isEditing;

  const _InfoHeaderCard({
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
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
            color: const Color(0xFF8E73D8).withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF8E73D8),
              size: 38,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEditing
                  ? 'Bilgilerini düzenliyorsun'
                  : 'Kayıtlı profil bilgilerin',
              style: const TextStyle(
                color: Color(0xFF2B2146),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _ProfileField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.enabled,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const darkLilac = Color(0xFF2B2146);
    const primaryLilac = Color(0xFF8E73D8);
   const salmon = Color(0xFFE9A6A6);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: enabled ? 0.9 : 0.62),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: enabled
              ? primaryLilac.withValues(alpha: 0.32)
              : Colors.white.withValues(alpha: 0.75),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryLilac.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: const TextStyle(
          color: darkLilac,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 22,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? primaryLilac : salmon,
            size: 28,
          ),
          labelText: label,
          labelStyle: TextStyle(
            color: darkLilac.withValues(alpha: 0.52),
            fontWeight: FontWeight.w700,
          ),
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool obscurePassword;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.obscurePassword,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    const darkLilac = Color(0xFF2B2146);
    const primaryLilac = Color(0xFF8E73D8);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: primaryLilac.withValues(alpha: 0.32),
          width: 1.4,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscurePassword,
        style: const TextStyle(
          color: darkLilac,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 22,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: primaryLilac,
            size: 28,
          ),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: primaryLilac,
            ),
          ),
          labelText: 'Mevcut şifre',
          labelStyle: TextStyle(
            color: darkLilac.withValues(alpha: 0.52),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}