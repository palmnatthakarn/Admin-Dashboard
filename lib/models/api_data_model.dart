import 'package:json_annotation/json_annotation.dart';

/// Alternative data model that matches API structure exactly
part 'api_data_model.g.dart';

@JsonSerializable()
class ApiPagination {
  final String resource;
  @JsonKey(fromJson: _safeToInt)
  final int page;
  @JsonKey(name: 'per_page', fromJson: _safeToInt)
  final int perPage;
  @JsonKey(fromJson: _safeToInt)
  final int total;
  @JsonKey(name: 'total_pages', fromJson: _safeToInt)
  final int totalPages;
  @JsonKey(name: 'next_page', fromJson: _safeToIntNullable)
  final int? nextPage;
  @JsonKey(name: 'prev_page', fromJson: _safeToIntNullable)
  final int? prevPage;

  ApiPagination({
    required this.resource,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    this.nextPage,
    this.prevPage,
  });

  factory ApiPagination.fromJson(Map<String, dynamic> json) =>
      _$ApiPaginationFromJson(json);
  Map<String, dynamic> toJson() => _$ApiPaginationToJson(this);

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
          return 0;
        }
      }
    }
    try {
      return int.parse(value.toString());
    } catch (e) {
      return 0;
    }
  }

  /// Safely convert dynamic value to nullable int
  static int? _safeToIntNullable(dynamic value) {
    if (value == null) return null;
    return _safeToInt(value);
  }
}

@JsonSerializable()
class ApiPrice {
  @JsonKey(name: 'price_1', fromJson: _safeToDouble)
  final double price1;
  @JsonKey(name: 'price_2', fromJson: _safeToDouble)
  final double price2;
  @JsonKey(name: 'price_3', fromJson: _safeToDouble)
  final double price3;
  @JsonKey(name: 'price_4', fromJson: _safeToDouble)
  final double price4;
  @JsonKey(name: 'price_5', fromJson: _safeToDouble)
  final double price5;

  ApiPrice({
    required this.price1,
    required this.price2,
    required this.price3,
    required this.price4,
    required this.price5,
  });

  factory ApiPrice.fromJson(Map<String, dynamic> json) =>
      _$ApiPriceFromJson(json);
  Map<String, dynamic> toJson() => _$ApiPriceToJson(this);

  /// Convert to list format for compatibility
  List<double> toList() => [price1, price2, price3, price4, price5];

  /// Safely convert dynamic value to double
  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    try {
      return double.parse(value.toString());
    } catch (e) {
      return 0.0;
    }
  }
}

@JsonSerializable()
class ApiProduct {
  final String barcode;
  @JsonKey(name: 'item_code')
  final String itemCode;
  final String name;
  @JsonKey(name: 'unitcode')
  final String unitCode;
  @JsonKey(name: 'unitname')
  final String unitName;
  final List<ApiPrice> prices; // Array of price objects (matches API)
  @JsonKey(name: 'dealer_code')
  final String dealerCode;
  @JsonKey(name: 'active_date')
  final String activeDate;

  ApiProduct({
    required this.barcode,
    required this.itemCode,
    required this.name,
    required this.unitCode,
    required this.unitName,
    required this.prices,
    required this.dealerCode,
    required this.activeDate,
  });

  factory ApiProduct.fromJson(Map<String, dynamic> json) =>
      _$ApiProductFromJson(json);
  Map<String, dynamic> toJson() => _$ApiProductToJson(this);

  // Getter สำหรับราคาหลัก
  double get mainPrice => prices.isNotEmpty ? prices[0].price1 : 0.0;

  // Method สำหรับดึงราคาตาม index (0-4)
  double getPriceByIndex(int index) {
    if (prices.isEmpty) return 0.0;
    final priceObj = prices[0];
    switch (index) {
      case 0:
        return priceObj.price1;
      case 1:
        return priceObj.price2;
      case 2:
        return priceObj.price3;
      case 3:
        return priceObj.price4;
      case 4:
        return priceObj.price5;
      default:
        return 0.0;
    }
  }

  // Get all prices as list for compatibility
  List<double> get pricesList => prices.isNotEmpty ? prices[0].toList() : [];

  // Method สำหรับค้นหา
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        itemCode.toLowerCase().contains(lowerQuery) ||
        barcode.toLowerCase().contains(lowerQuery);
  }

  // Method สำหรับกรองตาม dealer
  bool matchesDealer(String? dealerCode) {
    if (dealerCode == null || dealerCode.isEmpty) return true;
    return this.dealerCode == dealerCode;
  }
}

@JsonSerializable()
class ApiProductResponse {
  final ApiPagination pagination;
  final List<ApiProduct> data;

  ApiProductResponse({required this.pagination, required this.data});

  factory ApiProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiProductResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiProductResponseToJson(this);
}

@JsonSerializable()
class ApiDealer {
  @JsonKey(name: 'dealer_code')
  final String dealerCode;
  @JsonKey(name: 'dealer_name')
  final String dealerName;

  ApiDealer({required this.dealerCode, required this.dealerName});

  factory ApiDealer.fromJson(Map<String, dynamic> json) =>
      _$ApiDealerFromJson(json);
  Map<String, dynamic> toJson() => _$ApiDealerToJson(this);

  @override
  String toString() => '$dealerCode - $dealerName';
}

/// Wrapper for dealers array response
@JsonSerializable()
class ApiDealerResponse {
  final ApiPagination pagination;
  final List<ApiDealer> data;

  ApiDealerResponse({required this.pagination, required this.data});

  factory ApiDealerResponse.fromJson(Map<String, dynamic> json) =>
      _$ApiDealerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiDealerResponseToJson(this);
}
