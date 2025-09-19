import 'package:flutter/material.dart';
import 'lib/services/api_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔄 Testing API connection to http://192.168.2.52:3000/api/products');

  try {
    // Test products API
    print('📦 Fetching products...');
    final productResponse = await ApiDataService.getProducts();
    print('✅ Products loaded: ${productResponse.data.length} items');

    if (productResponse.data.isNotEmpty) {
      final firstProduct = productResponse.data.first;
      print('📋 First product: ${firstProduct.name}');
      print('💰 Prices: ${firstProduct.prices}');
    }

    // Test dealers API
    print('\n🏪 Fetching dealers...');
    final dealerResponse = await ApiDataService.getDealers();
    print('✅ Dealers loaded: ${dealerResponse.data.length} items');

    if (dealerResponse.data.isNotEmpty) {
      final firstDealer = dealerResponse.data.first;
      print('🏪 First dealer: ${firstDealer.dealerName}');
    }

    print('\n🎉 API connection test completed successfully!');
  } catch (e) {
    print('❌ API connection failed: $e');
  }
}
