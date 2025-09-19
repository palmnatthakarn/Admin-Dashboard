import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔄 Comparing API Formats: Real vs Mock');
  print('=' * 60);

  try {
    // Test Real API
    print('🌐 Real API (192.168.2.52:3000)');
    print('-' * 30);

    final realResponse = await http
        .get(
          Uri.parse('http://192.168.2.52:3000/api/products'),
          headers: {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (realResponse.statusCode == 200) {
      final realData = json.decode(realResponse.body);
      print('✅ Real API Response Structure:');

      if (realData is Map &&
          realData['data'] is List &&
          realData['data'].isNotEmpty) {
        final realProduct = realData['data'][0];
        print('📦 Sample Product from Real API:');
        print(JsonEncoder.withIndent('  ').convert(realProduct));

        // Check specific field types that might cause issues
        print('\n🔍 Field Type Analysis:');
        final criticalFields = [
          'barcode',
          'item_code',
          'prices',
          'dealer_code',
        ];

        for (final field in criticalFields) {
          if (realProduct.containsKey(field)) {
            final value = realProduct[field];
            print('  $field: ${value.runtimeType} = $value');

            if (field == 'prices' && value is List && value.isNotEmpty) {
              final priceObj = value[0];
              if (priceObj is Map) {
                print('    Price object fields:');
                priceObj.forEach((k, v) {
                  print('      $k: ${v.runtimeType} = $v');
                });
              }
            }
          } else {
            print('  $field: ❌ MISSING');
          }
        }
      }
    } else {
      print('❌ Real API failed: ${realResponse.statusCode}');
    }

    print('\n' + '=' * 60);

    // Compare with Mock Server (if running locally)
    print('🏠 Mock Server (localhost:3000)');
    print('-' * 30);

    try {
      final mockResponse = await http
          .get(
            Uri.parse('http://localhost:3000/api/products'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (mockResponse.statusCode == 200) {
        final mockData = json.decode(mockResponse.body);
        print('✅ Mock API Response Structure:');

        if (mockData is Map &&
            mockData['data'] is List &&
            mockData['data'].isNotEmpty) {
          final mockProduct = mockData['data'][0];
          print('📦 Sample Product from Mock API:');
          print(JsonEncoder.withIndent('  ').convert(mockProduct));

          print('\n🔍 Field Type Analysis:');
          final criticalFields = [
            'barcode',
            'item_code',
            'prices',
            'dealer_code',
          ];

          for (final field in criticalFields) {
            if (mockProduct.containsKey(field)) {
              final value = mockProduct[field];
              print('  $field: ${value.runtimeType} = $value');

              if (field == 'prices' && value is List && value.isNotEmpty) {
                final priceObj = value[0];
                if (priceObj is Map) {
                  print('    Price object fields:');
                  priceObj.forEach((k, v) {
                    print('      $k: ${v.runtimeType} = $v');
                  });
                }
              }
            } else {
              print('  $field: ❌ MISSING');
            }
          }
        }
      } else {
        print('❌ Mock API failed: ${mockResponse.statusCode}');
      }
    } catch (e) {
      print('⚠️  Mock server not available: $e');
    }

    print('\n' + '=' * 60);
    print('✅ API Format Comparison Completed!');
  } catch (e) {
    print('❌ Error during comparison: $e');
  }
}
