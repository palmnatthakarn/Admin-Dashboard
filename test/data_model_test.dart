import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:flutter_application_1/models/data_model.dart';

void main() {
  group('Data Model Tests', () {
    test('ProductResponse should parse JSON correctly', () {
      const jsonString = '''
      {
        "pagination": {
          "resource": "products",
          "page": 1,
          "per_page": 5,
          "total": 10,
          "total_pages": 2,
          "next_page": 2,
          "prev_page": null
        },
        "data": [
          {
            "barcode": "1234567890123",
            "item_code": "item-001",
            "name": "ข้าวสาร 5 กิโลกรัม",
            "unitcode": "bag",
            "unitname": "ถุง",
            "prices": [150.0, 148.0, 145.0, 142.0, 140.0],
            "dealer_code": "D001",
            "active_date": "2025-09-14"
          }
        ]
      }
      ''';

      final json = jsonDecode(jsonString);
      final productResponse = ProductResponse.fromJson(json);

      expect(productResponse.pagination.resource, 'products');
      expect(productResponse.pagination.page, 1);
      expect(productResponse.pagination.perPage, 5);
      expect(productResponse.data.length, 1);

      final product = productResponse.data.first;
      expect(product.name, 'ข้าวสาร 5 กิโลกรัม');
      expect(product.itemCode, 'item-001');
      expect(product.mainPrice, 150.0);
      expect(product.dealerCode, 'D001');
    });

    test('Product search functionality should work', () {
      final product = Product(
        barcode: '1234567890123',
        itemCode: 'item-001',
        name: 'ข้าวสาร 5 กิโลกรัม',
        unitCode: 'bag',
        unitName: 'ถุง',
        prices: [150.0, 148.0, 145.0, 142.0, 140.0],
        dealerCode: 'D001',
        activeDate: '2025-09-14',
      );

      expect(product.matchesSearch('ข้าวสาร'), true);
      expect(product.matchesSearch('item-001'), true);
      expect(product.matchesSearch('1234567890123'), true);
      expect(product.matchesSearch('ไม่มี'), false);
    });

    test('Product dealer filtering should work', () {
      final product = Product(
        barcode: '1234567890123',
        itemCode: 'item-001',
        name: 'ข้าวสาร 5 กิโลกรัม',
        unitCode: 'bag',
        unitName: 'ถุง',
        prices: [150.0, 148.0, 145.0, 142.0, 140.0],
        dealerCode: 'D001',
        activeDate: '2025-09-14',
      );

      expect(product.matchesDealer('D001'), true);
      expect(product.matchesDealer('D002'), false);
      expect(product.matchesDealer(null), true); // null means show all
    });
  });
}
