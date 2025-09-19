# แนวทางแก้ไขปัญหา Dealer Filter

## ปัญหา
- API `/dealers` ส่งกลับ 10 dealers: EZ978, QC759, WW013, LW097, TX140, LF413, MK256, RT891, PL634, VN472
- API `/products` ส่งกลับข้อมูลที่มี dealer_code ไม่ตรงกัน
- เมื่อเลือก dealer จาก DealerFilter ข้อมูลใน ProductsTable ไม่เปลี่ยน

## แนวทางแก้ไข

### 1. แก้ไข API Server (แนะนำ)
```javascript
// ใน api-server/server.js
// ให้ API `/products` filter ข้อมูลตาม dealer_code ที่ถูกต้อง
// และส่งกลับเฉพาะข้อมูลที่ตรงกับ dealer ที่เลือก
```

### 2. แก้ไขใน Flutter App (ชั่วคราว)
```dart
// ใน lib/services/api_data_service.dart
static Future<ProductResponse> getProducts({
  int page = 1,
  int perPage = 10,
  String? search,
  String? dealerCode,
}) async {
  // เรียก API ปกติ
  final response = await _dio.get('/products', queryParameters: queryParams);
  
  // Filter ข้อมูลใน client side
  if (dealerCode != null && dealerCode.isNotEmpty) {
    final filteredProducts = response.data['data']
        .where((product) => product['dealer_code'] == dealerCode)
        .toList();
    
    // สร้าง response ใหม่ที่ filter แล้ว
    return ProductResponse(
      data: filteredProducts.map((p) => Product.fromJson(p)).toList(),
      pagination: Pagination(
        resource: 'products',
        page: page,
        perPage: perPage,
        total: filteredProducts.length,
        totalPages: (filteredProducts.length / perPage).ceil(),
      ),
    );
  }
  
  // ส่งกลับข้อมูลปกติถ้าไม่มี filter
  return ProductResponse.fromJson(response.data);
}
```

### 3. ตรวจสอบข้อมูลใน Debug Mode
```dart
// ใน lib/widgets/products_table.dart
@override
Widget build(BuildContext context) {
  if (kDebugMode) {
    print('ProductsTable - Selected dealer: ${widget.selectedDealer}');
    print('ProductsTable - Products count: ${widget.filteredProducts.length}');
    if (widget.filteredProducts.isNotEmpty) {
      print('ProductsTable - First product dealer: ${widget.filteredProducts.first.dealerCode}');
    }
  }
  // ... rest of build method
}
```

## การทดสอบ
1. เลือก dealer จาก DealerFilter
2. ตรวจสอบ console log ว่าข้อมูลถูกส่งไปยัง API ถูกต้อง
3. ตรวจสอบว่าข้อมูลใน ProductsTable เปลี่ยนตาม dealer ที่เลือก

## สถานะปัจจุบัน
- ✅ API server โหลดข้อมูลจาก products_real.json ถูกต้อง
- ✅ Dealer index สร้างถูกต้อง (10 dealers)
- ❌ API `/products` ยังส่งข้อมูลที่ไม่ตรงกับ dealer index
- ❌ Dealer filtering ไม่ทำงาน

## ขั้นตอนถัดไป
1. แก้ไข API server ให้ส่งข้อมูลที่ถูกต้อง
2. ทดสอบ API endpoints
3. ทดสอบ Flutter app