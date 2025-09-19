import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/data_model.dart';

class ApiDataService {
  static const String baseUrl = 'http://192.168.2.52:3000/api';

  // ⚡ Cache สำหรับเก็บข้อมูล products ตาม dealer
  static final Map<String, ProductResponse> _productsCache = {};
  static const int _cacheExpiryMinutes = 5;

  // Dio instance with default configuration
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 3), // ⚡ ลดเหลือ 3 วินาที
      receiveTimeout: const Duration(seconds: 5), // ⚡ ลดเหลือ 5 วินาที
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Get products from API server
  static Future<ProductResponse> getProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? dealerCode,
  }) async {
    // ⚡ สร้าง cache key
    final cacheKey =
        '${dealerCode ?? 'all'}_${page}_${perPage}_${search ?? ''}';

    // ⚡ ตรวจสอบ cache ก่อน (เฉพาะเมื่อไม่มี search)
    if (search == null || search.isEmpty) {
      final cached = _productsCache[cacheKey];
      if (cached != null) {
        debugPrint('⚡ Using cached data for: $cacheKey');
        return cached;
      }
    }

    try {
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (dealerCode != null && dealerCode.isNotEmpty) {
        queryParams['dealer_code'] = dealerCode;
      }

      debugPrint('API Call: GET /products with params: $queryParams');

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        debugPrint('API Response: ${response.data['pagination']}');
        debugPrint('Products count: ${response.data['data']?.length ?? 0}');
        final Map<String, dynamic> jsonData = response.data;

        // Transform API response to match our data model
        final result = _createProductResponseFromApi(jsonData);

        // ⚡ เก็บใน cache (เฉพาะเมื่อไม่มี search)
        if (search == null || search.isEmpty) {
          _productsCache[cacheKey] = result;
          debugPrint('⚡ Cached data for: $cacheKey');

          // ⚡ ล้าง cache เก่าทุก 5 นาที
          Timer(Duration(minutes: _cacheExpiryMinutes), () {
            _productsCache.remove(cacheKey);
            debugPrint('⚡ Cache expired for: $cacheKey');
          });
        }

        return result;
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty data if API call fails
      debugPrint('Error loading products: $e');
      return ProductResponse(
        data: [],
        pagination: Pagination(
          resource: 'products',
          page: page,
          perPage: perPage,
          total: 0,
          totalPages: 1,
        ),
      );
    }
  }

  /// Get dealers from API server
  static Future<DealerResponse> getDealers({
    int page = 1,
    int perPage = 50,
  }) async {
    try {
      final response = await _dio.get(
        '/dealers',
        queryParameters: {
          'page': page.toString(),
          'per_page': perPage.toString(),
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = response.data;

        // Debug: Check response structure
        debugPrint('Dealers API response type: ${responseData.runtimeType}');
        if (responseData is Map) {
          debugPrint('Dealers response keys: ${responseData.keys}');
          if (responseData['data'] is List) {
            debugPrint('Dealers count: ${responseData['data'].length}');
          }
        }

        if (responseData is Map) {
          // API returns object with pagination (standard format)
          // Cast to Map<String, dynamic> to handle _Map internal type
          final mapData = Map<String, dynamic>.from(responseData);
          return DealerResponse.fromJson(mapData);
        } else if (responseData is List) {
          // API returns array directly, wrap it in our expected format
          final wrappedResponse = _wrapDealersArrayResponse(
            responseData.cast<dynamic>(),
            page,
            perPage,
          );
          return DealerResponse.fromJson(wrappedResponse);
        } else {
          throw Exception(
            'Invalid response format: expected List or Map but got ${responseData.runtimeType}',
          );
        }
      } else {
        throw Exception('Failed to load dealers: ${response.statusCode}');
      }
    } catch (e) {
      // Return empty dealers if API call fails
      debugPrint('Error loading dealers: $e');
      return DealerResponse(
        data: [],
        pagination: Pagination(
          resource: 'dealers',
          page: page,
          perPage: perPage,
          total: 0,
          totalPages: 1,
        ),
      );
    }
  }

  /// Update product price via API
  static Future<bool> updateProductPrice({
    required String itemCode,
    required int priceIndex,
    required double newPrice,
  }) async {
    try {
      final response = await _dio.put(
        '/products/$itemCode/price',
        data: {
          'price_index': priceIndex + 1, // API expects 1-based index
          'price': newPrice,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating product price: $e');
      return false;
    }
  }

  /// Create ProductResponse directly from API data (bypassing generated fromJson)
  static ProductResponse _createProductResponseFromApi(
    Map<String, dynamic> apiResponse,
  ) {
    // Create pagination with safe casting
    final paginationData = apiResponse['pagination'] as Map<String, dynamic>;
    final pagination = Pagination(
      resource: paginationData['resource']?.toString() ?? 'products',
      page: _safeToInt(paginationData['page']),
      perPage: _safeToInt(paginationData['per_page']),
      total: _safeToInt(paginationData['total']),
      totalPages: _safeToInt(paginationData['total_pages']),
      nextPage: _safeToIntNullable(paginationData['next_page']),
      prevPage: _safeToIntNullable(paginationData['prev_page']),
    );

    // Transform products
    final List<dynamic> apiProducts = apiResponse['data'] ?? [];
    final products = apiProducts.map((product) {
      // Convert prices from API format to model format
      List<double> prices = [];

      if (product['prices'] != null &&
          product['prices'] is List &&
          product['prices'].isNotEmpty) {
        final priceObj = product['prices'][0];
        if (priceObj is Map<String, dynamic>) {
          prices = [
            _safeToDouble(priceObj['price_1']),
            _safeToDouble(priceObj['price_2']),
            _safeToDouble(priceObj['price_3']),
            _safeToDouble(priceObj['price_4']),
            _safeToDouble(priceObj['price_5']),
          ];
        }
      }

      // Create Product directly
      return Product(
        barcode: product['barcode']?.toString() ?? '',
        itemCode: product['item_code']?.toString() ?? '',
        name: product['name']?.toString() ?? '',
        unitCode: product['unitcode']?.toString() ?? '',
        unitName: product['unitname']?.toString() ?? '',
        prices: prices,
        dealerCode: product['dealer_code']?.toString() ?? '',
        activeDate: product['active_date']?.toString() ?? '',
      );
    }).toList();

    return ProductResponse(pagination: pagination, data: products);
  }

  /// Safely convert dynamic value to double
  /// Handles String, int, double, and null values
  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        debugPrint('Failed to parse "$value" as double: $e');
        return 0.0;
      }
    }

    // For any other type, try to convert to string first then parse
    try {
      return double.parse(value.toString());
    } catch (e) {
      debugPrint(
        'Failed to convert "$value" (${value.runtimeType}) to double: $e',
      );
      return 0.0;
    }
  }

  /// Safely convert dynamic value to int
  static int _safeToInt(dynamic value) {
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
          debugPrint('Failed to parse "$value" as int: $e2');
          return 0;
        }
      }
    }

    try {
      return int.parse(value.toString());
    } catch (e) {
      debugPrint(
        'Failed to convert "$value" (${value.runtimeType}) to int: $e',
      );
      return 0;
    }
  }

  /// Safely convert dynamic value to nullable int
  static int? _safeToIntNullable(dynamic value) {
    if (value == null) return null;
    return _safeToInt(value);
  }

  /// Wrap dealers array response into expected format with pagination
  /// Also handles field mapping from API format to our data model
  static Map<String, dynamic> _wrapDealersArrayResponse(
    List<dynamic> dealersArray,
    int page,
    int perPage,
  ) {
    // Transform dealers with field mapping
    final transformedDealers = dealersArray.map((dealer) {
      if (dealer is Map<String, dynamic>) {
        return {
          // Map API fields to our data model fields
          'dealer_code': _mapDealerCode(dealer),
          'dealer_name': _mapDealerName(dealer),
        };
      }
      return dealer;
    }).toList();

    // Create pagination info
    final totalItems = dealersArray.length;
    final totalPages = (totalItems / perPage).ceil();

    return {
      'pagination': {
        'resource': 'dealers',
        'page': page,
        'per_page': perPage,
        'total': totalItems,
        'total_pages': totalPages,
        'next_page': page < totalPages ? page + 1 : null,
        'prev_page': page > 1 ? page - 1 : null,
      },
      'data': transformedDealers,
    };
  }

  /// Map dealer code from various possible API field names
  static String _mapDealerCode(Map<String, dynamic> dealer) {
    // Try different possible field names for dealer code
    return dealer['dealer_code']?.toString() ??
        dealer['code']?.toString() ??
        dealer['id']?.toString() ??
        'D${dealer['id'] ?? 'UNKNOWN'}';
  }

  /// Map dealer name from various possible API field names
  static String _mapDealerName(Map<String, dynamic> dealer) {
    // Try different possible field names for dealer name
    return dealer['dealer_name']?.toString() ??
        dealer['name']?.toString() ??
        dealer['title']?.toString() ??
        'Unknown Dealer';
  }

  /// Get dealer name by dealer code
  static Future<String> getDealerName(String dealerCode) async {
    try {
      final dealerResponse = await getDealers(perPage: 1000); // Get all dealers
      final dealer = dealerResponse.data.firstWhere(
        (d) => d.dealerCode == dealerCode,
        orElse: () =>
            Dealer(dealerCode: dealerCode, dealerName: 'Unknown Dealer'),
      );
      return dealer.dealerName;
    } catch (e) {
      debugPrint('Error getting dealer name for $dealerCode: $e');
      return 'Unknown Dealer';
    }
  }
}
