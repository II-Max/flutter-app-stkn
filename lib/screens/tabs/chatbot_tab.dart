import 'package:flutter/material.dart';

class ChatbotTab extends StatefulWidget {
  const ChatbotTab({super.key});

  @override
  State<ChatbotTab> createState() => _ChatbotTabState();
}

class _ChatbotTabState extends State<ChatbotTab> {
  final List<Map<String, dynamic>> _messages = [
    {
      "role": "bot",
      "text": "Chào bạn! Tôi là Trợ lý AI của Smart Farm. Tôi được tích hợp dữ liệu viễn thám NASA và có thể giúp bạn quản trị rủi ro trang trại. Bạn cần tìm hiểu thông tin gì?"
    }
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  final List<String> _suggestedQuestions = [
    "Cách dự báo thời tiết?",
    "Hệ thống giúp tiết kiệm bao nhiêu?",
    "Cấu trúc phần cứng ra sao?",
    "Bạn là ai?",
    "Bản sao số (Digital Twin) là gì?"
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isTyping = true;
    });

    _controller.clear();
    _focusNode.requestFocus();
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            "role": "bot",
            "text": _generateBotResponse(text)
          });
        });
        _scrollToBottom();
      }
    });
  }

  String _generateBotResponse(String query) {
    String lowerQuery = query.toLowerCase();

    if (lowerQuery.contains("chào") || lowerQuery.contains("hello") || lowerQuery.contains("hi")) {
      return "Chào bạn! Chúc trang trại của bạn một ngày năng suất. Bạn cần tôi phân tích thông số thời tiết hay tư vấn giải pháp tối ưu chi phí hôm nay?";
    }
    else if (lowerQuery.contains("bạn là ai") || lowerQuery.contains("tên gì") || lowerQuery.contains("who are you")) {
      return "Tôi là Trợ lý AI độc quyền của nền tảng Smart Farm. Nhiệm vụ của tôi là giúp bạn đón đầu thời tiết và tự động hóa nông nghiệp.";
    }
    else if (lowerQuery.contains("thời tiết") || lowerQuery.contains("dự báo") || lowerQuery.contains("nasa") || lowerQuery.contains("rủi ro")) {
      return "Dự án dung hợp dữ liệu viễn thám NASA GMAO và cảm biến IoT nội trạm. Khi phát hiện thời tiết cực đoan (bão, nắng gắt), AI sẽ tự động kích hoạt kịch bản phòng vệ từ sớm, giúp bạn bảo toàn 100% tài sản.";
    }
    else if (lowerQuery.contains("tiết kiệm") || lowerQuery.contains("chi phí") || lowerQuery.contains("điện") || lowerQuery.contains("nước")) {
      return "Bằng công nghệ Nông nghiệp Chính xác, AI sẽ tính toán 'điểm rơi sinh học' để tưới đúng lúc, đủ lượng. Giúp trang trại cắt giảm trực tiếp 20-30% chi phí vận hành (OPEX).";
    }
    else if (lowerQuery.contains("phần cứng") || lowerQuery.contains("thiết bị") || lowerQuery.contains("plc") || lowerQuery.contains("esp32")) {
      return "Chúng tôi áp dụng cấu trúc Phần cứng lai (Hybrid Hardware). Tùy quy mô, hệ thống dùng ESP32 giúp giảm 60% chi phí, hoặc dùng PLC Siemens S7-1200 cho trang trại chuẩn công nghiệp.";
    }
    else if (lowerQuery.contains("gói") || lowerQuery.contains("dịch vụ") || lowerQuery.contains("giá")) {
      return "Hệ thống có 3 gói theo mô hình SaaS: \n1. Khởi Điểm (Smart Control).\n2. Tự Động (Smart Auto).\n3. Toàn Diện (AI & NASA).";
    }
    else if (lowerQuery.contains("bản sao số") || lowerQuery.contains("digital twin") || lowerQuery.contains("mô phỏng")) {
      return "Digital Twin tạo ra một 'Bản sao ảo' của trang trại. AI sẽ chạy thử nghiệm kịch bản khí hậu trên không gian số để chọn phương án tưới tiêu tối ưu nhất.";
    }
    else {
      return "Câu hỏi rất thú vị! Ở phiên bản này, tôi được huấn luyện về công nghệ lõi (NASA, AI, Digital Twin) và quản trị rủi ro. Bạn có thể hỏi tôi chi tiết về các chủ đề đó nhé!";
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, color: Color(0xFF00B894)),
            SizedBox(width: 8),
            Text("Trợ Lý AI Smart Farm", style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return _buildMessageBubble(msg["text"], isUser);
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("AI đang phân tích dữ liệu...", style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ),

          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _suggestedQuestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  child: ActionChip(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF00B894), width: 1),
                    label: Text(_suggestedQuestions[index], style: const TextStyle(color: Color(0xFF00B894), fontSize: 12, fontWeight: FontWeight.w600)),
                    onPressed: () => _sendMessage(_suggestedQuestions[index]),
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.send,
                    textCapitalization: TextCapitalization.sentences,

                    // TỔ HỢP TẮT CÁC TÍNH NĂNG GÂY XUNG ĐỘT BỘ GÕ
                    autocorrect: false,
                    enableSuggestions: false,
                    spellCheckConfiguration: const SpellCheckConfiguration.disabled(),

                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: "Nhập câu hỏi...",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFFF5F6FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00B894),
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    onPressed: () => _sendMessage(_controller.text),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF00B894) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          boxShadow: [
            if (!isUser) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
          ],
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }
}