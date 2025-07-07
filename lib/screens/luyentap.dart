import 'package:caloer_app/screens/statistic_screen.dart';
import 'package:flutter/material.dart';
import 'package:caloer_app/screens/home_screen.dart';
import 'package:caloer_app/screens/chat_screen.dart';
import 'package:caloer_app/screens/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart' show canLaunchUrl, launchUrl, LaunchMode;

class TapLuyenScreen extends StatefulWidget {
  @override
  _TapLuyenScreenState createState() => _TapLuyenScreenState();
}

class _TapLuyenScreenState extends State<TapLuyenScreen> {
  int _selectedIndex = 2; // Tab "Tập luyện" mặc định

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // Ngăn điều hướng nếu đã ở màn hình hiện tại
    setState(() {
      _selectedIndex = index;
    });
    final screens = [
      HomeScreen(),
      ChatScreen(),
      TapLuyenScreen(),
      ProfileScreen(),
      StatisticsScreen()
    ];
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screens[index],
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Danh sách bài tập",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Tìm kiếm bài tập'),
                  content: TextField(
                    decoration: InputDecoration(hintText: 'Nhập tên bài tập'),
                    onSubmitted: (value) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Tìm kiếm: $value')),
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildWorkoutProgram(
            "Dành cho người mới",
            "14 ngày",
            "assets/nguoi_moi.jpg",
          ),
          _buildWorkoutProgram(
            "Giảm cân toàn thân",
            "28 ngày",
            "assets/giam_can.jpg",
          ),
          _buildWorkoutProgram(
            "Đốt cháy mỡ bụng",
            "18 ngày",
            "assets/mo_bung.jpg",
          ),
          _buildWorkoutProgram(
            "Tăng cơ săn chắc",
            "30 ngày",
            "assets/tang_co.jpg",
          ),
          _buildWorkoutProgram(
            "Yoga thư giãn",
            "21 ngày",
            "assets/yoga.jpg",
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWorkoutProgram(String title, String duration, String imagePath) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailScreen(
              title: title,
              duration: duration,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(15),
      splashColor: Colors.green.withOpacity(0.3), // Hiệu ứng nhấn
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        height: MediaQuery.of(context).size.height * 0.25, // Responsive height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width < 600 ? 20 : 24, // Responsive font
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      duration,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: MediaQuery.of(context).size.width < 600 ? 16 : 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          elevation: 0,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.black45,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Khám Phá'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Cá Nhân'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Thống kê'),
          ],
        ),
      ),
    );
  }
}

class WorkoutDetailScreen extends StatefulWidget {
  final String title;
  final String duration;

  WorkoutDetailScreen({required this.title, required this.duration});

  @override
  _WorkoutDetailScreenState createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool isLoading = false;
  final Set<int> _completedDays = {}; // Theo dõi các ngày được chọn

  // Ánh xạ tiêu đề chương trình với liên kết video YouTube
  final Map<String, String> workoutVideoLinks = {
    "Dành cho người mới": "https://www.youtube.com/watch?v=LnTQe-mpb_Q",
    "Giảm cân toàn thân": "https://www.youtube.com/watch?v=UC4B_CjUcZ4",
    "Đốt cháy mỡ bụng": "https://www.youtube.com/watch?v=8SPSYTx1s1g",
    "Tăng cơ săn chắc": "https://www.youtube.com/watch?v=UBMk3sOZmN4",
    "Yoga thư giãn": "https://www.youtube.com/watch?v=UCvGEK5_U-k",
  };

  Future<void> _launchVideo(String url) async {
    setState(() => isLoading = true);
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Mở trong ứng dụng YouTube
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở video'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi mở video: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _toggleDayCompletion(int day) {
    setState(() {
      if (_completedDays.contains(day)) {
        _completedDays.remove(day);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã bỏ đánh dấu ngày $day')),
        );
      } else {
        _completedDays.add(day);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã đánh dấu hoàn thành ngày $day')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Danh sách bài tập",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Quay lại TapLuyenScreen
          },
        ),
      ),
      body: ListView(
        children: [
          _buildProgramHeader(context),
          _buildProgramDays(),
          SizedBox(height: 20),
          _buildRestartButton(context),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProgramHeader(BuildContext context) {
    final videoUrl = workoutVideoLinks[widget.title] ?? "https://www.youtube.com";
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chương trình: ${widget.title}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Thời gian: ${widget.duration}",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Text(
            "Chi tiết:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Hãy thực hiện chương trình kéo dài ${widget.duration.toLowerCase()} này, được thiết kế để giúp bạn giảm cân bằng các bài tập HIIT và tập cơ bụng! Thử thách này thân thiện với người mới bắt đầu vì chỉ kéo dài ${widget.duration.toLowerCase()}, không có các biến thể nhảy, cũng như không cần thiết bị.",
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: isLoading ? null : () => _launchVideo(videoUrl),
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
              "Xem Video Hướng Dẫn",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
              minimumSize: Size(double.infinity, 50), // Full-width button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramDays() {
    int days = int.parse(widget.duration.split(" ")[0]);
    List<Widget> dayWidgets = [];

    for (int i = 1; i <= days; i++) {
      bool isRestDay = i % 4 == 0;
      bool isCompleted = _completedDays.contains(i);

      dayWidgets.add(
        InkWell(
          onTap: isRestDay
              ? null
              : () {
            _toggleDayCompletion(i);
          },
          borderRadius: BorderRadius.circular(15),
          splashColor: Colors.green.withOpacity(0.3),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  child: Column(
                    children: [
                      Text(
                        "Ngày",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        i.toString().padLeft(2, '0'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    isRestDay ? "Hãy dành thời gian nghỉ ngơi" : "5 bài tập / 58 phút",
                    style: TextStyle(
                      fontSize: 16,
                      color: isRestDay ? Colors.orange : Colors.black,
                    ),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    color: isCompleted ? Colors.green.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: isCompleted ? Icon(Icons.check, size: 16, color: Colors.green) : null,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(children: dayWidgets);
  }

  Widget _buildRestartButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _completedDays.clear(); // Đặt lại tất cả ngày hoàn thành
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã bắt đầu lại chương trình ${widget.title}')),
          );
        },
        child: Text(
          "Tập lại chương trình này",
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: EdgeInsets.symmetric(vertical: 15),
          minimumSize: Size(double.infinity, 50), // Full-width button
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}