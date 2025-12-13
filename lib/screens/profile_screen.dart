import 'package:caloer_app/screens/login_screen.dart';
import 'package:caloer_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../service/user_service.dart';
import '../service/google_auth_service.dart';
import 'dart:math' as math;

class OptionItem {
  final String label;
  final String value;
  final String description;
  final String apiValue;

  const OptionItem({
    required this.label,
    required this.value,
    required this.description,
    String? apiValue,
  }) : apiValue = apiValue ?? value;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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

  // Controllers cho modal chuẩn đoán sức khỏe
  final Map<String, TextEditingController> healthControllers = {
    'Age': TextEditingController(),
    'Height': TextEditingController(),
    'Weight': TextEditingController(),
  };

  // Dropdown values cho modal chuẩn đoán
  String selectedGender = "";
  String selectedCAEC = "";
  String selectedCALC = "";
  String selectedFAVC = "";
  String selectedSCC = "";
  String selectedSMOKE = "";
  String selectedMTRANS = "";
  String selectedFamilyHistory = "";
  String selectedCH2O = "";
  String selectedFCVC = "";
  String selectedNCP = "";
  String selectedFAF = "";
  String selectedTUE = "";

  final List<OptionItem> _genderOptions = const [
    OptionItem(label: "Nam", value: "Male", description: "Giới tính nam"),
    OptionItem(label: "Nữ", value: "Female", description: "Giới tính nữ"),
  ];

  final List<OptionItem> _snackOptions = const [
    OptionItem(label: "Không ăn vặt", value: "snack_none", apiValue: "Sometimes", description: "Hiếm khi ăn giữa các bữa (API chỉ nhận từ 'Sometimes')"),
    OptionItem(label: "Thỉnh thoảng", value: "snack_sometimes", apiValue: "Sometimes", description: "Ăn vặt 1-2 lần/tuần"),
    OptionItem(label: "Thường xuyên", value: "snack_frequently", apiValue: "Frequently", description: "Ăn vặt gần như mỗi ngày"),
    OptionItem(label: "Luôn luôn", value: "snack_always", apiValue: "Always", description: "Luôn ăn thêm giữa các bữa"),
  ];

  final List<OptionItem> _alcoholOptions = const [
    OptionItem(label: "Không uống", value: "no", description: "Không sử dụng đồ uống có cồn"),
    OptionItem(label: "Thỉnh thoảng", value: "Sometimes", description: "Uống trong những dịp nhất định"),
    OptionItem(label: "Thường xuyên", value: "Frequently", apiValue: "Sometimes", description: "Uống nhiều lần trong tuần (API chỉ nhận 'Always', 'Sometimes' hoặc 'no')"),
    OptionItem(label: "Rất thường xuyên", value: "Always", description: "Sử dụng gần như mỗi ngày"),
  ];

  final List<OptionItem> _highCalorieOptions = const [
    OptionItem(label: "Ít/Không ăn", value: "no", description: "Hiếm khi dùng đồ ăn giàu calo"),
    OptionItem(label: "Có ăn thường xuyên", value: "yes", description: "Thường xuyên dùng đồ ăn nhiều calo"),
  ];

  final List<OptionItem> _monitorOptions = const [
    OptionItem(label: "Không theo dõi", value: "no", description: "Không ghi lại lượng calo hằng ngày"),
    OptionItem(label: "Có theo dõi", value: "yes", description: "Theo dõi calo nạp vào/tiêu hao"),
  ];

  final List<OptionItem> _smokeOptions = const [
    OptionItem(label: "Không hút thuốc", value: "no", description: "Không có thói quen hút thuốc"),
    OptionItem(label: "Có hút thuốc", value: "yes", description: "Đang hút hoặc đã từng hút"),
  ];

  final List<OptionItem> _transportOptions = const [
    OptionItem(label: "Phương tiện công cộng", value: "Public_Transportation", description: "Xe bus, tàu điện..."),
    OptionItem(label: "Đi bộ", value: "Walking", description: "Đi bộ là chính"),
    OptionItem(label: "Ô tô", value: "Automobile", description: "Tự lái hoặc đi nhờ ô tô"),
    OptionItem(label: "Xe máy", value: "Motorbike", description: "Di chuyển bằng xe máy"),
    OptionItem(label: "Xe đạp", value: "Bike", description: "Đạp xe là phương tiện chính"),
  ];

  final List<OptionItem> _familyHistoryOptions = const [
    OptionItem(label: "Không có", value: "no", description: "Gia đình không ai thừa cân/béo phì"),
    OptionItem(label: "Có", value: "yes", description: "Có người thân từng thừa cân/béo phì"),
  ];

  final List<OptionItem> _waterOptions = const [
    OptionItem(label: "≈1L/ngày", value: "1.0", description: "Uống ít nước (<1.5L/ngày)"),
    OptionItem(label: "≈2L/ngày", value: "2.0", description: "Mức khuyến nghị (1.5–2.5L/ngày)"),
    OptionItem(label: "≥3L/ngày", value: "3.0", description: "Uống nhiều nước (>2.5L/ngày)"),
  ];

  final List<OptionItem> _fcvcOptions = const [
    OptionItem(label: "Hiếm khi ăn rau", value: "1.0", description: "Ăn rau <1 lần/ngày"),
    OptionItem(label: "Thỉnh thoảng", value: "2.0", description: "Ăn rau 1–2 lần/ngày"),
    OptionItem(label: "Thường xuyên", value: "3.0", description: "Ăn rau trong hầu hết bữa ăn"),
  ];

  final List<OptionItem> _ncpOptions = const [
    OptionItem(label: "1 bữa chính/ngày", value: "1.0", description: "Thường bỏ bữa"),
    OptionItem(label: "2 bữa chính/ngày", value: "2.0", description: "Ăn 2 bữa (ví dụ: trưa & tối)"),
    OptionItem(label: "3 bữa chính/ngày", value: "3.0", description: "Ăn đủ 3 bữa (sáng/trưa/tối)"),
    OptionItem(label: "4 bữa chính/ngày", value: "4.0", description: "Chia nhỏ thành 4 bữa trở lên"),
  ];

  final List<OptionItem> _physicalActivityOptions = const [
    OptionItem(label: "Không tập", value: "0.0", description: "Hầu như không vận động"),
    OptionItem(label: "Thỉnh thoảng", value: "1.0", description: "Tập ≤2 lần/tuần"),
    OptionItem(label: "Thường xuyên", value: "2.0", description: "Tập 3-4 lần/tuần"),
    OptionItem(label: "Rất thường xuyên", value: "3.0", description: "Tập hầu như mỗi ngày"),
  ];

  final List<OptionItem> _screenTimeOptions = const [
    OptionItem(label: "< 2 giờ/ngày", value: "0.0", description: "Ít dùng thiết bị"),
    OptionItem(label: "2-4 giờ/ngày", value: "1.0", description: "Mức trung bình"),
    OptionItem(label: "> 4 giờ/ngày", value: "2.0", description: "Sử dụng nhiều thiết bị"),
  ];
  
  // Form key cho validation
  final GlobalKey<FormState> _healthFormKey = GlobalKey<FormState>();
  String email = "", gender = "Nam", goal = "Duy trì cân nặng", state = "", name = "";
  double bmr = 0, tdee = 0, bmi = 0, caloDeficit = 0, firstWeight = 0, dailyCalories = 0;
  String? createdate;
  bool isLoading = true;
  bool _isEditingProfile = false;
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
    _initializeHealthControllers();
  }

  void _initializeHealthControllers() {
    // Khởi tạo giá trị mặc định cho health controllers
    healthControllers.forEach((key, controller) {
      controller.addListener(() {
        if (controller.selection.baseOffset == 0 && controller.text.isNotEmpty) {
          controller.clear();
        }
      });
    });
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
        // Sử dụng GoogleAuthService thay vì tạo GoogleSignIn mới
        final googleAuthService = GoogleAuthService();
        await googleAuthService.signOut();
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

  void _showHealthDiagnosisModal() {
    // Điền dữ liệu từ profile nếu có
    _populateHealthDataFromProfile();
    _ensureHealthSelectionDefaults();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header với gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.health_and_safety, color: Colors.white, size: 28),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Chuẩn đoán sức khỏe", 
                                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text("Phân tích tình trạng sức khỏe hiện tại", 
                                 style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Form(
                      key: _healthFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thông tin cơ bản
                          _buildSectionTitle("Thông tin cơ bản", Icons.person),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: _buildHealthTextField(healthControllers['Age']!, "Tuổi", Icons.calendar_today, 
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Tuổi không được để trống';
                                    }
                                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                                      return 'Tuổi phải là số dương';
                                    }
                                    return null;
                                  })),
                              SizedBox(width: 16),
                              Expanded(child: _buildHealthTextField(healthControllers['Height']!, "Chiều cao (m)", Icons.height,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Chiều cao không được để trống';
                                    }
                                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                      return 'Chiều cao phải là số dương';
                                    }
                                    return null;
                                  })),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(child: _buildHealthTextField(healthControllers['Weight']!, "Cân nặng (kg)", Icons.monitor_weight,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Cân nặng không được để trống';
                                    }
                                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                                      return 'Cân nặng phải là số dương';
                                    }
                                    return null;
                                  })),
                              SizedBox(width: 16),
                              Expanded(child: _buildHealthDropdown("Giới tính", selectedGender, 
                                  _genderOptions, (value) {
                                setModalState(() => selectedGender = value ?? "");
                              }, validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng chọn giới tính';
                                }
                                return null;
                              })),
                            ],
                          ),
                          
                          SizedBox(height: 30),
                          
                          // Thông tin dinh dưỡng
                          _buildSectionTitle("Thông tin dinh dưỡng", Icons.restaurant),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Lượng nước uống (L/ngày)", selectedCH2O,
                              _waterOptions, (value) {
                            setModalState(() => selectedCH2O = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn lượng nước uống';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Tần suất ăn rau", selectedFCVC,
                              _fcvcOptions, (value) {
                            setModalState(() => selectedFCVC = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn tần suất ăn rau';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Số bữa ăn chính/ngày", selectedNCP,
                              _ncpOptions, (value) {
                            setModalState(() => selectedNCP = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn số bữa ăn chính';
                            }
                            return null;
                          }),
                          
                          SizedBox(height: 30),
                          
                          // Thông tin lối sống
                          _buildSectionTitle("Thông tin lối sống", Icons.fitness_center),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Tần suất hoạt động thể chất", selectedFAF,
                              _physicalActivityOptions, (value) {
                            setModalState(() => selectedFAF = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn tần suất hoạt động thể chất';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Thời gian sử dụng thiết bị", selectedTUE,
                              _screenTimeOptions, (value) {
                            setModalState(() => selectedTUE = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn thời gian sử dụng thiết bị';
                            }
                            return null;
                          }),
                          
                          SizedBox(height: 20),
                          
                          // Dropdowns
                          _buildHealthDropdown("Ăn giữa các bữa chính", selectedCAEC, 
                              _snackOptions, (value) {
                            setModalState(() => selectedCAEC = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn tần suất ăn giữa bữa';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Uống rượu", selectedCALC, 
                              _alcoholOptions, (value) {
                            setModalState(() => selectedCALC = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn tần suất uống rượu';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Ăn thức ăn nhiều calo", selectedFAVC, 
                              _highCalorieOptions, (value) {
                            setModalState(() => selectedFAVC = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn có ăn thức ăn nhiều calo không';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Theo dõi calo", selectedSCC, 
                              _monitorOptions, (value) {
                            setModalState(() => selectedSCC = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn có theo dõi calo không';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Hút thuốc", selectedSMOKE, 
                              _smokeOptions, (value) {
                            setModalState(() => selectedSMOKE = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn có hút thuốc không';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Phương tiện di chuyển", selectedMTRANS, 
                              _transportOptions, (value) {
                            setModalState(() => selectedMTRANS = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn phương tiện di chuyển';
                            }
                            return null;
                          }),
                          SizedBox(height: 20),
                          _buildHealthDropdown("Tiền sử gia đình thừa cân", selectedFamilyHistory, 
                              _familyHistoryOptions, (value) {
                            setModalState(() => selectedFamilyHistory = value ?? "");
                          }, validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng chọn có tiền sử gia đình thừa cân không';
                            }
                            return null;
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Actions
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: Colors.grey.shade400),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text("Hủy", style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (_healthFormKey.currentState!.validate()) {
                              _performHealthDiagnosis();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.analytics, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text("Chuẩn đoán", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue.shade600, size: 20),
        ),
        SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
      ],
    );
  }

  void _populateHealthDataFromProfile() {
    // Điền dữ liệu từ profile nếu có
    if (controllers['age']!.text.isNotEmpty) {
      healthControllers['Age']!.text = controllers['age']!.text;
    }
    if (controllers['height']!.text.isNotEmpty) {
      double heightCm = double.tryParse(controllers['height']!.text) ?? 0;
      healthControllers['Height']!.text = (heightCm / 100).toStringAsFixed(2);
    }
    if (controllers['weight']!.text.isNotEmpty) {
      healthControllers['Weight']!.text = controllers['weight']!.text;
    }
    
    // Set gender
    selectedGender = gender == "Nữ" ? "Female" : "Male";
  }

  void _ensureHealthSelectionDefaults() {
    if (selectedGender.isEmpty) {
      selectedGender = _genderOptions.first.value;
    }
    if (selectedCAEC.isEmpty) {
      selectedCAEC = _snackOptions.first.value;
    }
    if (selectedCALC.isEmpty) {
      selectedCALC = _alcoholOptions.first.value;
    }
    if (selectedFAVC.isEmpty) {
      selectedFAVC = _highCalorieOptions.first.value;
    }
    if (selectedSCC.isEmpty) {
      selectedSCC = _monitorOptions.first.value;
    }
    if (selectedSMOKE.isEmpty) {
      selectedSMOKE = _smokeOptions.first.value;
    }
    if (selectedMTRANS.isEmpty) {
      selectedMTRANS = _transportOptions.first.value;
    }
    if (selectedFamilyHistory.isEmpty) {
      selectedFamilyHistory = _familyHistoryOptions.first.value;
    }
    if (selectedCH2O.isEmpty) {
      selectedCH2O = _waterOptions[1].value;
    }
    if (selectedFCVC.isEmpty) {
      selectedFCVC = _fcvcOptions[1].value;
    }
    if (selectedNCP.isEmpty) {
      selectedNCP = _ncpOptions[2].value;
    }
    if (selectedFAF.isEmpty) {
      selectedFAF = _physicalActivityOptions[1].value;
    }
    if (selectedTUE.isEmpty) {
      selectedTUE = _screenTimeOptions[1].value;
    }
  }

  Widget _buildHealthTextField(TextEditingController controller, String label, IconData icon, {String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.blue.shade600),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  OptionItem _resolveOptionItem(String currentValue, List<OptionItem> options) {
    if (options.isEmpty) throw ArgumentError("Options cannot be empty");
    if (currentValue.isNotEmpty) {
      for (final item in options) {
        if (item.value == currentValue) {
          return item;
        }
      }
    }
    return options.first;
  }

  String _selectedOrDefault(String currentValue, List<OptionItem> options) {
    return _resolveOptionItem(currentValue, options).apiValue;
  }

  double _selectedValueAsDouble(String currentValue, List<OptionItem> options, double fallback) {
    final option = _resolveOptionItem(currentValue, options);
    return double.tryParse(option.apiValue) ?? fallback;
  }

  Widget _buildHealthDropdown(String label, String value, List<OptionItem> items, Function(String?) onChanged, {String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        initialValue: value.isEmpty ? null : value,
        validator: validator,
        isDense: false,
        itemHeight: null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        dropdownColor: Colors.white,
        style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
        isExpanded: true,
        items: items.map((item) => DropdownMenuItem(
          value: item.value,
          alignment: AlignmentDirectional.centerStart,
          child: Text.rich(
            TextSpan(
              text: item.label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade900),
              children: item.description.isNotEmpty
                  ? [
                      TextSpan(text: '\n'),
                      TextSpan(
                        text: item.description,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
                      ),
                    ]
                  : [],
            ),
          ),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _performHealthDiagnosis() async {
    Navigator.pop(context); // Đóng modal
    setState(() => isLoading = true);

    try {
      final requestData = {
        "Age": int.parse(healthControllers['Age']!.text),
        "CAEC": _selectedOrDefault(selectedCAEC, _snackOptions),
        "CALC": _selectedOrDefault(selectedCALC, _alcoholOptions),
        "CH2O": _selectedValueAsDouble(selectedCH2O, _waterOptions, 2.0),
        "FAF": _selectedValueAsDouble(selectedFAF, _physicalActivityOptions, 1.0),
        "FAVC": _selectedOrDefault(selectedFAVC, _highCalorieOptions),
        "FCVC": _selectedValueAsDouble(selectedFCVC, _fcvcOptions, 2.0),
        "Gender": _selectedOrDefault(selectedGender, _genderOptions),
        "Height": double.parse(healthControllers['Height']!.text),
        "MTRANS": _selectedOrDefault(selectedMTRANS, _transportOptions),
        "NCP": _selectedValueAsDouble(selectedNCP, _ncpOptions, 3.0),
        "SCC": _selectedOrDefault(selectedSCC, _monitorOptions),
        "SMOKE": _selectedOrDefault(selectedSMOKE, _smokeOptions),
        "TUE": _selectedValueAsDouble(selectedTUE, _screenTimeOptions, 1.0),
        "Weight": double.parse(healthControllers['Weight']!.text),
        "family_history_with_overweight": _selectedOrDefault(selectedFamilyHistory, _familyHistoryOptions),
      };

      final response = await _userService.performHealthDiagnosis(requestData);
      
      if (response != null) {
        _showDiagnosisResult(response);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi chuẩn đoán sức khỏe"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showDiagnosisResult(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header với gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.analytics, color: Colors.white, size: 28),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Kết quả chuẩn đoán", 
                               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text("Phân tích hoàn tất", 
                               style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    // BMI Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.speed, color: Colors.blue.shade600, size: 24),
                              SizedBox(width: 8),
                              Text("CHỈ SỐ BMI", 
                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                            ],
                          ),
                          SizedBox(height: 12),
                          Text("${result['bmi']?.toStringAsFixed(2) ?? 'N/A'}", 
                               style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getBMIColor(result['bmi']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text("${result['bmi_category'] ?? 'N/A'}", 
                                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Prediction Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade50, Colors.orange.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.trending_up, color: Colors.orange.shade600, size: 24),
                              SizedBox(width: 8),
                              Text("DỰ ĐOÁN TÌNH TRẠNG", 
                                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                            ],
                          ),
                          SizedBox(height: 12),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: _getPredictionColor(result['prediction']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_mapPredictionToVietnamese(result['prediction']), 
                                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20),
                    
                    // Description
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text("Dựa trên thông tin bạn cung cấp, đây là kết quả chuẩn đoán tình trạng sức khỏe của bạn.", 
                                 style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text("Đóng", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBMIColor(double? bmi) {
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getPredictionColor(String? prediction) {
    if (prediction == null) return Colors.grey;
    switch (prediction.toLowerCase()) {
      case 'normal_weight':
        return Colors.green;
      case 'overweight_level_i':
        return Colors.orange;
      case 'overweight_level_ii':
        return Colors.red;
      case 'obesity_type_i':
        return Colors.red.shade700;
      case 'obesity_type_ii':
        return Colors.red.shade800;
      case 'obesity_type_iii':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  String _mapPredictionToVietnamese(String? prediction) {
    if (prediction == null) return 'Không xác định';
    switch (prediction.toLowerCase()) {
      case 'normal_weight':
        return 'Cân nặng bình thường';
      case 'overweight_level_i':
        return 'Thừa cân cấp độ I';
      case 'overweight_level_ii':
        return 'Thừa cân cấp độ II';
      case 'obesity_type_i':
        return 'Béo phì loại I';
      case 'obesity_type_ii':
        return 'Béo phì loại II';
      case 'obesity_type_iii':
        return 'Béo phì loại III';
      default:
        return prediction;
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
              icon: Icon(Icons.health_and_safety, color: Colors.blue),
              onPressed: _showHealthDiagnosisModal,
              tooltip: 'Chuẩn đoán sức khỏe',
            ),
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
                      _buildTextField(
                        controllers['name']!, 
                        "Tên", 
                        Icons.person, 
                        readOnly: firstWeight > 0 && !_isEditingProfile,
                      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Số đo cơ thể", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          // Nút chỉnh sửa thể trạng
                          if (firstWeight > 0)
                            TextButton.icon(
                              onPressed: () async {
                                if (_isEditingProfile) {
                                  // Validate và lưu tất cả các trường
                                  if (!_isProfileComplete()) {
                                    return; // _isProfileComplete đã hiển thị lỗi
                                  }
                                  
                                  setState(() {
                                    isLoading = true;
                                  });
                                  
                                  try {
                                    final userData = <String, dynamic>{};
                                    
                                    // Thu thập tất cả dữ liệu từ controllers
                                    if (controllers['name']!.text.isNotEmpty) {
                                      userData['name'] = controllers['name']!.text;
                                    }
                                    if (controllers['weight']!.text.isNotEmpty) {
                                      userData['weight'] = double.tryParse(controllers['weight']!.text);
                                    }
                                    if (controllers['height']!.text.isNotEmpty) {
                                      userData['height'] = double.tryParse(controllers['height']!.text);
                                    }
                                    if (controllers['age']!.text.isNotEmpty) {
                                      userData['age'] = int.tryParse(controllers['age']!.text);
                                    }
                                    if (controllers['firstWeight']!.text.isNotEmpty) {
                                      userData['firstWeight'] = double.tryParse(controllers['firstWeight']!.text);
                                    }
                                    if (controllers['waist']!.text.isNotEmpty) {
                                      userData['waist'] = double.tryParse(controllers['waist']!.text);
                                    }
                                    if (controllers['hip']!.text.isNotEmpty) {
                                      userData['hip'] = double.tryParse(controllers['hip']!.text);
                                    }
                                    if (controllers['biceps']!.text.isNotEmpty) {
                                      userData['biceps'] = double.tryParse(controllers['biceps']!.text);
                                    }
                                    if (controllers['thigh']!.text.isNotEmpty) {
                                      userData['thigh'] = double.tryParse(controllers['thigh']!.text);
                                    }
                                    
                                    if (gender.isNotEmpty) {
                                      userData['gender'] = gender == "Nữ" ? "Nu" : "Nam";
                                    }
                                    
                                    userData['goal'] = {
                                      'Duy trì cân nặng': 'MAINTAIN_WEIGHT',
                                      'Giảm cân': 'LOSE_WEIGHT',
                                      'Tăng cân': 'GAIN_WEIGHT'
                                    }[goal] ?? 'MAINTAIN_WEIGHT';
                                    
                                    bool success = await _userService.updateUserData(userData);
                                    
                                    if (success) {
                                      await _loadUserData();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Cập nhật thể trạng thành công'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Cập nhật thể trạng thất bại'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Lỗi: $e'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isLoading = false;
                                      _isEditingProfile = false;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _isEditingProfile = true;
                                  });
                                }
                              },
                              icon: Icon(
                                _isEditingProfile ? Icons.check : Icons.edit,
                                size: 18,
                                color: Theme.of(context).primaryColor,
                              ),
                              label: Text(
                                _isEditingProfile ? "Lưu" : "Chỉnh sửa thể trạng",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controllers['weight']!,
                              "Cân nặng (kg)",
                              Icons.monitor_weight,
                              readOnly: !_isEditingProfile && controllers['weight']!.text.isNotEmpty &&
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
                              readOnly: !_isEditingProfile && controllers['height']!.text.isNotEmpty &&
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
                              readOnly: !_isEditingProfile && controllers['age']!.text.isNotEmpty &&
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
                              readOnly: !_isEditingProfile && controllers['firstWeight']!.text.isNotEmpty &&
                                  double.tryParse(controllers['firstWeight']!.text) != null &&
                                  double.tryParse(controllers['firstWeight']!.text)! > 0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      // Thêm các trường số đo cơ thể
                      Text("Số đo chi tiết", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controllers['waist']!,
                              "Vòng eo (cm)",
                              Icons.straighten,
                              readOnly: !_isEditingProfile && controllers['waist']!.text.isNotEmpty &&
                                  double.tryParse(controllers['waist']!.text) != null &&
                                  double.tryParse(controllers['waist']!.text)! > 0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              controllers['hip']!,
                              "Vòng mông (cm)",
                              Icons.straighten,
                              readOnly: !_isEditingProfile && controllers['hip']!.text.isNotEmpty &&
                                  double.tryParse(controllers['hip']!.text) != null &&
                                  double.tryParse(controllers['hip']!.text)! > 0,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controllers['biceps']!,
                              "Vòng tay (cm)",
                              Icons.straighten,
                              readOnly: !_isEditingProfile && controllers['biceps']!.text.isNotEmpty &&
                                  double.tryParse(controllers['biceps']!.text) != null &&
                                  double.tryParse(controllers['biceps']!.text)! > 0,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildTextField(
                              controllers['thigh']!,
                              "Vòng đùi (cm)",
                              Icons.straighten,
                              readOnly: !_isEditingProfile && controllers['thigh']!.text.isNotEmpty &&
                                  double.tryParse(controllers['thigh']!.text) != null &&
                                  double.tryParse(controllers['thigh']!.text)! > 0,
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
        bottomNavigationBar: firstWeight > 0
            ? null // Đã có cân nặng ban đầu, sử dụng nút chỉnh sửa ở trên
            : Padding(
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _updateProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text("Lưu hồ sơ thể trạng", style: TextStyle(fontSize: 16, color: Colors.white)),
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
      onTap: _isEditingProfile ? () => setState(() => gender = value) : null,
      child: Opacity(
        opacity: _isEditingProfile ? 1.0 : 0.6,
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
        onChanged: _isEditingProfile ? (value) => setState(() => goal = value!) : null,
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
    healthControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}