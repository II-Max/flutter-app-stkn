import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import 'tabs/chatbot_tab.dart';
import 'tabs/data_tab.dart';
import 'tabs/profile_tab.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  // Danh sách 4 màn hình con
  final List<Widget> _tabs = [
    const HomeTab(),
    const ChatbotTab(),
    const DataTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex], // Hiển thị tab đang chọn
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF00B894).withOpacity(0.2),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Trang Chủ'),
            NavigationDestination(icon: Icon(Icons.smart_toy_rounded), label: 'ChatBot'),
            NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'Dữ Liệu'),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Người Dùng'),
          ],
        ),
      ),
    );
  }
}