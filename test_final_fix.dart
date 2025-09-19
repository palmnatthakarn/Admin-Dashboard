import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test safe casting functions
double safeToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    try {
      return double.parse(value);
    } catch (e) {
      print('Failed to parse "$value" as double: $e');
      return 0.0;
    }
  }

  try {
    return double.parse(value.toString());
  } catch (e) {
    print('Failed to convert "$value" (${value.runtimeType}) to double: $e');
    return 0.0;
  }
}

int safeToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    try {
      return int.parse(value);
    } catch (e) {
      try {
        return double.parse(value).toInt();
      } catch (e2) {
        print('Failed to parse "$value" as int: $e2');
        return 0;
      }
    }
  }

  try {
    return int.parse(value.toString());
  } catch (e) {
    print('Failed to convert "$value" (${value.runtimeType}) to int: $e');
    return 0;
  }
}

void main() async {
  print('🧪 Testing Final Fix with Safe Casting');
  print('=' * 50);

  try {
    print('📦 Fetching API data...');
    final response = await http
        .get(
          Uri.parse('http://192.168.2.52:3000/api/products'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final apiData = json.decode(response.body);

      print('✅ API Response received');

      // Test pagination parsing with safe casting
      print('\n📊 Testing Pagination Safe Casting:');
      final paginationData = apiData['pagination'] as Map<String, dynamic>;

      final testFields = [
        'page',
        'per_page',
        'total',
        'total_pages',
        'next_page',
        'prev_page',
      ];

      for (final field in testFields) {
        final value = paginationData[field];
        final safeValue = safeToInt(value);
        print('  $field: $value (${value.runtimeType}) → $safeValue');
      }

      // Test product parsing
      print('\n📦 Testing Product Safe Casting:');
      if (apiData['data'] != null && apiData['data'].isNotEmpty) {
        final firstProduct = apiData['data'][0];

        print('Product: ${firstProduct['name']}');

        // Test prices parsing
        if (firstProduct['prices'] != null &&
            firstProduct['prices'] is List &&
            firstProduct['prices'].isNotEmpty) {
          final priceObj = firstProduct['prices'][0];
          if (priceObj is Map<String, dynamic>) {
            print('  Prices safe casting:');
            final priceFields = [
              'price_1',
              'price_2',
              'price_3',
              'price_4',
              'price_5',
            ];

            for (final field in priceFields) {
              final value = priceObj[field];
              final safeValue = safeToDouble(value);
              print('    $field: $value (${value.runtimeType}) → $safeValue');
            }
          }
        }

        // Test other fields
        print('  Other fields:');
        final otherFields = ['barcode', 'item_code', 'dealer_code'];
        for (final field in otherFields) {
          final value = firstProduct[field];
          final stringValue = value?.toString() ?? '';
          print('    $field: $value (${value.runtimeType}) → "$stringValue"');
        }
      }

      print('\n🎉 All safe casting tests completed successfully!');
    } else {
      print('❌ API Error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Test failed: $e');
  }
}
