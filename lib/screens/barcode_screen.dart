import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:caloer_app/service/barcode_service.dart';
import 'food_detail_screen.dart';

class BarcodeScreen extends StatefulWidget {
  final String mealType;
  final DateTime selectedDate;

  BarcodeScreen({required this.mealType, required this.selectedDate});

  @override
  _BarcodeScreenState createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends State<BarcodeScreen> {
  final BarcodeService barcodeService = BarcodeService();
  final TextEditingController _barcodeController = TextEditingController();
  String _scanResult = 'Chưa quét mã vạch';
  bool _isLoading = false;
  Map<String, dynamic>? _productData;

  Future<void> _scanBarcode() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        setState(() {
          _isLoading = true;
        });

        ScanResult barcodeScanRes = await BarcodeScanner.scan(
          options: ScanOptions(
            restrictFormat: BarcodeFormat.values
                .where((format) => format != BarcodeFormat.unknown)
                .toList(), // Hỗ trợ tất cả định dạng mã vạch
            useCamera: -1,
            autoEnableFlash: true,
            android: AndroidOptions(
              useAutoFocus: true,
            ),
          ),
        );

        if (barcodeScanRes.rawContent.isNotEmpty) {
          await _processBarcode(barcodeScanRes.rawContent);
        } else {
          setState(() {
            _scanResult = 'Đã hủy quét mã vạch';
          });
        }
      } catch (e) {
        setState(() {
          _scanResult = 'Lỗi: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _scanResult = 'Quyền truy cập camera bị từ chối';
      });
    }
  }

  Future<void> _processBarcode(String barcode) async {
    try {
      setState(() {
        _isLoading = true;
        _scanResult = 'Đang quét mã vạch...';
      });

      // Gọi BarcodeService để lấy thông tin sản phẩm
      Map<String, dynamic> productData = await barcodeService.scanBarcode(barcode);

      // Kiểm tra phản hồi
      if (productData['id'] == null || productData['id'] == 0) {
        throw Exception('ID sản phẩm không hợp lệ');
      }

      // Lưu thông tin sản phẩm để hiển thị
      setState(() {
        _productData = {
          'id': productData['id'],
          'name': productData['name'] ?? 'Unknown Food',
          'calories': productData['calories'] is num ? (productData['calories'] as num).toDouble() : 0.0,
          'protein': productData['protein'] is num ? (productData['protein'] as num).toDouble() : 0.0,
          'carbs': productData['carbs'] is num ? (productData['carbs'] as num).toDouble() : 0.0,
          'fat': productData['fat'] is num ? (productData['fat'] as num).toDouble() : 0.0,
          'fiber': productData['fiber'] is num ? (productData['fiber'] as num).toDouble() : 0.0,
          'servingSize': productData['servingSize'] ?? '100g',
        };
        _scanResult = 'Sản phẩm: ${_productData!['name']} đã được lưu';
      });

      // Điều hướng đến FoodDetailScreen với ID thực phẩm
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FoodDetailScreen(
            foodId: _productData!['id'],
            selectedDate: widget.selectedDate,
            mealType: widget.mealType,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _scanResult = 'Lỗi: ${e.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitBarcode() async {
    final barcode = _barcodeController.text.trim();
    if (barcode.isEmpty) {
      setState(() {
        _scanResult = 'Vui lòng nhập mã vạch';
      });
      return;
    }

    // Bỏ kiểm tra regex để hỗ trợ tất cả định dạng mã vạch
    await _processBarcode(barcode);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Quét mã vạch',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _scanResult,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              if (_productData != null) ...[
                SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _productData!['name'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        Text('Calo: ${_productData!['calories']} kcal/${_productData!['servingSize']}'),
                        Text('Protein: ${_productData!['protein']}g'),
                        Text('Carbohydrate: ${_productData!['carbs']}g'),
                        Text('Chất béo: ${_productData!['fat']}g'),
                        Text('Chất xơ: ${_productData!['fiber']}g'),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20),
              TextField(
                controller: _barcodeController,
                decoration: InputDecoration(
                  labelText: 'Nhập mã vạch',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _barcodeController.clear();
                    },
                  ),
                ),
                keyboardType: TextInputType.text, // Cho phép nhập chữ và số
                onSubmitted: (_) => _submitBarcode(),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Column(
                children: [
                  ElevatedButton(
                    onPressed: _scanBarcode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Quét mã vạch',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _submitBarcode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'Xác nhận mã vạch',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}