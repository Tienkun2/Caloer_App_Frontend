import 'package:caloer_app/screens/login_screen.dart';
import 'package:caloer_app/screens/home_screen.dart';
import 'package:caloer_app/service/google_auth_service.dart';
import 'package:flutter/material.dart';
import '../service/user_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
    'weight': TextEditingController(),
    'height': TextEditingController(),
    'age': TextEditingController(),
    'waist': TextEditingController(),
    'hip': TextEditingController(),
    'biceps': TextEditingController(),
    'thigh': TextEditingController(),
    'firstWeight': TextEditingController(),
  };
  String email = "", gender = "Nam", goal = "Duy trì cân nặng", state = "", name = "";
  double bmr = 0, tdee = 0, bmi = 0, caloDeficit = 0, firstWeight = 0, dailyCalories = 0;
  String? createdate;
  bool isLoading = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    controllers.forEach((key, controller) {
      controller.addListener(() {
        if (controller.selection.baseOffset == 0 && controller.text.isNotEmpty) {
          controller.clear();
        }
      });
    });
    _loadUserData();
  }

  bool _isProfileComplete() {
    // Kiểm tra name
    if (controllers['name']!.text.isEmpty) {
      _showValidationError('Vui lòng nhập tên');
      return false;
    }
    if (controllers['name']!.text.length > 100) {
      _showValidationError('Tên không được vượt quá 100 ký tự');
      return false;
    }

    // Kiểm tra weight
    if (controllers['weight']!.text.isEmpty) {
      _showValidationError('Vui lòng nhập cân nặng');
      return false;
    }
    final weight = double.tryParse(controllers['weight']!.text);
    if (weight == null || weight <= 0) {
      _showValidationError('Cân nặng phải là số dương');
      return false;
    }
    if (weight > 500) {
      _showValidationError('Cân nặng không được vượt quá 500 kg');
      return false;
    }

    // Kiểm tra height
    if (controllers['height']!.text.isEmpty) {
      _showValidationError('Vui lòng nhập chiều cao');
      return false;
    }
    final height = double.tryParse(controllers['height']!.text);
    if (height == null || height <= 0) {
      _showValidationError('Chiều cao phải là số dương');
      return false;
    }
    if (height > 300) {
      _showValidationError('Chiều cao không được vượt quá 300 cm');
      return false;
    }
    if (!_isValidDecimalFormat(controllers['height']!.text, 3, 1)) {
      _showValidationError('Chiều cao phải có tối đa 3 chữ số nguyên và 1 chữ số thập phân');
      return false;
    }

    // Kiểm tra age
    if (controllers['age']!.text.isEmpty) {
      _showValidationError('Vui lòng nhập tuổi');
      return false;
    }
    final age = int.tryParse(controllers['age']!.text);
    if (age == null || age <= 0) {
      _showValidationError('Tuổi phải là số nguyên dương');
      return false;
    }
    if (age > 150) {
      _showValidationError('Tuổi không được vượt quá 150');
      return false;
    }

    // Kiểm tra gender
    if (gender.isEmpty || !['Nam', 'Nữ'].contains(gender)) {
      _showValidationError('Vui lòng chọn giới tính hợp lệ (Nam hoặc Nữ)');
      return false;
    }

    // Kiểm tra goal
    if (goal.isEmpty || !['Giảm cân', 'Duy trì cân nặng', 'Tăng cân'].contains(goal)) {
      _showValidationError('Vui lòng chọn mục tiêu hợp lệ');
      return false;
    }

    // Kiểm tra firstWeight (nếu có)
    if (controllers['firstWeight']!.text.isNotEmpty) {
      final firstWeight = double.tryParse(controllers['firstWeight']!.text);
      if (firstWeight == null || firstWeight <= 0) {
        _showValidationError('Cân nặng ban đầu phải là số dương');
        return false;
      }
      if (firstWeight > 500) {
        _showValidationError('Cân nặng ban đầu không được vượt quá 500 kg');
        return false;
      }
      if (!_isValidDecimalFormat(controllers['firstWeight']!.text, 3, 1)) {
        _showValidationError('Cân nặng ban đầu phải có tối đa 3 chữ số nguyên và 1 chữ số thập phân');
        return false;
      }
    }

    return true;
  }

  bool _isValidDecimalFormat(String value, int integerDigits, int fractionDigits) {
    final regex = RegExp(r'^\d{1,' + integerDigits.toString() + r'}(\.\d{0,' + fractionDigits.toString() + r'})?$');
    return regex.hasMatch(value);
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userService.fetchUserData();
      if (userData != null) {
        setState(() {
          email = userData['email'] ?? "";
          name = userData['name'] ?? "";
          gender = (userData['gender'] == "Nu") ? "Nữ" : "Nam";
          goal = {
            'MAINTAIN_WEIGHT': 'Duy trì cân nặng',
            'LOSE_WEIGHT': 'Giảm cân',
            'GAIN_WEIGHT': 'Tăng cân'
          }[userData['goal']] ?? 'Duy trì cân nặng';
          bmr = _safeParseDouble(userData['bmr']);
          tdee = _safeParseDouble(userData['tdee']);
          bmi = _safeParseDouble(userData['bmi']);
          caloDeficit = _safeParseDouble(userData['caloDeficit']);
          firstWeight = _safeParseDouble(userData['firstWeight']);
          dailyCalories = _safeParseDouble(userData['dailyCalories']);
          state = userData['state'] ?? "";
          createdate = userData['createdate'];
          controllers.forEach((key, controller) => controller.text = userData[key]?.toString() ?? "");
        });
      }
    } catch (e) {
      print("❌ Error loading user data: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  double _safeParseDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0.0;

  Future<void> _updateProfileData() async {
    if (!_isProfileComplete()) {
      // Nếu dữ liệu không hợp lệ, xóa các trường nhập liệu trừ trường name và đặt các giá trị về 0
      setState(() {
        controllers.forEach((key, controller) {
          if (key != 'name') controller.clear();
        });
        gender = "Nam";
        goal = "Duy trì cân nặng";
        bmr = 0;
        tdee = 0;
        bmi = 0;
        caloDeficit = 0;
        firstWeight = 0;
        dailyCalories = 0;
        state = "";
        createdate = null;
      });
      return;
    }

    final userData = <String, dynamic>{};
    if (controllers['name']!.text.isNotEmpty) userData['name'] = controllers['name']!.text;
    if (controllers['weight']!.text.isNotEmpty) userData['weight'] = double.tryParse(controllers['weight']!.text);
    if (controllers['height']!.text.isNotEmpty) userData['height'] = double.tryParse(controllers['height']!.text);
    if (controllers['age']!.text.isNotEmpty) userData['age'] = int.tryParse(controllers['age']!.text);
    if (controllers['firstWeight']!.text.isNotEmpty) userData['firstWeight'] = double.tryParse(controllers['firstWeight']!.text);
    if (gender.isNotEmpty) userData['gender'] = gender == "Nữ" ? "Nu" : "Nam";
    userData['goal'] = {
      'Duy trì cân nặng': 'MAINTAIN_WEIGHT',
      'Giảm cân': 'LOSE_WEIGHT',
      'Tăng cân': 'GAIN_WEIGHT'
    }[goal] ?? 'MAINTAIN_WEIGHT';
    if (controllers['waist']!.text.isNotEmpty) userData['waist'] = double.tryParse(controllers['waist']!.text);
    if (controllers['hip']!.text.isNotEmpty) userData['hip'] = double.tryParse(controllers['hip']!.text);
    if (controllers['biceps']!.text.isNotEmpty) userData['biceps'] = double.tryParse(controllers['biceps']!.text);
    if (controllers['thigh']!.text.isNotEmpty) userData['thigh'] = double.tryParse(controllers['thigh']!.text);

    setState(() => isLoading = true);
    try {
      bool success = await _userService.updateUserData(userData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Text(success ? 'Cập nhật thành công' : 'Cập nhật thất bại'),
          ]),
          backgroundColor: success ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      if (success) {
        await _loadUserData();
        if (_isProfileComplete()) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => HomeScreen(),
              transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
              transitionDuration: Duration(milliseconds: 300),
            ),
          );
        }
      } else {
        // Nếu cập nhật thất bại do lỗi server, xóa các trường nhập liệu trừ name và đặt các giá trị về 0
        setState(() {
          controllers.forEach((key, controller) {
            if (key != 'name') controller.clear();
          });
          gender = "Nam";
          goal = "Duy trì cân nặng";
          bmr = 0;
          tdee = 0;
          bmi = 0;
          caloDeficit = 0;
          firstWeight = 0;
          dailyCalories = 0;
          state = "";
          createdate = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật dữ liệu'), backgroundColor: Colors.red),
      );
      // Nếu có ngoại lệ, xóa các trường nhập liệu trừ name và đặt các giá trị về 0
      setState(() {
        controllers.forEach((key, controller) {
          if (key != 'name') controller.clear();
        });
        gender = "Nam";
        goal = "Duy trì cân nặng";
        bmr = 0;
        tdee = 0;
        bmi = 0;
        caloDeficit = 0;
        firstWeight = 0;
        dailyCalories = 0;
        state = "";
        createdate = null;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Đăng xuất"),
        content: Text("Bạn có chắc chắn muốn đăng xuất?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Hủy")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      try {
        await _userService.logout();
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
          await googleSignIn.signOut();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đăng xuất thành công'), backgroundColor: Colors.green),
        );
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => LoginScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: Duration(milliseconds: 300),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi đăng xuất: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleClearData() async {
    bool? confirmClear = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Xóa dữ liệu"),
        content: Text("Bạn có chắc chắn muốn xóa toàn bộ dữ liệu cá nhân? Hành động này không thể hoàn tác."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmClear == true) {
      setState(() => isLoading = true);
      try {
        bool success = await _userService.clearUserData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text(success ? 'Xóa dữ liệu thành công' : 'Xóa dữ liệu thất bại'),
            ]),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        if (success) {
          controllers.forEach((key, controller) => controller.clear());
          setState(() {
            name = "";
            gender = "Nam";
            goal = "Duy trì cân nặng";
            bmr = 0;
            tdee = 0;
            bmi = 0;
            caloDeficit = 0;
            firstWeight = 0;
            dailyCalories = 0;
            state = "";
            createdate = null;
          });
          _loadUserData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa dữ liệu: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _handleUpdateWeightLostDaily() async {
    bool? confirmUpdate = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Cập nhật cân nặng hàng ngày"),
        content: Text("Bạn có chắc chắn muốn cập nhật số kg giảm hàng ngày?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Cập nhật", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (confirmUpdate == true) {
      setState(() => isLoading = true);
      try {
        bool success = await _userService.updateWeightLostDaily();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(success ? Icons.check_circle : Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text(success ? 'Cập nhật cân nặng hàng ngày thành công' : 'Cập nhật cân nặng hàng ngày thất bại'),
              ],
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        if (success) {
          await _loadUserData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật cân nặng hàng ngày: $e'), backgroundColor: Colors.red),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_isProfileComplete()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vui lòng điền đầy đủ thông tin hồ sơ trước khi thoát'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Hồ sơ thể chất", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
            onPressed: () {
              if (_isProfileComplete()) {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => HomeScreen(),
                    transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
                    transitionDuration: Duration(milliseconds: 300),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Vui lòng điền đầy đủ thông tin hồ sơ trước khi thoát'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red),
              onPressed: _handleClearData,
              tooltip: 'Xóa dữ liệu',
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.red),
              onPressed: _handleLogout,
              tooltip: 'Đăng xuất',
            ),
          ],
        ),
        body: isLoading
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
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Icon(Icons.person, size: 50, color: Theme.of(context).primaryColor),
                      ),
                      SizedBox(height: 8),
                      _buildTextField(controllers['name']!, "Tên", Icons.person, readOnly: false),
                      SizedBox(height: 4),
                      Text(
                        email.isEmpty ? "Chưa có email" : email,
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 8),
                      _buildGenderSelector(),
                      SizedBox(height: 8),
                      _buildGoalSelector(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Chỉ số cơ thể", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMetricCard("BMI", bmi > 0 ? bmi.toStringAsFixed(1) : "—", bmi > 0 ? _getBmiStatus(bmi) : "Chưa có"),
                          _buildMetricCard("BMR", bmr > 0 ? "${bmr.toInt()} kcal" : "—", "Cơ bản"),
                          _buildMetricCard("TDEE", tdee > 0 ? "${tdee.toInt()} kcal" : "—", "Hàng ngày"),
                        ],
                      ),
                      SizedBox(height: 12),
                      bmi > 0 ? _buildBmiIndicator() : _buildNoBmiMessage(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Số đo cơ thể", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controllers['weight']!,
                              "Cân nặng (kg)",
                              Icons.monitor_weight,
                              readOnly: controllers['weight']!.text.isNotEmpty &&
                                  double.tryParse(controllers['weight']!.text) != null &&
                                  double.tryParse(controllers['weight']!.text)! > 0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              controllers['height']!,
                              "Chiều cao (cm)",
                              Icons.height,
                              readOnly: controllers['height']!.text.isNotEmpty &&
                                  double.tryParse(controllers['height']!.text) != null &&
                                  double.tryParse(controllers['height']!.text)! > 0 &&
                                  double.tryParse(controllers['height']!.text)! <= 300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controllers['age']!,
                              "Tuổi",
                              Icons.calendar_today,
                              readOnly: controllers['age']!.text.isNotEmpty &&
                                  int.tryParse(controllers['age']!.text) != null &&
                                  int.tryParse(controllers['age']!.text)! > 0 &&
                                  int.tryParse(controllers['age']!.text)! <= 150,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              controllers['firstWeight']!,
                              "Cân nặng ban đầu (kg)",
                              Icons.monitor_weight,
                              readOnly: controllers['firstWeight']!.text.isNotEmpty &&
                                  double.tryParse(controllers['firstWeight']!.text) != null &&
                                  double.tryParse(controllers['firstWeight']!.text)! > 0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _updateProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Cập nhật", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _handleUpdateWeightLostDaily,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Cập nhật cân nặng", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoBmiMessage() => Card(
    color: Colors.blue.shade50,
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.info, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(child: Text("Nhập cân nặng và chiều cao để tính BMI", style: TextStyle(color: Colors.blue.shade800))),
        ],
      ),
    ),
  );

  Widget _buildGenderSelector() => Container(
    padding: EdgeInsets.all(4),
    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGenderOption("Nam", Icons.male),
        SizedBox(width: 4),
        _buildGenderOption("Nữ", Icons.female),
      ],
    ),
  );

  Widget _buildGenderOption(String value, IconData icon) {
    bool isSelected = gender == value;
    return GestureDetector(
      onTap: () => setState(() => gender = value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey.shade600),
            SizedBox(width: 4),
            Text(value, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    const goals = ["Giảm cân", "Duy trì cân nặng", "Tăng cân"];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: goal,
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
        onChanged: (value) => setState(() => goal = value!),
        items: goals.map((value) => DropdownMenuItem(
          value: value,
          child: Row(
            children: [
              Icon(
                value == "Giảm cân" ? Icons.trending_down : value == "Tăng cân" ? Icons.trending_up : Icons.balance,
                color: Theme.of(context).primaryColor,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(value, style: TextStyle(fontSize: 14)),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String subtitle) {
    Color textColor = title == "BMI" && value != "—" ? _getMetricColor(title, double.tryParse(value) ?? 0) : Theme.of(context).primaryColor;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
            SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Color _getMetricColor(String metric, double value) {
    if (metric != "BMI") return Theme.of(context).primaryColor;
    if (value < 18.5) return Colors.blue;
    if (value < 25) return Colors.green;
    if (value < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiStatus(double bmi) {
    if (bmi < 18.5) return "Thiếu cân";
    if (bmi < 25) return "Bình thường";
    if (bmi < 30) return "Thừa cân";
    return "Béo phì";
  }

  Widget _buildBmiIndicator() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("BMI: ${bmi.toStringAsFixed(1)} - ${_getBmiStatus(bmi)}",
          style: TextStyle(fontWeight: FontWeight.bold, color: _getMetricColor("BMI", bmi))),
      SizedBox(height: 8),
      Container(
        height: 8,
        decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(flex: 185, child: Container(color: Colors.blue)),
                Expanded(flex: 165, child: Container(color: Colors.green)),
                Expanded(flex: 50, child: Container(color: Colors.orange)),
                Expanded(flex: 100, child: Container(color: Colors.red)),
              ],
            ),
            Positioned(
              left: math.min((bmi / 40) * MediaQuery.of(context).size.width * 0.8, MediaQuery.of(context).size.width * 0.8 - 12),
              child: Container(
                height: 12,
                width: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: _getMetricColor("BMI", bmi), width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Thiếu cân", style: TextStyle(fontSize: 10, color: Colors.blue)),
          Text("Bình thường", style: TextStyle(fontSize: 10, color: Colors.green)),
          Text("Thừa cân", style: TextStyle(fontSize: 10, color: Colors.orange)),
          Text("Béo phì", style: TextStyle(fontSize: 10, color: Colors.red)),
        ],
      ),
    ],
  );

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false}) => Card(
    child: TextField(
      controller: controller,
      keyboardType: label == "Tên" ? TextInputType.text : TextInputType.number,
      readOnly: readOnly,
      enabled: !readOnly,
      onTap: () {
        if (!readOnly && controller.text.isNotEmpty) {
          controller.clear();
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    ),
  );

  @override
  void dispose() {
    controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}