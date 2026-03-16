import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ControlDetailScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final String deviceType; // 'barn' (Chuồng trại) hoặc 'greenhouse' (Nhà kính)

  const ControlDetailScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
  });

  @override
  State<ControlDetailScreen> createState() => _ControlDetailScreenState();
}

class _ControlDetailScreenState extends State<ControlDetailScreen> {
  // Danh sách thiết bị con
  late List<Map<String, dynamic>> _controls;

  @override
  void initState() {
    super.initState();
    // Tự động cấu hình nút bấm dựa trên loại thiết bị
    if (widget.deviceType == 'barn') {
      _controls = [
        {'id': 'fan', 'name': 'Quạt Thông Gió', 'icon': Icons.air},
        {'id': 'heater', 'name': 'Đèn Sưởi Ấm', 'icon': Icons.wb_sunny},
        {'id': 'feeder', 'name': 'Máy Cho Ăn', 'icon': Icons.restaurant},
        {'id': 'water', 'name': 'Bơm Nước Uống', 'icon': Icons.water_drop},
      ];
    } else {
      // Mặc định là greenhouse
      _controls = [
        {'id': 'pump', 'name': 'Máy Bơm Tưới', 'icon': Icons.water},
        {'id': 'light', 'name': 'Đèn Quang Hợp', 'icon': Icons.lightbulb},
        {'id': 'roof', 'name': 'Rèm Che Nắng', 'icon': Icons.roofing},
        {'id': 'mist', 'name': 'Phun Sương', 'icon': Icons.cloud},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBarn = widget.deviceType == 'barn';
    final themeColor = isBarn ? Colors.orange : const Color(0xFF00B894);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.deviceName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            Text("ID: ${widget.deviceId}", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Phần hiển thị Cảm biến
            _buildSensorCard(themeColor),
            const SizedBox(height: 25),
            
            // 2. Tiêu đề danh sách
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Bảng Điều Khiển", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            ),
            const SizedBox(height: 15),

            // 3. Lưới các nút bấm
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 cột
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1, // Tỷ lệ khung hình vuông vắn hơn
                ),
                itemCount: _controls.length,
                itemBuilder: (context, index) {
                  return _buildControlSwitch(_controls[index], themeColor);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị cảm biến (Nhiệt độ/Độ ẩm)
  Widget _buildSensorCard(Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSensorItem(Icons.thermostat, "28°C", "Nhiệt Độ"),
          Container(width: 1, height: 40, color: Colors.white30),
          _buildSensorItem(Icons.water_drop, "65%", "Độ Ẩm"),
        ],
      ),
    );
  }

  Widget _buildSensorItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 30),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  // Widget công tắc (Switch) kết nối Firebase Realtime
  Widget _buildControlSwitch(Map<String, dynamic> item, Color activeColor) {
    // Đường dẫn Firebase: devices/{deviceID}/relay/{componentID}
    // Ví dụ: devices/PLCK01/relay/pump
    final dbRef = FirebaseDatabase.instance.ref("devices/${widget.deviceId}/relay/${item['id']}");

    return StreamBuilder(
      stream: dbRef.onValue,
      builder: (context, snapshot) {
        // Mặc định là TẮT (false) nếu chưa có dữ liệu hoặc lỗi
        bool isOn = false;
        if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
          // Ép kiểu an toàn
          try {
            isOn = snapshot.data!.snapshot.value == true;
          } catch (e) {
            isOn = false;
          }
        }

        return GestureDetector(
          onTap: () {
            // Gửi lệnh Bật/Tắt (đảo ngược trạng thái hiện tại) lên Firebase
            dbRef.set(!isOn);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: isOn ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOn ? activeColor : Colors.transparent,
                width: 2
              ),
              boxShadow: isOn 
                ? [BoxShadow(color: activeColor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))]
                : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOn ? activeColor : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                Text(item['name'], style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isOn ? Colors.black87 : Colors.grey[500]
                )),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOn ? activeColor.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(isOn ? "ĐANG BẬT" : "ĐANG TẮT", style: TextStyle(
                    fontSize: 11,
                    color: isOn ? activeColor : Colors.grey,
                    fontWeight: FontWeight.bold
                  )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}