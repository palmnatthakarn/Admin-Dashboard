# วิธีการใช้งาน

## 1. เริ่มต้น API Server

### วิธีที่ 1: ใช้ batch file (Windows)
```bash
# Double-click หรือรันใน command prompt
start-api-server.bat
```

### วิธีที่ 2: รันด้วยตนเอง
```bash
cd api-server
npm install
npm start
```

## 2. รัน Flutter App

```bash
flutter pub get
flutter run
```

## 3. การทดสอบ API

### ทดสอบด้วย Browser
- เปิด `http://192.168.2.52:3000/api/products`
- เปิด `http://192.168.2.52:3000/api/dealers`
- เปิด `http://192.168.2.52:3000/health`

### ทดสอบด้วย curl
```bash
# ดึงข้อมูลสินค้า
curl http://192.168.2.52:3000/api/products

# อัปเดตราคาสินค้า
curl -X PUT http://192.168.2.52:3000/api/products/item-001/price ^
  -H "Content-Type: application/json" ^
  -d "{\"price_index\": 1, \"price\": 185.0}"
```

## 4. การแก้ไขปัญหา

### ปัญหา: ไม่สามารถเชื่อมต่อ API ได้
1. ตรวจสอบว่า API server ทำงานอยู่
2. ตรวจสอบ IP address ใน `lib/services/api_service.dart`
3. ตรวจสอบ firewall settings

### ปัญหา: CORS Error
- API server มี CORS middleware แล้ว
- ตรวจสอบว่า server รันบน port 3000

### ปัญหา: Timeout
- เพิ่มเวลา timeout ใน `api_service.dart`
- ตรวจสอบความเร็วเครือข่าย

## 5. การปรับแต่ง

### เปลี่ยน API URL
แก้ไขใน `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'http://YOUR_IP:3000/api';
```

### เปลี่ยน Port
แก้ไขใน `api-server/server.js`:
```javascript
const PORT = 3001; // เปลี่ยนจาก 3000
```

### เพิ่มข้อมูลทดสอบ
แก้ไขใน `api-server/server.js` ในส่วน `products.data` และ `dealers.data`