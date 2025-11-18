import 'package:caloer_app/screens/profile_screen.dart';
import 'package:caloer_app/screens/statistic_screen.dart';
import 'package:caloer_app/screens/step_counter_screen.dart';
import 'package:caloer_app/service/user_service.dart';
import 'package:caloer_app/service/step_service.dart';
import 'package:flutter/material.dart';
import '../service/food_service.dart';
import 'h20.dart';
import 'schedule_meal_screen.dart';
import 'ghichu.dart';
import 'luyentap.dart';
import 'chat_screen.dart';
import 'package:caloer_app/service/SplashScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Color(0xFF4CAF50),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF4CAF50),
        secondary: Color(0xFF8BC34A),
      ),
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: Colors.grey[50],
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
    ),
    home: SplashScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FoodService _foodService = FoodService();
  final UserService _userService = UserService();
  final StepService _stepService = StepService();
  bool _isLoading = false;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  int _selectedIndex = 0;

  // Placeholder data
  String _caloriesNeeded = "1643";
  String _caloriesRemaining = "1643";
  String _caloriesConsumed = "0";
  String _caloriesBurned = "0";
  String _carbs = "0/246g";
  String _protein = "0/82g";
  String _fat = "0/37g";
  String _fiber = "0/25g";
  List<FoodHistoryItem> _foodHistory = [];
  double _weightLost = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchMealLogs();
    _fetchStepsData();
    _fetchWeightLost();
  }

  void _fetchMealLogs() async {
    try {
      setState(() => _isLoading = true);
      final userInfo = await _userService.fetchUserData();
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
      final mealLogsData = await _foodService.fetchMealLogs(formattedDate);

      double TDEE = (userInfo?['tdee'] as num?)?.toDouble() ?? 2000.0;
      double totalDailyCalories = (mealLogsData['result']['totalDailyCalories'] as num?)?.toDouble() ?? 0.0;
      double remainingCalories = TDEE - totalDailyCalories;

      List<FoodHistoryItem> foodHistoryItems = [];
      if (mealLogsData['result']['mealLogs'] != null) {
        for (var mealLog in mealLogsData['result']['mealLogs']) {
          String mealType = mealLog['mealType'] ?? '';
          String mealTypeName = {
            'BREAKFAST': 'Bữa sáng',
            'LUNCH': 'Bữa trưa',
            'DINNER': 'Bữa tối',
            'SNACK': 'Bữa phụ',
          }[mealType] ?? mealType;

          var food = mealLog['food'];
          if (food != null) {
            int weightInGrams = (mealLog['weightInGrams'] as num?)?.toInt() ?? 100;
            
            String servingSizeStr = food['servingSize']?.toString() ?? '100g';
            double servingSizeGrams = double.tryParse(servingSizeStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 100.0;
            
            double ratio = weightInGrams / servingSizeGrams;
            
            double baseCalories = (food['calories'] as num?)?.toDouble() ?? 0.0;
            double baseProtein = (food['protein'] as num?)?.toDouble() ?? 0.0;
            double baseCarbs = (food['carbs'] as num?)?.toDouble() ?? 0.0;
            double baseFat = (food['fat'] as num?)?.toDouble() ?? 0.0;
            
            foodHistoryItems.add(FoodHistoryItem(
              id: (mealLog['id'] ?? '').toString(),
              foodId: (food['id'] ?? '').toString(),
              name: food['name'] ?? 'Không có tên',
              calories: baseCalories * ratio,
              mealType: mealTypeName,
              carbs: baseCarbs * ratio,
              protein: baseProtein * ratio,
              fat: baseFat * ratio,
              servingSize: '${weightInGrams}g',
            ));
          }
        }
      }

      setState(() {
        _caloriesConsumed = totalDailyCalories.toStringAsFixed(0);
        _caloriesNeeded = TDEE.toStringAsFixed(0);
        _caloriesRemaining = remainingCalories.toStringAsFixed(0);
        _foodHistory = foodHistoryItems;

        double totalCarbs = foodHistoryItems.fold(0, (sum, item) => sum + item.carbs);
        double totalProtein = foodHistoryItems.fold(0, (sum, item) => sum + item.protein);
        double totalFat = foodHistoryItems.fold(0, (sum, item) => sum + item.fat);

        _carbs = "${totalCarbs.toStringAsFixed(1)}/246g";
        _protein = "${totalProtein.toStringAsFixed(1)}/82g";
        _fat = "${totalFat.toStringAsFixed(1)}/37g";
        _fiber = "0/25g";
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching meal logs: $e");
      setState(() {
        _foodHistory = [];
        _isLoading = false;
      });
    }
  }

  void _fetchStepsData() async {
    try {
      setState(() => _isLoading = true);
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
      final stepData = await _stepService.fetchSteps(formattedDate);
      setState(() {
        _caloriesBurned = (stepData['calories'] as num?)?.toStringAsFixed(0) ?? "0";
        double TDEE = double.parse(_caloriesNeeded);
        double consumed = double.parse(_caloriesConsumed);
        _caloriesRemaining = (TDEE - consumed - double.parse(_caloriesBurned)).toStringAsFixed(0);
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error fetching steps data: $e");
      setState(() {
        _caloriesBurned = "0";
        _isLoading = false;
      });
    }
  }

  void _fetchWeightLost() async {
    try {
      setState(() => _isLoading = true);
      final weightLostData = await _userService.getWeightLost();
      if (weightLostData != null && weightLostData['WeightLost'] != null) {
        setState(() {
          _weightLost = (weightLostData['WeightLost'] as num).toDouble();
          _isLoading = false;
        });
      } else {
        setState(() {
          _weightLost = 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error fetching weight lost: $e");
      setState(() {
        _weightLost = 0.0;
        _isLoading = false;
      });
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _fetchMealLogs();
    _fetchStepsData();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    final screens = [
      HomeScreen(),
      ChatScreen(),
      TapLuyenScreen(),
      ProfileScreen(),
      StatisticsScreen(),
    ];
    Navigator.push(context, MaterialPageRoute(builder: (_) => screens[index]));
  }

  void _navigateToMealScreen(String mealType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScheduleMealsScreen(mealType: mealType, selectedDate: _selectedDay),
      ),
    ).then((_) => _fetchMealLogs());
  }

  void _showMealSuggestions() async {
    try {
      setState(() => _isLoading = true);
      final suggestions = await _foodService.fetchMealSuggestions();

      Map<String, List<Map<String, dynamic>>> groupedSuggestions = {
        'Bữa sáng': [],
        'Bữa trưa': [],
        'Bữa tối': [],
        'Bữa phụ': [],
      };

      for (var suggestion in suggestions) {
        String mealType = suggestion['mealType'] ?? '';
        String mealTypeName = {
          'BREAKFAST': 'Bữa sáng',
          'LUNCH': 'Bữa trưa',
          'DINNER': 'Bữa tối',
          'SNACK': 'Bữa phụ',
        }[mealType] ?? mealType;
        groupedSuggestions[mealTypeName]!.add(suggestion);
      }

      setState(() => _isLoading = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.restaurant_menu, color: Theme.of(context).primaryColor),
              SizedBox(width: 8),
              Text('Gợi ý bữa ăn'),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            height: 400,
            child: DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(text: 'Sáng'),
                      Tab(text: 'Trưa'),
                      Tab(text: 'Tối'),
                      Tab(text: 'Phụ'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSuggestionList(groupedSuggestions['Bữa sáng']!),
                        _buildSuggestionList(groupedSuggestions['Bữa trưa']!),
                        _buildSuggestionList(groupedSuggestions['Bữa tối']!),
                        _buildSuggestionList(groupedSuggestions['Bữa phụ']!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải gợi ý bữa ăn'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildSuggestionList(List<Map<String, dynamic>> suggestions) {
    if (suggestions.isEmpty) {
      return Center(child: Text('Chưa có gợi ý', style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final food = suggestion['food'];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(food['name'] ?? 'Không có tên'),
            subtitle: Text(
              'Calo: ${suggestion['totalCalories'].toStringAsFixed(1)} kcal | ${suggestion['weightInGrams'].toStringAsFixed(0)}g',
            ),
            trailing: IconButton(
              icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
              onPressed: () => _addSuggestedMeal(suggestion),
            ),
          ),
        );
      },
    );
  }

  void _addSuggestedMeal(Map<String, dynamic> suggestion) async {
    try {
      setState(() => _isLoading = true);
      final food = suggestion['food'];
      final double enteredAmount = (suggestion['weightInGrams'] as num?)?.toDouble() ?? 0.0;
      final String suggestionMealType = suggestion['mealType'] ?? '';

      if (enteredAmount <= 0) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Số lượng không hợp lệ"), backgroundColor: Colors.red),
        );
        return;
      }

      if (food['id'] == null || food['id'] is! num) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ID món ăn không hợp lệ"), backgroundColor: Colors.red),
        );
        return;
      }

      final Map<String, String> mealTypeToEnum = {
        'Bữa sáng': 'BREAKFAST',
        'Bữa trưa': 'LUNCH',
        'Bữa tối': 'DINNER',
        'Bữa phụ': 'SNACK',
      };
      String apiMealType = mealTypeToEnum[suggestionMealType] ?? suggestionMealType;

      if (!['BREAKFAST', 'LUNCH', 'DINNER', 'SNACK'].contains(apiMealType)) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Loại bữa ăn không hợp lệ: $suggestionMealType"), backgroundColor: Colors.red),
        );
        return;
      }

      Map<String, dynamic> requestData = {
        "mealType": apiMealType,
        "date": DateFormat('yyyy-MM-dd').format(_selectedDay),
        "foodId": (food['id'] as num).toInt(),
        "weightInGrams": enteredAmount.toInt(),
      };

      print("🔵 Request gửi lên API: $requestData");

      final response = await _foodService.addFoodToMeal(requestData);
      print("🟢 Phản hồi từ API: $response");

      if (response['code'] == 200) {
        print("✅ Đã thêm món ăn: ${food['name']}, Food ID: ${requestData['foodId']}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Đã thêm ${food['name']} vào $suggestionMealType"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _fetchMealLogs();
        print("🔍 FoodHistory sau khi thêm:");
        _foodHistory.forEach((item) {
          print("✅ FoodHistoryItem: ${item.name}, Food ID: ${item.foodId}, Meal Type: ${item.mealType}");
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Lỗi từ API: ${response['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print("🔴 Lỗi API: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi kết nối API: $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: _onDaySelected,
                      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.3), shape: BoxShape.circle),
                        selectedDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.volume_up, color: Colors.orange, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _weightLost >= 0
                                      ? 'Bạn đã tăng ${_weightLost.toStringAsFixed(1)} kg, hãy kiểm soát lại lượng ăn uống'
                                      : 'Bạn đã giảm ${(-_weightLost).toStringAsFixed(1)} kg! Cố lên!',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: [Colors.green.shade100, Colors.white]),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset('assets/apple.png', fit: BoxFit.cover, errorBuilder: (_, __, ___) => SizedBox()),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(_caloriesConsumed, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                                        Text('Đã nạp', style: TextStyle(fontSize: 12, color: Colors.black54)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStat('Cần nạp', '$_caloriesNeeded kcal', Colors.green),
                                    _buildStat(
                                      double.parse(_caloriesRemaining) >= 0 ? 'Còn lại' : 'Đã dư',
                                      '${double.parse(_caloriesRemaining).abs().toStringAsFixed(0)} kcal',
                                      double.parse(_caloriesRemaining) >= 0 ? Colors.red : Colors.redAccent,
                                    ),
                                    _buildStat('Tiêu hao', '$_caloriesBurned kcal', Colors.orange),
                                    SizedBox(height: 8),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        _buildMacro('Carbs', _carbs.split('/')[0], Colors.blue.shade100),
                                        _buildMacro('Đạm', _protein.split('/')[0], Colors.pink.shade100),
                                        _buildMacro('Béo', _fat.split('/')[0], Colors.orange.shade100),
                                        _buildMacro('Xơ', '0g', Colors.green.shade100),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 2,
                    runSpacing: 2,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildMealButton('Bữa sáng', Icons.breakfast_dining, Color(0xFF42A5F5), () => _navigateToMealScreen('BREAKFAST')),
                      _buildMealButton('Bữa trưa', Icons.lunch_dining, Color(0xFFEC407A), () => _navigateToMealScreen('LUNCH')),
                      _buildMealButton('Bữa tối', Icons.dinner_dining, Color(0xFFFFA726), () => _navigateToMealScreen('DINNER')),
                      _buildMealButton('Bữa phụ', Icons.fastfood, Color(0xFF66BB6A), () => _navigateToMealScreen('SNACK')),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Lịch sử ăn uống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(DateFormat('dd/MM/yyyy').format(_selectedDay), style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: _foodHistory.isEmpty
                        ? Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('Chưa có dữ liệu', style: TextStyle(color: Colors.grey))),
                      ),
                    )
                        : ListView.builder(
                      physics: ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _foodHistory.length,
                      itemBuilder: (_, index) => _buildFoodHistoryItem(_foodHistory[index]),
                    ),
                  ),
                  SizedBox(height: 12),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildUtilityButton('Uống nước', Icons.water, Color(0xFFFFB74D), () => Navigator.push(context, MaterialPageRoute(builder: (_) => H20Screen()))),
                      _buildUtilityButton('Ghi chú', Icons.note_alt, Color(0xFFFFB74D), () => Navigator.push(context, MaterialPageRoute(builder: (_) => GhiChuScreen()))),
                      _buildUtilityButton('Gợi ý bữa ăn', Icons.restaurant_menu, Color(0xFF7B1FA2), () => _showMealSuggestions()),
                      _buildUtilityButton('Bước đi', Icons.directions_walk, Color(0xFF4DB6AC), () => Navigator.push(context, MaterialPageRoute(builder: (_) => StepCounterScreen()))),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Theme.of(context).primaryColor,
              unselectedItemColor: Colors.grey,
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
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(fontSize: 14, color: color.withOpacity(0.9))),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildMacro(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text('$label: $value', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildMealButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Container(
          width: 80,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodHistoryItem(FoodHistoryItem item) {
    final mealTypeColors = {
      'Bữa sáng': Color(0xFF42A5F5),
      'Bữa trưa': Color(0xFFEC407A),
      'Bữa tối': Color(0xFFFFA726),
      'Bữa phụ': Color(0xFF66BB6A),
    };
    final mealColor = mealTypeColors[item.mealType] ?? Colors.grey;

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(color: mealColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(
                {
                  'Bữa sáng': Icons.breakfast_dining,
                  'Bữa trưa': Icons.lunch_dining,
                  'Bữa tối': Icons.dinner_dining,
                  'Bữa phụ': Icons.fastfood,
                }[item.mealType] ?? Icons.fastfood,
                color: mealColor,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _showEditWeightDialog(item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                    Text('${item.mealType} (${item.servingSize})', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        _buildMacroIndicator('C', '${item.carbs.toStringAsFixed(1)}g', Colors.blue),
                        SizedBox(width: 8),
                        _buildMacroIndicator('P', '${item.protein.toStringAsFixed(1)}g', Colors.pink),
                        SizedBox(width: 8),
                        _buildMacroIndicator('F', '${item.fat.toStringAsFixed(1)}g', Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(12)),
              child: Text('${item.calories.toStringAsFixed(0)} kcal', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showDeleteConfirmDialog(item),
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.delete, color: Colors.red, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroIndicator(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
          child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
        ),
        SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildUtilityButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: 80,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                SizedBox(height: 4),
                Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(FoodHistoryItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Xóa món ăn'),
        content: Text('Bạn có chắc muốn xóa ${item.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () {
              _deleteFoodItem(item);
              Navigator.pop(context);
            },
            child: Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteFoodItem(FoodHistoryItem item) async {
    try {
      setState(() => _isLoading = true);
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
      bool success = await _foodService.deleteMealLog(int.parse(item.id), formattedDate);
      if (success) {
        setState(() {
          _foodHistory.removeWhere((foodItem) => foodItem.id == item.id);
          _isLoading = false;
        });
        _recalculateTotals();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã xóa ${item.name}'), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Error deleting food item: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể xóa món ăn'), backgroundColor: Colors.red));
    }
  }

  void _showEditWeightDialog(FoodHistoryItem item) {
    final controller = TextEditingController(text: item.servingSize.replaceAll('g', ''));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Chỉnh sửa khối lượng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Khối lượng hiện tại: ${item.servingSize}', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Khối lượng mới (g)',
                border: OutlineInputBorder(),
                suffixText: 'g',
                fillColor: Colors.grey.shade100,
                filled: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              _updateFoodWeight(item, controller.text);
              Navigator.pop(context);
            },
            child: Text('Cập nhật'),
          ),
        ],
      ),
    );
  }

  void _updateFoodWeight(FoodHistoryItem item, String newWeightText) async {
    try {
      setState(() => _isLoading = true);
      double newWeight = double.parse(newWeightText);
      if (newWeight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Khối lượng phải lớn hơn 0g'), backgroundColor: Colors.red));
        setState(() => _isLoading = false);
        return;
      }
      String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDay);
      await _foodService.updateMealLogWeight(int.parse(item.id), formattedDate, int.parse(item.id), newWeight.toInt());
      double oldWeight = double.parse(item.servingSize.replaceAll('g', ''));
      double ratio = newWeight / oldWeight;
      int index = _foodHistory.indexWhere((foodItem) => foodItem.id == item.id);
      if (index != -1) {
        setState(() {
          _foodHistory[index] = FoodHistoryItem(
            id: item.id,
            foodId: item.foodId,
            name: item.name,
            calories: item.calories * ratio,
            mealType: item.mealType,
            carbs: item.carbs * ratio,
            protein: item.protein * ratio,
            fat: item.fat * ratio,
            servingSize: '${newWeight.toStringAsFixed(0)}g',
          );
          _isLoading = false;
        });
        _recalculateTotals();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã cập nhật ${item.name}'), backgroundColor: Colors.green));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print("❌ Error updating food weight: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể cập nhật'), backgroundColor: Colors.red));
    }
  }

  void _recalculateTotals() {
    double totalCalories = _foodHistory.fold(0, (sum, item) => sum + item.calories);
    double totalCarbs = _foodHistory.fold(0, (sum, item) => sum + item.carbs);
    double totalProtein = _foodHistory.fold(0, (sum, item) => sum + item.protein);
    double totalFat = _foodHistory.fold(0, (sum, item) => sum + item.fat);
    double TDEE = double.parse(_caloriesNeeded);
    double caloriesBurned = double.parse(_caloriesBurned);
    setState(() {
      _caloriesConsumed = totalCalories.toStringAsFixed(0);
      _caloriesRemaining = (TDEE - totalCalories - caloriesBurned).toStringAsFixed(0);
      _carbs = "${totalCarbs.toStringAsFixed(1)}/246g";
      _protein = "${totalProtein.toStringAsFixed(1)}/82g";
      _fat = "${totalFat.toStringAsFixed(1)}/37g";
    });
  }
}

class FoodHistoryItem {
  final String id, foodId, name, mealType, servingSize;
  final double calories, carbs, protein, fat;

  FoodHistoryItem({
    this.id = '',
    this.foodId = '',
    required this.name,
    required this.calories,
    required this.mealType,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.servingSize,
  });
}