import 'package:flutter/material.dart';
import 'dart:async';
import 'package:caloer_app/service/chat_gemini_service.dart';
import 'package:caloer_app/screens/home_screen.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ChatGeminiService _chatService = ChatGeminiService();
  final ScrollController _scrollController = ScrollController();

  bool _isTyping = false;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels <
          _scrollController.position.maxScrollExtent - 300) {
        if (!_showScrollToBottom) {
          setState(() {
            _showScrollToBottom = true;
          });
        }
      } else {
        if (_showScrollToBottom) {
          setState(() {
            _showScrollToBottom = false;
          });
        }
      }
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.05),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => HomeScreen(),
                transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                transitionDuration: Duration(milliseconds: 300),
              ),
            );
          },
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
                radius: 18,
                child: Icon(
                  Icons.smart_toy_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trợ lý ảo sức khỏe',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: Colors.grey.shade700),
            onPressed: () {
              _showHelpBottomSheet();
            },
            tooltip: 'Trợ giúp',
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
            onPressed: () {
              _showOptionsMenu();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  // image: DecorationImage(
                  //   image: AssetImage('assets/chat_bg.png'),
                  //   opacity: 0.03,
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Stack(
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                      itemCount: _messages.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        return _buildMessageWithAnimation(
                          _messages[_messages.length - 1 - index],
                          _messages.length - 1 - index,
                        );
                      },
                    ),
                    if (_messages.isEmpty)
                      _buildWelcomeMessage(),
                    if (_showScrollToBottom)
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton(
                          mini: true,
                          backgroundColor: Colors.white,
                          elevation: 4,
                          onPressed: _scrollToBottom,
                          child: Icon(
                            Icons.arrow_downward,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_isTyping)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _buildTypingIndicator(),
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, -2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.06),
                  ),
                ],
              ),
              padding: EdgeInsets.fromLTRB(8, 12, 8, 12),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {},
                        tooltip: 'Nhập giọng nói',
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'Nhập tin nhắn...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          maxLines: 5,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: _isTyping ? null : _handleSubmitted,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor,
                            Theme.of(context).primaryColor.withBlue(
                              Theme.of(context).primaryColor.blue + 40,
                            ),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.4),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isTyping ? Icons.hourglass_top : Icons.send_rounded,
                          color: Colors.white,
                        ),
                        onPressed: _isTyping
                            ? null
                            : () {
                          _handleSubmitted(_textController.text);
                        },
                        tooltip: 'Gửi',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.health_and_safety_outlined,
              size: 60,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Trợ lý sức khỏe cá nhân',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Xin chào! Tôi là trợ lý ảo sức khỏe. Hãy hỏi tôi về dinh dưỡng, tập luyện hoặc bất kỳ mục tiêu sức khỏe nào của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ),
          SizedBox(height: 30),
          _buildSuggestionChips(),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    List<String> suggestions = [
      "Chế độ ăn cho người tập gym",
      "Cách giảm cân hiệu quả",
      "Chế độ tập luyện cho người mới",
      "Chế độ ăn giàu protein",
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((suggestion) {
        return ActionChip(
          elevation: 0,
          backgroundColor: Colors.white,
          side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.3)),
          label: Text(
            suggestion,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          onPressed: () {
            _handleSubmitted(suggestion);
          },
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.smart_toy_rounded,
            size: 14,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: 42,
          child: Row(
            children: List.generate(
              3,
                  (index) => Padding(
                padding: EdgeInsets.only(right: 4),
                child: _buildPulsingDot(index),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPulsingDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageWithAnimation(ChatMessage message, int index) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(message.isUser ? 1 : -1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: AnimationController(
          vsync: this,
          duration: Duration(milliseconds: 300),
        )..forward(),
        curve: Curves.easeOutQuad,
      )),
      child: message,
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text("Xóa cuộc trò chuyện"),
                onTap: () {
                  Navigator.pop(context);
                  _showClearChatConfirmation();
                },
              ),
              ListTile(
                leading: Icon(Icons.share_outlined),
                title: Text("Chia sẻ trò chuyện"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline),
                title: Text("Trợ giúp & Phản hồi"),
                onTap: () {
                  Navigator.pop(context);
                  _showHelpBottomSheet();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showHelpBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: 20, left: MediaQuery.of(context).size.width * 0.5 - 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                "Hướng dẫn sử dụng",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildHelpItem(
                      Icons.chat_bubble_outline,
                      "Trò chuyện với trợ lý",
                      "Đặt câu hỏi về dinh dưỡng, tập luyện, và các mục tiêu sức khỏe của bạn.",
                    ),
                    _buildHelpItem(
                      Icons.fact_check_outlined,
                      "Theo dõi tiến độ",
                      "Xem lịch sử hoạt động và dữ liệu sức khỏe của bạn.",
                    ),
                    _buildHelpItem(
                      Icons.restaurant_menu,
                      "Chế độ ăn",
                      "Nhận gợi ý về chế độ ăn uống phù hợp với mục tiêu của bạn.",
                    ),
                    _buildHelpItem(
                      Icons.fitness_center,
                      "Tập luyện",
                      "Tìm hiểu các bài tập và lịch trình tập luyện.",
                    ),
                    Divider(height: 32),
                    Text(
                      "Gửi phản hồi",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Chúng tôi luôn mong muốn cải thiện ứng dụng. Nếu bạn có bất kỳ góp ý nào, vui lòng cho chúng tôi biết!",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Center(
                              child: Text(
                                "Gửi phản hồi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Xóa cuộc trò chuyện"),
          content: Text("Bạn có chắc chắn muốn xóa toàn bộ cuộc trò chuyện này?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Hủy",
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _messages.clear();
                });
                Navigator.of(context).pop();
              },
              child: Text(
                "Xóa",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();

    ChatMessage userMessage = ChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      _messages.add(userMessage); // Thêm tin nhắn người dùng vào cuối danh sách
      _isTyping = true;
    });

    // Cuộn xuống tin nhắn mới nhất
    Timer(Duration(milliseconds: 100), () {
      _scrollToBottom();
    });

    try {
      // Gửi yêu cầu đến Gemini API
      final response = await _chatService.sendMessage(text);

      // Thêm phản hồi của bot
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add( // Thêm phản hồi bot vào cuối danh sách
            ChatMessage(
              text: response,
              isUser: false,
            ),
          );
        });

        // Cuộn xuống tin nhắn mới nhất
        Timer(Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollToBottom();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: "Xin lỗi, đã có lỗi xảy ra. Vui lòng thử lại sau.",
              isUser: false,
            ),
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAvatar(context),
          SizedBox(width: isUser ? 0 : 12),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser ? Radius.circular(20) : Radius.circular(0),
                  bottomRight: isUser ? Radius.circular(0) : Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment:
                    isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedTime(),
                        style: TextStyle(
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                      if (isUser) ...[
                        SizedBox(width: 4),
                        Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: isUser ? 12 : 0),
          if (isUser) _buildUserAvatar(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
        radius: 16,
        child: Icon(
          Icons.smart_toy_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 4),
      child: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        radius: 16,
        child: Icon(
          Icons.person,
          color: Colors.grey.shade500,
          size: 16,
        ),
      ),
    );
  }

  String _getFormattedTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }
}