import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = true; // Chuyển đổi trạng thái Login/Register
  bool _isLoading = false;
  
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(); // Chỉ dùng khi đăng ký

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // --- ĐĂNG NHẬP ---
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
      } else {
        // --- ĐĂNG KÝ ---
        UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text.trim(),
        );
        
        // Lưu tên người dùng vào Database
        await FirebaseDatabase.instance.ref("users/${userCred.user!.uid}/profile").set({
          "name": _nameCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "joined_date": DateTime.now().toString(),
        });
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Có lỗi xảy ra"), backgroundColor: Colors.red)
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.eco, size: 60, color: Color(0xFF00B894)),
              ),
              const SizedBox(height: 30),
              Text(
                _isLogin ? "CHÀO MỪNG TRỞ LẠI" : "TẠO TÀI KHOẢN MỚI",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _isLogin ? "Đăng nhập để quản lý nông trại của bạn" : "Bắt đầu hành trình nông nghiệp thông minh",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Form nhập liệu
              if (!_isLogin) ...[
                TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: "Họ và Tên", prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
              ],
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 16),
              TextField(controller: _passCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu", prefixIcon: Icon(Icons.lock_outline))),
              
              const SizedBox(height: 30),
              
              // Nút bấm chính
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : Text(_isLogin ? "ĐĂNG NHẬP" : "ĐĂNG KÝ", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 20),
              // Nút chuyển đổi
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: RichText(
                  text: TextSpan(
                    text: _isLogin ? "Chưa có tài khoản? " : "Đã có tài khoản? ",
                    style: const TextStyle(color: Colors.grey),
                    children: [
                      TextSpan(
                        text: _isLogin ? "Đăng ký ngay" : "Đăng nhập ngay",
                        style: const TextStyle(color: Color(0xFF00B894), fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}