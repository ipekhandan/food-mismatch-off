import 'register_screen.dart';
import 'home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen e-posta ve şifre girin"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Giriş başarılı"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Giriş başarısız";

      if (e.code == 'user-not-found') {
        message = "Bu e-posta ile kayıtlı kullanıcı bulunamadı";
      } else if (e.code == 'wrong-password') {
        message = "Şifre hatalı";
      } else if (e.code == 'invalid-email') {
        message = "Geçersiz e-posta adresi";
      } else if (e.code == 'invalid-credential') {
        message = "E-posta veya şifre yanlış";
      } else if (e.code == 'too-many-requests') {
        message = "Çok fazla deneme yapıldı, lütfen sonra tekrar deneyin";
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

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen önce e-posta adresinizi girin"),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Şifre sıfırlama linki gönderildi (Spam klasörünü kontrol edin)",
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Şifre sıfırlama başarısız";

      if (e.code == 'invalid-email') {
        message = "Geçersiz e-posta adresi";
      } else if (e.code == 'user-not-found') {
        message = "Bu e-posta ile kayıtlı kullanıcı bulunamadı";
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
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9DDE3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTopArea(),
              Transform.translate(
                offset: const Offset(0, -25),
                child: _buildLoginCard(context),
              ),
              _buildBottomIllustration(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 36),
      decoration: const BoxDecoration(
        color: Color(0xFFF6D3DA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "",
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFB85C74),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Color(0xFFB85C74),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4F6),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withValues(alpha: 0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              size: 56,
              color: Color(0xFF57A85A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "GıdAI",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF5A3D44),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Ambalajını tara, içeriğini incele,\nkendine uygun ürünleri keşfet.",
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 16,
              height: 1.4,
              color: const Color(0xFF8C6B73),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: resetPassword,
              child: Text(
                "Şifremi unuttum",
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB85C74),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isLoading ? null : login,
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
                      "Giriş Yap",
                      style: GoogleFonts.nunito(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE4CAD0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "veya",
                  style: GoogleFonts.nunito(
                    color: const Color(0xFF9A7A82),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFE4CAD0))),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _socialButton(
                  label: "Google",
                  icon: Icons.g_mobiledata_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _socialButton(
                  label: "Apple",
                  icon: Icons.apple_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: const Color(0xFF7A6368),
                  fontWeight: FontWeight.w700,
                ),
                children: const [
                  TextSpan(text: "Hesabın yok mu? "),
                  TextSpan(
                    text: "Kayıt ol",
                    style: TextStyle(
                      color: Color(0xFFE8578A),
                      fontWeight: FontWeight.w900,
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

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
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
        obscureText: isPassword ? obscurePassword : false,
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
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
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

  Widget _socialButton({
    required String label,
    required IconData icon,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE6D6DA)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFB85C74)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: const Color(0xFF6A545A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomIllustration() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _foodBubble("🍩"),
          const SizedBox(width: 10),
          _foodBubble("🥛"),
          const SizedBox(width: 10),
          _foodBubble("🍓"),
          const SizedBox(width: 10),
          _foodBubble("🍪"),
          const SizedBox(width: 10),
          _foodBubble("🧃"),
        ],
      ),
    );
  }

  Widget _foodBubble(String emoji) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F6),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}