import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../service/food_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final int foodId;
  final DateTime selectedDate;
  final String mealType;

  FoodDetailScreen({
    required this.foodId,
    required this.selectedDate,
    required this.mealType,
  });

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final FoodService foodService = FoodService();
  final TextEditingController _amountController = TextEditingController();
  final String _selectedMeal = 'Bữa sáng'; // Default selected meal

  @override
  void initState() {
    super.initState();
    _amountController.text = '100'; // Default serving amount
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder(
        future: foodService.fetchFoodDetail(widget.foodId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
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
          } else {
            final food = snapshot.data as Map<String, dynamic>;
            // Safely parse numeric fields to double with fallback to 0.0
            final double calories = (food['calories'] ?? 0.0) is num ? (food['calories'] as num).toDouble() : 0.0;
            final double protein = (food['protein'] ?? 0.0) is num ? (food['protein'] as num).toDouble() : 0.0;
            final double carbs = (food['carbs'] ?? 0.0) is num ? (food['carbs'] as num).toDouble() : 0.0;
            final double fat = (food['fat'] ?? 0.0) is num ? (food['fat'] as num).toDouble() : 0.0;
            final double servingAmount = (food['servingAmount'] ?? 100.0) is num ? (food['servingAmount'] as num).toDouble() : 100.0;

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
                      food['name'] ?? 'Unknown Food',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    background: Container(
                      color: const Color(0xFFFCE4EC), // Match the background color
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: Icon(
                              Icons.local_dining, // Replace with a fork-and-spoon icon (or use a custom asset)
                              size: 80,
                              color: const Color(0xFFE91E63), // Pink color for the icon
                            ),
                          ),
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                              ),
                            ),
                          ),
                        ],
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
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: "Số gram thực tế",
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    suffixText: "g",
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
                                          _buildNutrientInfo("Calo", "${_calculateValue(calories, servingAmount, _amountController.text)} kcal"),
                                          _buildNutrientInfo("Protein", "${_calculateValue(protein, servingAmount, _amountController.text)}g"),
                                          _buildNutrientInfo("Carbs", "${_calculateValue(carbs, servingAmount, _amountController.text)}g"),
                                          _buildNutrientInfo("Fat", "${_calculateValue(fat, servingAmount, _amountController.text)}g"),
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
                                      double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

                                      if (enteredAmount <= 0) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Vui lòng nhập số lượng hợp lệ")),
                                        );
                                        return;
                                      }

                                      // Tạo JSON data để gửi lên API
                                      Map<String, dynamic> requestData = {
                                        "mealType": widget.mealType,
                                        "date": widget.selectedDate.toIso8601String().split('T')[0],
                                        "foodId": widget.foodId,
                                        "weightInGrams": enteredAmount,
                                      };

                                      print("🔵 Request gửi lên API: $requestData");

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
        },
      ),
    );
  }

  // Helper method to calculate nutrition values based on entered amount
  double _calculateValue(double originalValue, double servingAmount, String enteredAmount) {
    double amount = double.tryParse(enteredAmount) ?? 0.0;
    double ratio = amount / servingAmount;
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