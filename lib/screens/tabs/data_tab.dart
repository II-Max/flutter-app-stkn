import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataTab extends StatefulWidget {
  const DataTab({super.key});

  @override
  State<DataTab> createState() => _DataTabState();
}

class _DataTabState extends State<DataTab> {
  // Biến quản lý trạng thái khu vực được chọn
  String selectedLocation = 'Hà Nội';

  // Dữ liệu mô phỏng sát thực tế cho Nhiệt độ (Temp) và Độ ẩm (Humidity)
  final Map<String, List<FlSpot>> tempData = {
    'Hà Nội': const [
      FlSpot(1, 22), FlSpot(2, 24), FlSpot(3, 23), FlSpot(4, 25),
      FlSpot(5, 27), FlSpot(6, 28), FlSpot(7, 26) // Mát mẻ, giao mùa
    ],
    'Hồ Chí Minh': const [
      FlSpot(1, 32), FlSpot(2, 33), FlSpot(3, 34), FlSpot(4, 32),
      FlSpot(5, 33), FlSpot(6, 35), FlSpot(7, 34) // Nóng bức, mùa khô
    ],
  };

  final Map<String, List<FlSpot>> humData = {
    'Hà Nội': const [
      FlSpot(1, 80), FlSpot(2, 82), FlSpot(3, 78), FlSpot(4, 75),
      FlSpot(5, 85), FlSpot(6, 88), FlSpot(7, 83) // Độ ẩm cao
    ],
    'Hồ Chí Minh': const [
      FlSpot(1, 60), FlSpot(2, 58), FlSpot(3, 55), FlSpot(4, 62),
      FlSpot(5, 65), FlSpot(6, 59), FlSpot(7, 61) // Độ ẩm thấp
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
            "Dữ Liệu Môi Trường",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Nút chuyển đổi Khu vực (Location Toggle)
              _buildLocationSelector(),
              const SizedBox(height: 24),

              // 2. Thẻ hiển thị thông số hiện tại (Real-time Stats)
              _buildCurrentStats(),
              const SizedBox(height: 32),

              // 3. Biểu đồ Nhiệt độ
              _buildChartSection(
                title: "Nhiệt độ 7 ngày qua (°C)",
                spots: tempData[selectedLocation]!,
                lineColor: Colors.orangeAccent,
                gradientColors: [Colors.orangeAccent.withOpacity(0.3), Colors.transparent],
                minY: 15,
                maxY: 40,
              ),
              const SizedBox(height: 32),

              // 4. Biểu đồ Độ ẩm
              _buildChartSection(
                title: "Độ ẩm 7 ngày qua (%)",
                spots: humData[selectedLocation]!,
                lineColor: Colors.blueAccent,
                gradientColors: [Colors.blueAccent.withOpacity(0.3), Colors.transparent],
                minY: 40,
                maxY: 100,
              ),
              const SizedBox(height: 30),

              // 5. Footer Demo Notice
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      Text("Dữ liệu đang chạy ở chế độ Demo", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget: Trạm chọn khu vực
  Widget _buildLocationSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: ['Hà Nội', 'Hồ Chí Minh'].map((location) {
          final isSelected = selectedLocation == location;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedLocation = location),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00B894) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    location,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Widget: Thẻ thông số nổi bật hiện tại
  Widget _buildCurrentStats() {
    // Lấy chỉ số ngày cuối cùng (ngày 7) làm chỉ số hiện tại
    final currentTemp = tempData[selectedLocation]!.last.y;
    final currentHum = humData[selectedLocation]!.last.y;

    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: "Nhiệt độ hiện tại",
            value: "${currentTemp.toInt()}°C",
            icon: Icons.thermostat,
            color: Colors.orangeAccent,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            title: "Độ ẩm đất/kk",
            value: "${currentHum.toInt()}%",
            icon: Icons.water_drop,
            color: Colors.blueAccent,
          ),
        ),
      ],
    );
  }

  Widget _statCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // Widget: Cấu trúc chung cho Biểu đồ
  Widget _buildChartSection({
    required String title,
    required List<FlSpot> spots,
    required Color lineColor,
    required List<Color> gradientColors,
    required double minY,
    required double maxY,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.only(right: 16, left: 0, top: 16, bottom: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              minX: 1,
              maxX: 7,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 10,
                getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        child: Text('T${value.toInt() + 1}', style: style), // Hiển thị T2, T3, T4...
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 10,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 12));
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: lineColor,
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4, color: Colors.white, strokeWidth: 2, strokeColor: lineColor,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(colors: gradientColors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}