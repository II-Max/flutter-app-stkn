import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Dữ Liệu Môi Trường", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Nhiệt độ 7 ngày qua (°C)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(1, 28), FlSpot(2, 29), FlSpot(3, 27),
                          FlSpot(4, 30), FlSpot(5, 28), FlSpot(6, 26), FlSpot(7, 28),
                        ],
                        isCurved: true,
                        color: const Color(0xFF00B894),
                        barWidth: 4,
                        belowBarData: BarAreaData(
                          show: true,
                          color: const Color(0xFF00B894).withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(child: Text("Dữ liệu đang chạy ở chế độ Demo", style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }
}