import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CanNangScreen extends StatefulWidget {
  const CanNangScreen({super.key});

  @override
  _CanNangScreenState createState() => _CanNangScreenState();
}

class _CanNangScreenState extends State<CanNangScreen> {
  double initialWeight = 68;
  double currentWeight = 68;
  double goalWeight = 75;
  List<Map<String, dynamic>> weightHistory = [];

  @override
  void initState() {
    super.initState();
    _loadData(); // Tải dữ liệu khi mở ứng dụng
  }

  // 🔹 Tải dữ liệu từ SharedPreferences
  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      initialWeight = prefs.getDouble("initialWeight") ?? 68;
      currentWeight = prefs.getDouble("currentWeight") ?? 68;
      goalWeight = prefs.getDouble("goalWeight") ?? 75;

      String? historyString = prefs.getString("weightHistory");
      if (historyString != null) {
        weightHistory = List<Map<String, dynamic>>.from(json.decode(historyString));
      }
    });
  }

  // 🔹 Lưu dữ liệu vào SharedPreferences
  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble("initialWeight", initialWeight);
    prefs.setDouble("currentWeight", currentWeight);
    prefs.setDouble("goalWeight", goalWeight);
    prefs.setString("weightHistory", json.encode(weightHistory));
  }

  void _editWeight(String type) {
    TextEditingController controller = TextEditingController();
    controller.text = (type == "initial"
        ? initialWeight
        : type == "current"
        ? currentWeight
        : goalWeight)
        .toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Cập nhật cân nặng", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Nhập cân nặng",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  double newWeight = double.tryParse(controller.text) ?? 0;
                  if (newWeight > 0) {
                    if (type == "initial") {
                      initialWeight = newWeight;
                    } else if (type == "current") {
                      currentWeight = newWeight;
                      weightHistory.insert(0, {
                        "date": _getFormattedDate(),
                        "weight": newWeight
                      });
                    } else {
                      goalWeight = newWeight;
                    }
                    _saveData(); // Lưu dữ liệu sau khi cập nhật
                  }
                });
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }

  String _getFormattedDate() {
    DateTime now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Quản lý cân nặng", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildWeightCard("Ban đầu", initialWeight, "initial"),
                    _buildWeightCard("Hiện tại", currentWeight, "current"),
                    _buildWeightCard("Mục tiêu", goalWeight, "goal"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: _buildWeightHistory(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightCard(String title, double weight, String type) {
    return GestureDetector(
      onTap: () => _editWeight(type),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 5),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text("$weight kg", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(width: 5),
                Icon(Icons.edit, size: 16, color: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightHistory() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Lịch sử cân nặng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: weightHistory.length,
                itemBuilder: (context, index) {
                  final history = weightHistory[index];
                  return ListTile(
                    leading: Icon(Icons.calendar_today, color: Colors.green),
                    title: Text(history["date"], style: TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Text(
                      "${history["weight"]} kg",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
