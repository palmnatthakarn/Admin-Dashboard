# การแก้ไขปัญหา Remote API Connection

## ปัญหาที่พบ

```
💥 API Error: GET http://192.168.2.52:3000/api/dealers
❌ Error: TimeoutException after 0:00:10.000000: Future not completed
```

## สาเหตุที่เป็นไปได้

1. **API Server ไม่ทำงาน** - Server ที่เครื่อง `192.168.2.52:3000` ไม่ได้เปิดใช้งาน
2. **Network Connection** - ไม่สามารถเชื่อมต่อเครือข่าย LAN ได้
3. **Firewall Blocking** - Windows Firewall บล็อก port 3000
4. **Different Network** - อยู่คนละ network subnet
5. **Server Binding** - Server ไม่ได้ bind กับ 0.0.0.0

## วิธีแก้ไข

### 1. ตรวจสอบ Network Configuration

```bash
# ตรวจสอบ network setup
check_network.bat
```

### 2. รัน API Server บนเครื่อง 192.168.2.52

```bash
# รัน server ให้รองรับ remote access
start-remote-api-server.bat

# หรือรันด้วยตนเอง
cd api-server
npm install
npm start
```

### 3. ทดสอบการเชื่อมต่อ

```bash
# รัน test script
test_api.bat

# ทดสอบจากเครื่องอื่น
curl http://192.168.2.52:3000/health
curl http://192.168.2.52:3000/api/products
```

### 4. ตรวจสอบ Windows Firewall

**บนเครื่อง Server (192.168.2.52):**

1. เปิด Windows Defender Firewall
2. คลิก "Allow an app or feature through Windows Defender Firewall"
3. เพิ่ม Node.js หรือ allow port 3000
4. หรือปิด firewall ชั่วคราว:
   ```bash
   # ปิด firewall (ระวัง!)
   netsh advfirewall set allprofiles state off
   
   # เปิด firewall กลับ
   netsh advfirewall set allprofiles state on
   ```

### 5. ตรวจสอบ Server Binding

ใน `api-server/server.js` ต้องมี:
```javascript
app.listen(PORT, '0.0.0.0', () => {
  // Server code
});
```

### 6. เปลี่ยน Base URL (ถ้าจำเป็น)

แก้ไขใน `lib/core/api_config.dart`:

```dart
// ใช้ IP address ของเครื่อง server
static const String _devBaseUrl = 'http://192.168.2.52:3000/api';

// หรือใช้ localhost ถ้ารันบนเครื่องเดียวกัน
static const String _devBaseUrl = 'http://localhost:3000/api';
```

### 4. ใช้ Mock Data Mode

แอปจะเปลิ่ยนเป็น Mock Data อัตโนมัติเมื่อไม่สามารถเชื่อมต่อ API ได้

```dart
// บังคับใช้ Mock Mode
ApiService.enableMockMode();

// กลับไปใช้ API Mode
ApiService.disableMockMode();
```

## การตรวจสอบสถานะ

### ใน Flutter App

1. ดูที่ TopBar จะมี Connection Status แสดง:
   - 🟢 "API Connected" = เชื่อมต่อ API สำเร็จ
   - 🟠 "Mock Data" = ใช้ข้อมูลจำลอง

2. คลิกที่ไอคอน refresh เพื่อลองเชื่อมต่อใหม่

### ใน Console

```
⚠️ API server not available, switching to mock data
🧪 Mock mode enabled
✅ API connection restored
```

## Mock Data Features

เมื่อใช้ Mock Data จะมีข้อมูลตัวอย่าง:

- **สินค้า**: 5 รายการ (ข้าว, น้ำตาล, น้ำมัน, เกลือ, ซอส)
- **ร้านค้า**: 5 ร้าน (เซเว่น, โลตัส, บิ๊กซี, ช้อปปี้, แม็คโคร)
- **การค้นหา**: รองรับการค้นหาและกรอง
- **การแก้ไขราคา**: สามารถแก้ไขได้ (เก็บใน memory)

## การตั้งค่า API Server

### ติดตั้ง Node.js

1. ดาวน์โหลด Node.js จาก https://nodejs.org
2. ติดตั้งและรีสตาร์ทเครื่อง

### รัน API Server

```bash
cd api-server
npm install
npm start
```

Server จะทำงานที่:
- `http://localhost:3000`
- `http://127.0.0.1:3000`
- `http://192.168.2.52:3000` (ถ้า IP ถูกต้อง)

### ตรวจสอบ IP Address

```bash
# Windows
ipconfig

# หา IPv4 Address ของ Wi-Fi หรือ Ethernet
```

## การแก้ไขปัญหาเฉพาะ

### Windows Firewall

1. เปิด Windows Defender Firewall
2. คลิก "Allow an app or feature through Windows Defender Firewall"
3. เพิ่ม Node.js หรือ allow port 3000

### Network Issues

1. ตรวจสอบว่าอยู่ network เดียวกัน
2. ปิด VPN (ถ้ามี)
3. ลองใช้ localhost แทน IP address

### Port Already in Use

```bash
# หา process ที่ใช้ port 3000
netstat -ano | findstr :3000

# ปิด process
taskkill /PID <PID> /F

# หรือเปลี่ยน port ใน server.js
const PORT = 3001;
```

## การทดสอบ

### 1. ทดสอบ API Server

```bash
# Health check
curl http://localhost:3000/health

# Products
curl http://localhost:3000/api/products

# Dealers  
curl http://localhost:3000/api/dealers
```

### 2. ทดสอบใน Flutter

```bash
flutter run
```

ดูที่ console จะมี log:
```
🚀 API Request: GET http://localhost:3000/api/products
✅ API Response: GET http://localhost:3000/api/products
⏱️  Duration: 150ms
📊 Status: 200
```

## Best Practices

1. **ใช้ localhost สำหรับ development** - เสถียรกว่า IP address
2. **ตรวจสอบ Connection Status** - ดูที่ TopBar
3. **ใช้ Mock Data สำหรับ demo** - ไม่ต้องพึ่ง API server
4. **Log ข้อผิดพลาด** - ดูที่ console เพื่อ debug

## การติดต่อขอความช่วยเหลือ

หากยังแก้ไขไม่ได้ ให้แจ้ง:

1. ข้อความ error ที่แสดง
2. ระบบปฏิบัติการ
3. ผลลัพธ์จาก `test_api.bat`
4. Screenshot ของ Connection Status