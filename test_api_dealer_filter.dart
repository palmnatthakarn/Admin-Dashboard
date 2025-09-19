import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Testing API Dealer Filter');
  print('=' * 50);

  final client = HttpClient();
  const baseUrl = 'http://192.168.2.52:3000/api';

  try {
    // 1. ทดสอบโหลด dealers
    print('1. Loading dealers...');
    final dealersRequest = await client.getUrl(Uri.parse('$baseUrl/dealers'));
    final dealersResponse = await dealersRequest.close();
    final dealersBody = await dealersResponse.transform(utf8.decoder).join();
    final dealersData = jsonDecode(dealersBody);

    print('   ✅ Status: ${dealersResponse.statusCode}');
    print('   📊 Found ${dealersData['data']?.length ?? 0} dealers');

    if (dealersData['data'] != null && dealersData['data'].isNotEmpty) {
      print('   📋 Available dealers:');
      for (var dealer in dealersData['data'].take(3)) {
        print('      - ${dealer['dealer_code']}: ${dealer['dealer_name']}');
      }
    }

    // 2. ทดสอบโหลดสินค้าทั้งหมด (ไม่ filter)
    print('\n2. Loading all products...');
    final allProductsRequest = await client.getUrl(
      Uri.parse('$baseUrl/products?page=1&per_page=10'),
    );
    final allProductsResponse = await allProductsRequest.close();
    final allProductsBody = await allProductsResponse
        .transform(utf8.decoder)
        .join();
    final allProductsData = jsonDecode(allProductsBody);

    print('   ✅ Status: ${allProductsResponse.statusCode}');
    print(
      '   📊 Found ${allProductsData['data']?.length ?? 0} products (page 1)',
    );
    print(
      '   📈 Total products: ${allProductsData['pagination']?['total'] ?? 0}',
    );

    if (allProductsData['data'] != null && allProductsData['data'].isNotEmpty) {
      print('   📋 Sample products:');
      for (var product in allProductsData['data'].take(3)) {
        print(
          '      - ${product['item_code']}: ${product['name']} (Dealer: ${product['dealer_code']})',
        );
      }
    }

    // 3. ทดสอบ filter ตาม dealer
    if (dealersData['data'] != null && dealersData['data'].isNotEmpty) {
      final testDealer = dealersData['data'][0];
      final dealerCode = testDealer['dealer_code'];

      print('\n3. Testing filter by dealer: $dealerCode');

      final filteredRequest = await client.getUrl(
        Uri.parse(
          '$baseUrl/products?page=1&per_page=10&dealer_code=$dealerCode',
        ),
      );
      final filteredResponse = await filteredRequest.close();
      final filteredBody = await filteredResponse
          .transform(utf8.decoder)
          .join();
      final filteredData = jsonDecode(filteredBody);

      print('   ✅ Status: ${filteredResponse.statusCode}');
      print(
        '   📊 Found ${filteredData['data']?.length ?? 0} products for dealer $dealerCode',
      );
      print(
        '   📈 Total products for this dealer: ${filteredData['pagination']?['total'] ?? 0}',
      );

      if (filteredData['data'] != null && filteredData['data'].isNotEmpty) {
        print('   📋 Products for ${testDealer['dealer_name']}:');
        for (var product in filteredData['data'].take(3)) {
          print(
            '      - ${product['item_code']}: ${product['name']} (Dealer: ${product['dealer_code']})',
          );
        }
      }

      // 4. ตรวจสอบว่าข้อมูลที่ filter แล้วถูกต้องหรือไม่
      print('\n4. Validating filter results...');
      bool allProductsMatchDealer = true;
      int mismatchCount = 0;

      if (filteredData['data'] != null) {
        for (var product in filteredData['data']) {
          if (product['dealer_code'] != dealerCode) {
            allProductsMatchDealer = false;
            mismatchCount++;
            if (mismatchCount <= 3) {
              // แสดงแค่ 3 ตัวอย่างแรก
              print(
                '      ⚠️  ${product['item_code']} has dealer ${product['dealer_code']} instead of $dealerCode',
              );
            }
          }
        }
      }

      if (allProductsMatchDealer) {
        print('   ✅ All filtered products match the selected dealer');
      } else {
        print(
          '   ❌ Found $mismatchCount products that don\'t match the selected dealer!',
        );
      }

      // 5. ทดสอบ dealer อื่น
      if (dealersData['data'].length > 1) {
        final secondDealer = dealersData['data'][1];
        final secondDealerCode = secondDealer['dealer_code'];

        print('\n5. Testing second dealer: $secondDealerCode');

        final secondFilteredRequest = await client.getUrl(
          Uri.parse(
            '$baseUrl/products?page=1&per_page=10&dealer_code=$secondDealerCode',
          ),
        );
        final secondFilteredResponse = await secondFilteredRequest.close();
        final secondFilteredBody = await secondFilteredResponse
            .transform(utf8.decoder)
            .join();
        final secondFilteredData = jsonDecode(secondFilteredBody);

        print('   ✅ Status: ${secondFilteredResponse.statusCode}');
        print(
          '   📊 Found ${secondFilteredData['data']?.length ?? 0} products for dealer $secondDealerCode',
        );
        print(
          '   📈 Total products for this dealer: ${secondFilteredData['pagination']?['total'] ?? 0}',
        );

        if (secondFilteredData['data'] != null &&
            secondFilteredData['data'].isNotEmpty) {
          print('   📋 Products for ${secondDealer['dealer_name']}:');
          for (var product in secondFilteredData['data'].take(3)) {
            print(
              '      - ${product['item_code']}: ${product['name']} (Dealer: ${product['dealer_code']})',
            );
          }
        }
      }

      // 6. ทดสอบ search + dealer filter
      print('\n6. Testing search with dealer filter...');
      final searchFilteredRequest = await client.getUrl(
        Uri.parse(
          '$baseUrl/products?page=1&per_page=10&dealer_code=$dealerCode&search=น้ำ',
        ),
      );
      final searchFilteredResponse = await searchFilteredRequest.close();
      final searchFilteredBody = await searchFilteredResponse
          .transform(utf8.decoder)
          .join();
      final searchFilteredData = jsonDecode(searchFilteredBody);

      print('   ✅ Status: ${searchFilteredResponse.statusCode}');
      print(
        '   📊 Found ${searchFilteredData['data']?.length ?? 0} products matching "น้ำ" for dealer $dealerCode',
      );
      print(
        '   📈 Total matching products: ${searchFilteredData['pagination']?['total'] ?? 0}',
      );
    }

    print('\n✅ API dealer filter testing completed successfully!');
  } catch (e, stackTrace) {
    print('\n❌ Error during testing: $e');
    print('Stack trace: $stackTrace');
  } finally {
    client.close();
  }
}
