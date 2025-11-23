import 'package:flutter/material.dart';
import 'package:caloer_app/service/food_service.dart';
import 'food_detail_screen.dart';
import 'barcode_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ScheduleMealsScreen extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;

  const ScheduleMealsScreen({super.key, required this.mealType, required this.selectedDate});

  @override
  _ScheduleMealsScreenState createState() => _ScheduleMealsScreenState();
}

class _ScheduleMealsScreenState extends State<ScheduleMealsScreen> {
  final FoodService foodService = FoodService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  String selectedTab = 'Gần đây';
  List<Map<String, dynamic>> mealItems = [];
  List<Map<String, dynamic>> filteredItems = [];
  TextEditingController searchController = TextEditingController();
  late String mealType;
  bool _isSearching = false;
  bool _isListening = false;
  String _voiceStatus = '';

  @override
  void initState() {
    super.initState();
    _fetchRandomFood();
    mealType = widget.mealType;
    _initializeSpeech();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Xử lý query để tự động thêm "100g" nếu cần
  String _processQuery(String query) {
    // Kiểm tra xem query đã có số và đơn vị chưa
    RegExp hasNumberAndUnit = RegExp(r'\d+\s*(g|kg|ml|l|gram|kilogram|liter|litre)', caseSensitive: false);
    
    if (hasNumberAndUnit.hasMatch(query)) {
      // Nếu đã có số và đơn vị, giữ nguyên
      return query;
    } else {
      // Nếu chưa có, thêm "100g" vào đầu
      return "100g $query";
    }
  }

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == 'listening';
          _voiceStatus = _isListening ? 'Đang nghe...' : '';
        });
      },
      onError: (error) {
        setState(() {
          _isListening = false;
          _voiceStatus = '';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi nhận diện giọng nói: ${error.errorMsg}'), backgroundColor: Colors.red),
          );
        });
      },
    );
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể khởi tạo nhận diện giọng nói'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool hasPermission = await _speech.hasPermission;
      if (!hasPermission) {
        await _speech.initialize();
      }
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            searchController.text = result.recognizedWords;
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              _searchFoods();
            }
          });
        },
        localeId: 'vi_VN', // Set to Vietnamese for better recognition
      );
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
    }
  }

  Future<void> _fetchRandomFood() async {
    try {
      List<Map<String, dynamic>> foods = await foodService.fetchRandomFoods();
      setState(() {
        mealItems = foods;
        filteredItems = List.from(mealItems);
      });
    } catch (e) {
      print("Lỗi fetchRandomFood: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể tải danh sách món ăn'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _searchFoods() async {
    String query = searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        filteredItems = List.from(mealItems);
      });
      return;
    }

    // Tự động thêm "100g" nếu query không chứa số và đơn vị
    String processedQuery = _processQuery(query);

    setState(() {
      _isSearching = true;
    });

    try {
      List<Map<String, dynamic>> predictResults = await foodService.predictFood(processedQuery);
      
      setState(() {
        filteredItems = predictResults;
        _isSearching = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(predictResults.isEmpty
              ? '😕 AI chưa tìm được món phù hợp'
              : '✅ Đã tìm thấy ${predictResults.length} lựa chọn'),
          backgroundColor: predictResults.isEmpty ? Colors.orange : Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      
    } catch (predictError) {
      setState(() {
        _isSearching = false;
        filteredItems = [];
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Lỗi AI predict: ${predictError.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToFoodDetail(Map<String, dynamic> food) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(
          foodId: food['id'],
          selectedDate: widget.selectedDate,
          mealType: widget.mealType,
          foodData: food, // Truyền data food để sử dụng luôn thay vì gọi API
        ),
      ),
    );
  }

  void _navigateToBarcodeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScreen(
          mealType: widget.mealType,
          selectedDate: widget.selectedDate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Chọn món ăn cho ${widget.mealType}",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Theme.of(context).primaryColor),
            onPressed: _navigateToBarcodeScreen,
          ),
          IconButton(
            icon: Icon(Icons.favorite_border, color: Colors.redAccent),
            onPressed: () {
              // Favorites action
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar with Voice and Search Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onSubmitted: (_) => _searchFoods(),
                          decoration: InputDecoration(
                            hintText: 'Nhập món ăn để AI phân tích (VD: 100g thịt cá mập)',
                            hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                            prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                        ),
                        onPressed: _isSearching ? null : _searchFoods,
                        child: _isSearching
                            ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : Icon(Icons.search, color: Colors.white),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListening ? Colors.red : Theme.of(context).primaryColor,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(12),
                        ),
                        onPressed: _startListening,
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  if (_voiceStatus.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        _voiceStatus,
                        style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            // Tab bar
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabItem('Gần đây'),
                  _buildTabItem('Yêu thích'),
                  _buildTabItem('Của tôi'),
                ],
              ),
            ),

            // Food List
            Expanded(
              child: _isSearching
                  ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                ),
              )
                  : filteredItems.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.no_food, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      "Không tìm thấy món ăn nào",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    return _buildFoodCard(filteredItems[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add),
        onPressed: () {
          // Add new food
        },
      ),
    );
  }

  // Food Card Widget
  Widget _buildFoodCard(Map<String, dynamic> food) {
    Color cardColor = Colors.primaries[food['id'] % Colors.primaries.length].shade50;

    return GestureDetector(
      onTap: () => _navigateToFoodDetail(food),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image or Icon Placeholder
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: ((food['imageUrl'] != null && food['imageUrl'].toString().isNotEmpty) ||
                        (food['image_url'] != null && food['image_url'].toString().isNotEmpty))
                    ? Image.network(
                        (food['imageUrl'] ?? food['image_url']).toString(),
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Hiển thị icon nếu lỗi load ảnh
                          return Container(
                            color: cardColor,
                            child: Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 50,
                                color: Colors.primaries[food['id'] % Colors.primaries.length],
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            color: cardColor,
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.primaries[food['id'] % Colors.primaries.length],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: cardColor,
                        child: Center(
                          child: Icon(
                            Icons.restaurant_menu,
                            size: 50,
                            color: Colors.primaries[food['id'] % Colors.primaries.length],
                          ),
                        ),
                      ),
              ),
            ),

            // Food Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${food['calories'].toStringAsFixed(0)} kcal",
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "${food['servingSize']}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tab Item Widget
  Widget _buildTabItem(String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selectedTab == title
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: selectedTab == title ? FontWeight.bold : FontWeight.normal,
              color: selectedTab == title
                  ? Theme.of(context).primaryColor
                  : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}