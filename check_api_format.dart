import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔍 Checking API Response Formats');
  print('=' * 60);

  final client = HttpClient();

  try {
    // 1. Check /api/dealers
    print('\n📋 API: /api/dealers');
    print('-' * 30);

    final dealersRequest = await client.getUrl(
      Uri.parse('http://192.168.2.52:3000/api/dealers'),
    );
    final dealersResponse = await dealersRequest.close();
    final dealersBody = await dealersResponse.transform(utf8.decoder).join();

    print('Status: ${dealersResponse.statusCode}');
    print('Response:');

    if (dealersResponse.statusCode == 200) {
      final dealersData = jsonDecode(dealersBody);
      final prettyDealers = JsonEncoder.withIndent('  ').convert(dealersData);
      print(prettyDealers);

      // Analyze structure
      if (dealersData is Map && dealersData['data'] is List) {
        final dealers = dealersData['data'] as List;
        print('\n📊 Analysis:');
        print('   Total dealers: ${dealers.length}');
        if (dealers.isNotEmpty) {
          final firstDealer = dealers.first;
          print('   Fields: ${firstDealer.keys.join(', ')}');
          print(
            '   Sample: ${firstDealer['dealer_code']} - ${firstDealer['dealer_name']}',
          );
        }
      }
    } else {
      print('Error: ${dealersResponse.statusCode}');
      print(dealersBody);
    }

    // 2. Check /api/products (first 3 items)
    print('\n\n📦 API: /api/products');
    print('-' * 30);

    final productsRequest = await client.getUrl(
      Uri.parse('http://192.168.2.52:3000/api/products?per_page=3'),
    );
    final productsResponse = await productsRequest.close();
    final productsBody = await productsResponse.transform(utf8.decoder).join();

    print('Status: ${productsResponse.statusCode}');
    print('Response:');

    if (productsResponse.statusCode == 200) {
      final productsData = jsonDecode(productsBody);
      final prettyProducts = JsonEncoder.withIndent('  ').convert(productsData);
      print(prettyProducts);

      // Analyze structure
      if (productsData is Map && productsData['data'] is List) {
        final products = productsData['data'] as List;
        print('\n📊 Analysis:');
        print('   Products shown: ${products.length}');
        print(
          '   Total products: ${productsData['pagination']?['total'] ?? 'unknown'}',
        );
        if (products.isNotEmpty) {
          final firstProduct = products.first;
          print('   Fields: ${firstProduct.keys.join(', ')}');
          print(
            '   Sample: ${firstProduct['item_code']} - ${firstProduct['name']}',
          );
          print('   Dealer: ${firstProduct['dealer_code']}');
        }
      }
    } else {
      print('Error: ${productsResponse.statusCode}');
      print(productsBody);
    }

    // 3. Check dealer consistency
    print('\n\n🔗 Checking Dealer Consistency');
    print('-' * 40);

    if (dealersResponse.statusCode == 200 &&
        productsResponse.statusCode == 200) {
      final dealersData = jsonDecode(
        await client
            .getUrl(Uri.parse('http://192.168.2.52:3000/api/dealers'))
            .then((req) => req.close())
            .then((res) => res.transform(utf8.decoder).join()),
      );
      final allProductsData = jsonDecode(
        await client
            .getUrl(
              Uri.parse('http://192.168.2.52:3000/api/products?per_page=50'),
            )
            .then((req) => req.close())
            .then((res) => res.transform(utf8.decoder).join()),
      );

      final dealerCodes = (dealersData['data'] as List)
          .map((d) => d['dealer_code'].toString())
          .toSet();

      final productDealerCodes = (allProductsData['data'] as List)
          .map((p) => p['dealer_code'].toString())
          .toSet();

      print('Dealers in /api/dealers: ${dealerCodes.toList()..sort()}');
      print('Dealers in /api/products: ${productDealerCodes.toList()..sort()}');

      final commonDealers = dealerCodes.intersection(productDealerCodes);
      final dealersOnlyInDealersAPI = dealerCodes.difference(
        productDealerCodes,
      );
      final dealersOnlyInProductsAPI = productDealerCodes.difference(
        dealerCodes,
      );

      print('\n✅ Common dealers: ${commonDealers.toList()..sort()}');
      if (dealersOnlyInDealersAPI.isNotEmpty) {
        print(
          '⚠️  Dealers only in /dealers: ${dealersOnlyInDealersAPI.toList()..sort()}',
        );
      }
      if (dealersOnlyInProductsAPI.isNotEmpty) {
        print(
          '⚠️  Dealers only in /products: ${dealersOnlyInProductsAPI.toList()..sort()}',
        );
      }

      print('\n📈 Summary:');
      print('   Total dealers available: ${dealerCodes.length}');
      print('   Dealers with products: ${commonDealers.length}');
      print('   Dealers without products: ${dealersOnlyInDealersAPI.length}');
    }
  } catch (e, stackTrace) {
    print('\n❌ Error: $e');
    print('Stack trace: $stackTrace');
  } finally {
    client.close();
  }
}
