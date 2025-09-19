import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/api_data_model.dart';

/// Service that uses API data model directly (no transformation needed)
class DirectApiService {
  static const String baseUrl = 'http://192.168.2.52:3000/api';

  // Dio instance with default configuration
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  /// Get products using direct API model (no transformation)
  static Future<ApiProductResponse> getProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    String? dealerCode,
  }) async {
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

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = response.data;

        // Direct deserialization - no transformation needed!
        return ApiProductResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading products: $e');

      // Return empty response
      return ApiProductResponse(
        data: [],
        pagination: ApiPagination(
          resource: 'products',
          page: page,
          perPage: perPage,
          total: 0,
          totalPages: 1,
        ),
      );
    }
  }

  /// Get dealers using direct API model with array wrapper
  static Future<ApiDealerResponse> getDealers({
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

        if (responseData is Map<String, dynamic>) {
          // Standard format with pagination
          return ApiDealerResponse.fromJson(responseData);
        } else if (responseData is List<dynamic>) {
          // API returns array directly, wrap it
          final dealers = responseData
              .map((item) => ApiDealer.fromJson(item as Map<String, dynamic>))
              .toList();

          return ApiDealerResponse(
            data: dealers,
            pagination: ApiPagination(
              resource: 'dealers',
              page: page,
              perPage: perPage,
              total: dealers.length,
              totalPages: (dealers.length / perPage).ceil(),
              nextPage: page < (dealers.length / perPage).ceil()
                  ? page + 1
                  : null,
              prevPage: page > 1 ? page - 1 : null,
            ),
          );
        } else {
          throw Exception(
            'Invalid response format: ${responseData.runtimeType}',
          );
        }
      } else {
        throw Exception('Failed to load dealers: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading dealers: $e');

      // Return empty dealers if API call fails
      return ApiDealerResponse(
        data: [],
        pagination: ApiPagination(
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
}
