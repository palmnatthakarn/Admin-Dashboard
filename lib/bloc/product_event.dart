import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  final int page;
  final int perPage;
  final String? dealerCode;
  final String? search;

  const LoadProductsEvent({
    this.page = 1,
    this.perPage = 10,
    this.dealerCode,
    this.search,
  });

  @override
  List<Object?> get props => [page, perPage, dealerCode, search];
}

class SearchProductsEvent extends ProductEvent {
  final String query;

  const SearchProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterByDealerEvent extends ProductEvent {
  final String? dealerCode;

  const FilterByDealerEvent(this.dealerCode);

  @override
  List<Object?> get props => [dealerCode];
}

class ChangeMenuEvent extends ProductEvent {
  final int menuIndex;

  const ChangeMenuEvent(this.menuIndex);

  @override
  List<Object?> get props => [menuIndex];
}

class UpdateProductPriceEvent extends ProductEvent {
  final String itemCode;
  final int priceIndex;
  final double newPrice;

  const UpdateProductPriceEvent({
    required this.itemCode,
    required this.priceIndex,
    required this.newPrice,
  });

  @override
  List<Object?> get props => [itemCode, priceIndex, newPrice];
}
