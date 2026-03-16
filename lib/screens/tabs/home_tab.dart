import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// Import màn hình điều khiển chi tiết
import '../control_detail_screen.dart'; 

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  // --- HÀM XỬ LÝ THÊM THIẾT BỊ ---
  void _showAddDeviceDialog(BuildContext context) {
    final idCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final uid = FirebaseAuth.instance.currentUser!.uid;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Thêm Thiết Bị Mới"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Nhập ID và Mật khẩu được in trên tem thiết bị."),
            const SizedBox(height: 15),
            TextField(
              controller: idCtrl, 
              decoration: const InputDecoration(
                labelText: "ID Thiết Bị (VD: PLCK01)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.qr_code),
              )
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passCtrl, 
              decoration: const InputDecoration(
                labelText: "Mật khẩu kích hoạt",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              )
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              if (idCtrl.text.isEmpty || passCtrl.text.isEmpty) return;

              // 1. Kiểm tra thiết bị trong Kho (Inventory)
              final snapshot = await FirebaseDatabase.instance
                  .ref('device_inventory/${idCtrl.text.trim()}')
                  .get();
              
              if (snapshot.exists) {
                final realPass = snapshot.child('password').value.toString();
                // 2. So khớp mật khẩu
                if (realPass == passCtrl.text.trim()) {
                  // 3. Đúng pass -> Gán vào tài khoản User
                  await FirebaseDatabase.instance.ref('users/$uid/devices/${idCtrl.text.trim()}').set({
                    "name": snapshot.child('name').value,
                    "type": snapshot.child('type').value, // 'barn' hoặc 'greenhouse'
                    "added_at": DateTime.now().toString(),
                  });
                  
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Kích hoạt thành công!"), backgroundColor: Colors.green)
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Sai mật khẩu thiết bị!"), backgroundColor: Colors.red)
                    );
                  }
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("ID thiết bị không tồn tại!"), backgroundColor: Colors.red)
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white),
            child: const Text("Kích Hoạt"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Quản Lý Nông Trại", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF00B894), size: 32),
            tooltip: "Thêm thiết bị",
            onPressed: () => _showAddDeviceDialog(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseDatabase.instance.ref('users/$uid/devices').onValue,
        builder: (context, snapshot) {
          // --- TRƯỜNG HỢP 1: CHƯA CÓ DỮ LIỆU HOẶC RỖNG ---
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_to_photos_outlined, size: 100, color: Colors.grey[300]),
                  const SizedBox(height: 20),
                  Text("Bạn chưa có nông trại nào", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => _showAddDeviceDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Thêm thiết bị ngay"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B894),
                      foregroundColor: Colors.white,
                    ),
                  )
                ],
              ),
            );
          }

          // --- TRƯỜNG HỢP 2: CÓ DỮ LIỆU -> HIỂN THỊ DANH SÁCH ---
          Map<dynamic, dynamic> devices = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<Map<String, dynamic>> deviceList = [];
          
          devices.forEach((key, value) {
            deviceList.add({
              "id": key,
              "name": value['name'],
              "type": value['type']
            });
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: deviceList.length,
            itemBuilder: (context, index) {
              final device = deviceList[index];
              final isBarn = device['type'] == 'barn'; // Kiểm tra loại để đổi màu
              
              return GestureDetector(
                onTap: () {
                  // --- CHUYỂN HƯỚNG SANG CONTROL SCREEN ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ControlDetailScreen(
                        deviceId: device['id'],
                        deviceName: device['name'],
                        deviceType: device['type'],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isBarn ? Colors.orange[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        isBarn ? Icons.pets : Icons.grass, // Icon khác nhau tùy loại
                        color: isBarn ? Colors.orange : Colors.green,
                        size: 32,
                      ),
                    ),
                    title: Text(
                      device['name'], 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text("Đang trực tuyến • ID: ${device['id']}", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}