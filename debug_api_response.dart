import 'package:dio/dio.dart';

void main() async {
  print('🔍 Debugging API Response Structure');
  print('=' * 50);

  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.2.52:3000/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  try {
    // Test products API
    print('📦 Fetching Products API Response...');
    final productsResponse = await dio.get('/products');

    if (productsResponse.statusCode == 200) {
      final productsData = productsResponse.data;

      print('\n📋 Products API Analysis:');
      print('Response Type: ${productsData.runtimeType}');

      if (productsData is Map<String, dynamic>) {
        print('Top Level Keys: ${productsData.keys.toList()}');

        if (productsData['data'] != null && productsData['data'] is List) {
          final products = productsData['data'] as List;
          print('Products Count: ${products.length}');

          if (products.isNotEmpty) {
            final firstProduct = products[0];
            print('\n🔍 First Product Analysis:');
            print('Product Keys: ${firstProduct.keys.toList()}');

            // Analyze each field type
            firstProduct.forEach((key, value) {
              print('  $key: $value (${value.runtimeType})');
            });

            // Special focus on prices
            if (firstProduct['prices'] != null) {
              print('\n💰 Prices Analysis:');
              final prices = firstProduct['prices'];
              print('  Prices Type: ${prices.runtimeType}');
              print('  Prices Value: $prices');

              if (prices is List && prices.isNotEmpty) {
                final priceObj = prices[0];
                print('  First Price Object Type: ${priceObj.runtimeType}');
                print('  First Price Object: $priceObj');

                if (priceObj is Map<String, dynamic>) {
                  print('  Price Fields:');
                  priceObj.forEach((key, value) {
                    print('    $key: $value (${value.runtimeType})');
                  });
                }
              }
            }
          }
        }
      }
    } else {
      print('❌ Products API Error: ${productsResponse.statusCode}');
      print('Response: ${productsResponse.data}');
    }

    print('\n${'=' * 50}');

    // Test dealers API
    print('🏪 Fetching Dealers API Response...');
    final dealersResponse = await dio.get('/dealers');

    if (dealersResponse.statusCode == 200) {
      final dealersData = dealersResponse.data;

      print('\n🏪 Dealers API Analysis:');
      print('Response Type: ${dealersData.runtimeType}');

      if (dealersData is List) {
        print('Dealers Count: ${dealersData.length}');

        if (dealersData.isNotEmpty) {
          final firstDealer = dealersData[0];
          print('\n🔍 First Dealer Analysis:');
          print('Dealer Keys: ${firstDealer.keys.toList()}');

          // Analyze each field type
          firstDealer.forEach((key, value) {
            print('  $key: $value (${value.runtimeType})');
          });
        }
      } else if (dealersData is Map<String, dynamic>) {
        print('Dealers Keys: ${dealersData.keys.toList()}');
        if (dealersData['data'] != null) {
          final dealers = dealersData['data'];
          print('Dealers Data Type: ${dealers.runtimeType}');
          print('Dealers Data: $dealers');
        }
      }
    } else {
      print('❌ Dealers API Error: ${dealersResponse.statusCode}');
      print('Response: ${dealersResponse.data}');
    }

    print('\n${'=' * 50}');
    print('✅ API Response Analysis Completed!');
  } catch (e) {
    print('❌ Error during API analysis: $e');
    print('Stack trace: ${StackTrace.current}');
  }
}
