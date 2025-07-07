import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/step_service.dart';
import 'package:intl/intl.dart';

class StepCounterScreen extends StatefulWidget {
  @override
  _StepCounterScreenState createState() => _StepCounterScreenState();
}

class _StepCounterScreenState extends State<StepCounterScreen> {
  final StepService _stepService = StepService();
  late Stream<StepCount> _stepCountStream;
  int _todaySteps = 0;
  int _previousSteps = 0;
  double _calories = 0.0;
  bool _isLoading = true;
  double _weight = 70.0; // Giả sử mặc định, lấy từ UserService nếu cần
  double _strideLength = 78.0; // cm, nam

  @override
  void initState() {
    super.initState();
    _initUserData();
    _fetchStepsData();
    _initPedometer();
  }

  Future<void> _initUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weight = prefs.getDouble('weight') ?? 70.0; // Lấy từ UserService nếu có
    });
  }

  Future<void> _fetchStepsData() async {
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final stepData = await _stepService.fetchSteps(formattedDate);
      setState(() {
        _todaySteps = (stepData['steps'] as num?)?.toInt() ?? 0;
        _calories = (stepData['calories'] as num?)?.toDouble() ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching steps: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      final prefs = await SharedPreferences.getInstance();
      _previousSteps = prefs.getInt('previous_steps') ?? 0;
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError((error) {
        print("Lỗi đếm bước: $error");
        setState(() => _isLoading = false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cần cấp quyền để đếm bước chân'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  void _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    int totalSteps = event.steps;
    int todaySteps = totalSteps - _previousSteps;

    if (todaySteps < 0) {
      _previousSteps = totalSteps;
      todaySteps = 0;
      await prefs.setInt('previous_steps', _previousSteps);
    }

    // Tính calo cục bộ để kiểm tra
    double calories = _weight * (todaySteps * _strideLength / 100000) * 0.57;

    setState(() {
      _todaySteps = todaySteps;
      _calories = calories;
    });

    // Gửi lên API
    try {
      final stepData = await _stepService.updateSteps(todaySteps);
      setState(() {
        _todaySteps = (stepData['steps'] as num?)?.toInt() ?? todaySteps;
        _calories = (stepData['calories'] as num?)?.toDouble() ?? calories;
      });
      await prefs.setInt('previous_steps', totalSteps);
    } catch (e) {
      print("❌ Error updating steps: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bước đi trong ngày', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.directions_walk, size: 60, color: Theme.of(context).primaryColor),
                    SizedBox(height: 8),
                    Text('$_todaySteps', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    Text('Bước hôm nay', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStat('Calo', '${_calories.toStringAsFixed(1)} kcal', Colors.orange),
                        SizedBox(width: 16),
                        _buildStat('Quãng đường', '${(_todaySteps * _strideLength / 100000).toStringAsFixed(2)} km', Colors.blue),
                      ],
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

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
        SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

