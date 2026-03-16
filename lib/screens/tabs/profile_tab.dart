import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic> _userData = {
    "name": "Người dùng",
    "email": "Đang tải...",
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- HÀM 1: LẤY DỮ LIỆU TỪ FIREBASE ---
  Future<void> _fetchUserData() async {
    if (user == null) return;
    try {
      final snapshot = await FirebaseDatabase.instance.ref("users/${user!.uid}/profile").get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          _userData = {
            "name": data['full_name'] ?? data['name'] ?? "Người dùng",
            "email": data['email'] ?? user!.email,
          };
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // --- HÀM 2: CHỈNH SỬA TÊN NGƯỜI DÙNG ---
  void _editProfile() {
    final nameCtrl = TextEditingController(text: _userData['name']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đổi Tên Hiển Thị"),
        content: TextField(
          controller: nameCtrl, 
          decoration: const InputDecoration(labelText: "Nhập tên mới", border: OutlineInputBorder())
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (user != null && nameCtrl.text.isNotEmpty) {
                // Cập nhật lên Firebase
                await FirebaseDatabase.instance.ref("users/${user!.uid}/profile").update({
                  "full_name": nameCtrl.text.trim()
                });
                Navigator.pop(ctx);
                _fetchUserData(); // Load lại giao diện
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đã cập nhật tên!")));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white),
            child: const Text("Lưu"),
          )
        ],
      ),
    );
  }

  // --- HÀM 3: XỬ LÝ MENU CHỨC NĂNG (POPUP) ---
  void _handleMenuAction(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 250,
        child: Column(
          children: [
            Container(width: 40, height: 4, color: Colors.grey[300], margin: const EdgeInsets.only(bottom: 20)),
            Icon(Icons.construction, size: 50, color: Colors.orange[300]),
            const SizedBox(height: 15),
            Text("Tính năng: $title", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
              "Chức năng này đang được phát triển và sẽ sớm ra mắt trong phiên bản tiếp theo.", 
              textAlign: TextAlign.center, 
              style: TextStyle(color: Colors.grey)
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black),
                child: const Text("Đã Hiểu"),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF00B894);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Hồ Sơ Của Tôi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryColor))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // --- CARD 1: THÔNG TIN USER ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      // Avatar chữ cái đầu
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        child: Text(
                          _userData['name'][0].toUpperCase(),
                          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userData['name'],
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _userData['email'],
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                              child: const Text("👑 Thành viên Pro", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: _editProfile, // Gọi hàm sửa tên
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- CARD 2: MENU CHỨC NĂNG ---
                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text("Quản lý chung", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(Icons.analytics_outlined, "Thống kê hoạt động", "Xem lịch sử tưới tiêu", () => _handleMenuAction("Thống kê")),
                      _buildMenuItem(Icons.share_location, "Chia sẻ quyền", "Thêm người quản lý phụ", () => _handleMenuAction("Chia sẻ quyền")),
                      _buildMenuItem(Icons.payment, "Gói dịch vụ", "Gia hạn gói Pro", () => _handleMenuAction("Gói dịch vụ")),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Align(
                  alignment: Alignment.centerLeft, 
                  child: Text("Cài đặt & Hỗ trợ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey))
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                  ),
                  child: Column(
                    children: [
                      _buildMenuItem(Icons.notifications_active_outlined, "Thông báo", "Cảnh báo nhiệt độ, độ ẩm", () => _handleMenuAction("Cài đặt thông báo")),
                      _buildMenuItem(Icons.support_agent, "Liên hệ hỗ trợ", "Chat với kỹ thuật viên", () => _handleMenuAction("Hỗ trợ kỹ thuật")),
                      _buildMenuItem(Icons.info_outline, "Phiên bản ứng dụng", "v1.0.2 (Beta)", () {}),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- NÚT ĐĂNG XUẤT ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Xác nhận"),
                          content: const Text("Bạn có chắc muốn đăng xuất khỏi tài khoản này?"),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                FirebaseAuth.instance.signOut();
                              },
                              child: const Text("Đăng Xuất", style: TextStyle(color: Colors.red)),
                            )
                          ],
                        )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text("Đăng Xuất", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
    );
  }

  // Widget vẽ từng dòng menu
  Widget _buildMenuItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFF00B894).withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: const Color(0xFF00B894), size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
    );
  }
}