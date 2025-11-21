import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../service/food_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final int foodId;
  final DateTime selectedDate;
  final String mealType;
  final Map<String, dynamic>? foodData; // Thêm field để truyền data từ predict

  FoodDetailScreen({
    required this.foodId,
    required this.selectedDate,
    required this.mealType,
    this.foodData, // Optional - nếu có thì dùng data này thay vì gọi API
  });

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final FoodService foodService = FoodService();
  final TextEditingController _amountController = TextEditingController();
  final String _selectedMeal = 'Bữa sáng'; // Default selected meal
  
  // Thêm state để lưu trữ dữ liệu dinh dưỡng gốc
  Map<String, dynamic>? _foodData;
  double _originalCalories = 0.0;
  double _originalProtein = 0.0;
  double _originalCarbs = 0.0;
  double _originalFat = 0.0;
  double _originalServingAmount = 100.0;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = '100'; // Default serving amount
    _amountController.addListener(_onAmountChanged); // Thêm listener
    _loadFoodData(); // Load data một lần duy nhất
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Method để load data food - từ predict hoặc từ API
  Future<void> _loadFoodData() async {
    try {
      // Nếu có data từ predict API, sử dụng luôn
      if (widget.foodData != null) {
        _foodData = widget.foodData!;
      } else {
        // Nếu không có, gọi API để lấy data từ database
        _foodData = await foodService.fetchFoodDetail(widget.foodId);
      }
      
      // Lưu trữ dữ liệu gốc
      _originalCalories = (_foodData!['calories'] ?? 0.0) is num ? (_foodData!['calories'] as num).toDouble() : 0.0;
      _originalProtein = (_foodData!['protein'] ?? 0.0) is num ? (_foodData!['protein'] as num).toDouble() : 0.0;
      _originalCarbs = (_foodData!['carbs'] ?? 0.0) is num ? (_foodData!['carbs'] as num).toDouble() : 0.0;
      _originalFat = (_foodData!['fat'] ?? 0.0) is num ? (_foodData!['fat'] as num).toDouble() : 0.0;
      _originalServingAmount = (_foodData!['servingAmount'] ?? 100.0) is num ? (_foodData!['servingAmount'] as num).toDouble() : 100.0;
      
      setState(() {
        _isDataLoaded = true;
      });
    } catch (e) {
      print("Lỗi load food data: $e");
    }
  }

  // Method để xử lý thay đổi số gram
  void _onAmountChanged() {
    setState(() {
      // UI sẽ được cập nhật tự động khi setState được gọi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isDataLoaded ? _buildContent() : Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildContent() {
    if (_foodData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              "Lỗi khi tải dữ liệu",
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
          ],
        ),
      );
    }

    // Lấy số gram hiện tại từ TextField
    double currentAmount = double.tryParse(_amountController.text) ?? 100.0;
    
    // Tính toán lại các giá trị dinh dưỡng dựa trên số gram hiện tại
    final double calories = _calculateValue(_originalCalories, _originalServingAmount, currentAmount);
    final double protein = _calculateValue(_originalProtein, _originalServingAmount, currentAmount);
    final double carbs = _calculateValue(_originalCarbs, _originalServingAmount, currentAmount);
    final double fat = _calculateValue(_originalFat, _originalServingAmount, currentAmount);
    final double servingAmount = currentAmount; // Sử dụng số gram hiện tại

            Color headerColor = Colors.primaries[widget.foodId % Colors.primaries.length].shade50;
            Color accentColor = Colors.primaries[widget.foodId % Colors.primaries.length];

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFFFCE4EC), // Light pink color from the screenshot
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _foodData!['name'] ?? 'Unknown Food',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    background: (_foodData!['image_url'] != null && 
                                  _foodData!['image_url'].toString().isNotEmpty)
                        ? Image.network(
                            _foodData!['image_url'].toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback nếu lỗi load ảnh
                              return Container(
                                color: const Color(0xFFFCE4EC),
                                child: Center(
                                  child: Icon(
                                    Icons.local_dining,
                                    size: 80,
                                    color: const Color(0xFFE91E63),
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: const Color(0xFFFCE4EC),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFFE91E63),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFFCE4EC),
                            child: Center(
                              child: Icon(
                                Icons.local_dining,
                                size: 80,
                                color: const Color(0xFFE91E63),
                              ),
                            ),
                          ),
                  ),
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border, color: Colors.red),
                      ),
                      onPressed: () {
                        // Add to favorites
                      },
                    ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nutritional Info Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            children: [
                              _buildNutrientCard('Protein', '${protein}g', Colors.blue),
                              SizedBox(width: 8),
                              _buildNutrientCard('Carbs', '${carbs}g', Colors.green),
                              SizedBox(width: 8),
                              _buildNutrientCard('Fat', '${fat}g', Colors.orange),
                            ],
                          ),
                        ),

                        // Serving Info
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Thông tin phần ăn",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoRow(Icons.rice_bowl, "Khẩu phần", "${servingAmount}g"),
                                    ),
                                    Expanded(
                                      child: _buildInfoRow(Icons.local_fire_department, "Calo", "$calories kcal"),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Divider(),
                                SizedBox(height: 8),
                                Text(
                                  "Dinh dưỡng trên mỗi phần ăn",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 12),
                                _buildNutrientRow("Protein", "${protein}g"),
                                SizedBox(height: 8),
                                _buildNutrientProgressBar(protein / 100, Colors.blue),
                                SizedBox(height: 16),
                                _buildNutrientRow("Carbohydrates", "${carbs}g"),
                                SizedBox(height: 8),
                                _buildNutrientProgressBar(carbs / 100, Colors.green),
                                SizedBox(height: 16),
                                _buildNutrientRow("Fat", "${fat}g"),
                                SizedBox(height: 8),
                                _buildNutrientProgressBar(fat / 100, Colors.orange),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Modified section for entering actual amount (without meal selection)
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Thêm vào bữa ăn",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),

                                // Amount input field
                                TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                  ],
                                  decoration: InputDecoration(
                                    labelText: "Số gram thực tế",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    suffixText: "g",
                                    hintText: "Nhập số gram (ví dụ: 200)",
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Calculated nutrition based on entered amount
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Giá trị dinh dưỡng với lượng đã nhập:",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildNutrientInfo("Calo", "${_calculateValue(_originalCalories, _originalServingAmount, currentAmount)} kcal"),
                                          _buildNutrientInfo("Protein", "${_calculateValue(_originalProtein, _originalServingAmount, currentAmount)}g"),
                                          _buildNutrientInfo("Carbs", "${_calculateValue(_originalCarbs, _originalServingAmount, currentAmount)}g"),
                                          _buildNutrientInfo("Fat", "${_calculateValue(_originalFat, _originalServingAmount, currentAmount)}g"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 16),

                                // Add button
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    icon: Icon(Icons.add_circle_outline, color: Colors.white),
                                    label: Text(
                                      "Thêm vào bữa ăn",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 15),
                                    ),
                                    onPressed: () {
                                      // Lấy giá trị từ TextField và parse
                                      // Loại bỏ tất cả ký tự không phải số và dấu chấm
                                      String amountText = _amountController.text.trim().replaceAll(RegExp(r'[^0-9.]'), '');
                                      print("🔵 TextField value (raw): '${_amountController.text}'");
                                      print("🔵 TextField value (cleaned): '$amountText'");
                                      
                                      double enteredAmount = double.tryParse(amountText) ?? 0.0;
                                      print("🔵 Parsed enteredAmount: $enteredAmount");

                                      if (enteredAmount <= 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Vui lòng nhập số lượng hợp lệ")),
                                        );
                                        return;
                                      }

                                      // Helper function để parse số an toàn
                                      double safeParseDouble(dynamic value, double defaultValue) {
                                        if (value == null) return defaultValue;
                                        if (value is num) return value.toDouble();
                                        if (value is String) {
                                          final parsed = double.tryParse(value);
                                          return parsed ?? defaultValue;
                                        }
                                        return defaultValue;
                                      }

                                      // Map dữ liệu từ _foodData vào request body
                                      // Ưu tiên calories_per_100g nếu có (từ predict API), nếu không thì dùng calories
                                      double foodCalories = safeParseDouble(
                                        _foodData!['calories_per_100g'] ?? _foodData!['calories'], 
                                        0.0
                                      );

                                      // Tạo JSON data để gửi lên API với đầy đủ thông tin
                                      int weightInGrams = enteredAmount.toInt();
                                      print("🔵 weightInGrams sẽ gửi: $weightInGrams");
                                      
                                      Map<String, dynamic> requestData = {
                                        "mealType": widget.mealType,
                                        "date": widget.selectedDate.toIso8601String().split('T')[0],
                                        "foodId": widget.foodId,
                                        "foodName": _foodData!['name']?.toString() ?? 'Unknown Food',
                                        "foodCalories": foodCalories,
                                        "foodProtein": safeParseDouble(_foodData!['protein'], 0.0),
                                        "foodCarbs": safeParseDouble(_foodData!['carbs'], 0.0),
                                        "foodFat": safeParseDouble(_foodData!['fat'], 0.0),
                                        "foodFiber": safeParseDouble(_foodData!['fiber'], 0.0),
                                        "weightInGrams": weightInGrams,
                                      };

                                      print("🔵 Request gửi lên API: $requestData");
                                      print("🔵 _foodData: $_foodData");

                                      // Gửi API
                                      foodService.addFoodToMeal(requestData).then((response) {
                                        print("🟢 Phản hồi từ API: $response");

                                        if (response['code'] == 200) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("Đã thêm vào ${widget.mealType}")),
                                          );
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("❌ Lỗi từ API: ${response['message']}")),
                                          );
                                        }
                                      }).catchError((error) {
                                        print("🔴 Lỗi API: $error");

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Lỗi kết nối API: $error")),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
  }

  // Helper method to calculate nutrition values based on entered amount
  double _calculateValue(double originalValue, double servingAmount, double enteredAmount) {
    double ratio = enteredAmount / servingAmount;
    return double.parse((originalValue * ratio).toStringAsFixed(1));
  }

  // Helper widgets
  Widget _buildNutrientCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String name, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: TextStyle(fontSize: 15),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientProgressBar(double value, Color color) {
    // Ensure value is between 0 and 1
    value = value.clamp(0.0, 1.0);

    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: FractionallySizedBox(
        widthFactor: value,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}