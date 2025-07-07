import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/intro_video.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);  // Thêm dòng này để video lặp lại
        _controller.play();
      });
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Giải phóng bộ nhớ khi không còn sử dụng video
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            // Hiển thị video toàn màn hình
            Positioned.fill(
              child: VideoPlayer(_controller),
            ),
            // Văn bản và nút mũi tên
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    'Bắt đầu cải thiện cân nặng, vóc dáng và sức khỏe của bạn từ những việc đơn giản nhất!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Icon(Icons.arrow_forward),
                  style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(20),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
