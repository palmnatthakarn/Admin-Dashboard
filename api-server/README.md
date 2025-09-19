# API Server สำหรับ Flutter App

## การติดตั้งและรัน

1. ติดตั้ง dependencies:
```bash
cd api-server
npm install
```

2. รัน server:
```bash
npm start
```

หรือสำหรับ development (auto-reload):
```bash
npm run dev
```

Server จะทำงานที่ `http://0.0.0.0:3000`

## API Endpoints

### GET /api/products
ดึงข้อมูลสินค้าทั้งหมด

### GET /api/dealers  
ดึงข้อมูลร้านค้าทั้งหมด

### PUT /api/products/:itemCode/price
อัปเดตราคาสินค้า

**Request Body:**
```json
{
  "price_index": 1,
  "price": 185.0
}
```

### GET /health
ตรวจสอบสถานะ server

## การทดสอบ

ใช้ curl หรือ Postman ทดสอบ:

```bash
# ดึงข้อมูลสินค้า
curl http://192.168.2.52:3000/api/products

# ดึงข้อมูลร้านค้า
curl http://192.168.2.52:3000/api/dealers

# อัปเดตราคา
curl -X PUT http://192.168.2.52:3000/api/products/item-001/price \
  -H "Content-Type: application/json" \
  -d '{"price_index": 1, "price": 185.0}'
```