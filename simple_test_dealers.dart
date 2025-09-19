import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing Dealers API...');

  try {
    // Test API call
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('http://192.168.2.52:3000/api/dealers'),
    );
    final response = await request.close();

    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonData = json.decode(responseBody);

      print('✅ API Response received');
      print('📊 Status Code: ${response.statusCode}');

      if (jsonData['data'] != null) {
        final dealers = jsonData['data'] as List;
        print('📊 Dealers count: ${dealers.length}');

        print('\n📋 Dealers list:');
        for (int i = 0; i < dealers.length; i++) {
          final dealer = dealers[i];
          print(
            '   ${i + 1}. ${dealer['dealer_name']} (${dealer['dealer_code']})',
          );
        }

        print('\n🎉 Dealers API working correctly!');
      } else {
        print('❌ No dealers data found');
      }
    } else {
      print('❌ API Error: ${response.statusCode}');
    }

    client.close();
  } catch (e) {
    print('❌ Error occurred: $e');
  }
}
