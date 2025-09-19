import 'package:json_annotation/json_annotation.dart';

/// This allows the classes to access private members in
/// the generated file. The value for this is *.g.dart, where
/// the star denotes the source file name.
part 'data_model.g.dart';

@JsonSerializable()
class Pagination {
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

  Pagination({
    required this.resource,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
    this.nextPage,
    this.prevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) =>
      _$PaginationFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationToJson(this);

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
class Price {
  @JsonKey(name: 'price_1')
  final double price1;
  @JsonKey(name: 'price_2')
  final double price2;
  @JsonKey(name: 'price_3')
  final double price3;
  @JsonKey(name: 'price_4')
  final double price4;
  @JsonKey(name: 'price_5')
  final double price5;

  Price({
    required this.price1,
    required this.price2,
    required this.price3,
    required this.price4,
    required this.price5,
  });

  factory Price.fromJson(Map<String, dynamic> json) => _$PriceFromJson(json);
  Map<String, dynamic> toJson() => _$PriceToJson(this);
}

@JsonSerializable()
class Product {
  final String barcode;
  @JsonKey(name: 'item_code')
  final String itemCode;
  final String name;
  @JsonKey(name: 'unitcode')
  final String unitCode;
  @JsonKey(name: 'unitname')
  final String unitName;
  final List<double> prices;
  @JsonKey(name: 'dealer_code')
  final String dealerCode;
  @JsonKey(name: 'active_date')
  final String activeDate;

  Product({
    required this.barcode,
    required this.itemCode,
    required this.name,
    required this.unitCode,
    required this.unitName,
    required this.prices,
    required this.dealerCode,
    required this.activeDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  // Getter สำหรับราคาหลัก
  double get mainPrice => prices.isNotEmpty ? prices[0] : 0.0;

  // Method สำหรับดึงราคาตาม index (0-4)
  double getPriceByIndex(int index) {
    if (prices.isEmpty || index < 0 || index >= prices.length) return 0.0;
    return prices[index];
  }

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
class ProductResponse {
  final Pagination pagination;
  final List<Product> data;

  ProductResponse({required this.pagination, required this.data});

  factory ProductResponse.fromJson(Map<String, dynamic> json) =>
      _$ProductResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductResponseToJson(this);
}

@JsonSerializable()
class Dealer {
  @JsonKey(name: 'dealer_code')
  final String dealerCode;
  @JsonKey(name: 'dealer_name')
  final String dealerName;

  Dealer({required this.dealerCode, required this.dealerName});

  factory Dealer.fromJson(Map<String, dynamic> json) => _$DealerFromJson(json);
  Map<String, dynamic> toJson() => _$DealerToJson(this);

  @override
  String toString() => '$dealerCode - $dealerName';
}

@JsonSerializable()
class DealerResponse {
  final Pagination pagination;
  final List<Dealer> data;

  DealerResponse({required this.pagination, required this.data});

  factory DealerResponse.fromJson(Map<String, dynamic> json) =>
      _$DealerResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DealerResponseToJson(this);
}
