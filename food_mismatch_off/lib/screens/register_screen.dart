import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  Future<void> register() async {
    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifreler eşleşmiyor")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre en az 6 karakter olmalı")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName('$name $surname');
      await credential.user?.reload();
      await FirebaseAuth.instance.currentUser?.reload();

      final updatedUser = FirebaseAuth.instance.currentUser;
      print("DISPLAY NAME: ${updatedUser?.displayName}");
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarılı")),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Kayıt başarısız";

      if (e.code == 'email-already-in-use') {
        message = "Bu e-posta zaten kullanılıyor";
      } else if (e.code == 'invalid-email') {
        message = "Geçersiz e-posta adresi";
      } else if (e.code == 'weak-password') {
        message = "Şifre çok zayıf";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Beklenmeyen hata: $e")),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9DDE3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9DDE3),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Kayıt Ol",
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF5A3D44),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBFC),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 70,
                    color: Colors.pink[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Yeni Hesap Oluştur",
                    style: GoogleFonts.nunito(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF5A3D44),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Gıda ambalaj analizine başlamak için kayıt ol.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      color: const Color(0xFF8C6B73),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInput(
                    controller: nameController,
                    hint: "Ad",
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),

                  _buildInput(
                    controller: surnameController,
                    hint: "Soyad",
                    icon: Icons.badge_outlined,
                  ),
                  const SizedBox(height: 16),

                  _buildInput(
                    controller: emailController,
                    hint: "E-posta",
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  _buildInput(
                    controller: passwordController,
                    hint: "Şifre",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),

                  _buildInput(
                    controller: confirmPasswordController,
                    hint: "Şifre Tekrar",
                    icon: Icons.lock_outline_rounded,
                    isConfirmPassword: true,
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFE8578A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Kayıt Ol",
                              style: GoogleFonts.nunito(
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8D3D8)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword
            ? obscurePassword
            : isConfirmPassword
                ? obscureConfirmPassword
                : false,
        style: GoogleFonts.nunito(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF5A3D44),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          prefixIcon: Icon(icon, color: const Color(0xFFB85C74)),
          hintText: hint,
          hintStyle: GoogleFonts.nunito(
            color: const Color(0xFFB4969D),
            fontWeight: FontWeight.w700,
          ),
          suffixIcon: (isPassword || isConfirmPassword)
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      if (isPassword) {
                        obscurePassword = !obscurePassword;
                      } else {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      }
                    });
                  },
                  icon: Icon(
                    (isPassword && obscurePassword) ||
                            (isConfirmPassword && obscureConfirmPassword)
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFFB85C74),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}