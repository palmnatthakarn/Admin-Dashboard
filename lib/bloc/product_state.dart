import 'package:equatable/equatable.dart';
import '../models/data_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<Dealer> dealers;
  final Pagination? productPagination;
  final String searchQuery;
  final String? selectedDealer;
  final int selectedMenuIndex;
  final bool isLoadingMore;

  const ProductLoaded({
    required this.products,
    required this.filteredProducts,
    required this.dealers,
    this.productPagination,
    this.searchQuery = '',
    this.selectedDealer,
    this.selectedMenuIndex = 0,
    this.isLoadingMore = false,
  });

  ProductLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<Dealer>? dealers,
    Pagination? productPagination,
    String? searchQuery,
    String? selectedDealer,
    int? selectedMenuIndex,
    bool? isLoadingMore,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      dealers: dealers ?? this.dealers,
      productPagination: productPagination ?? this.productPagination,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedDealer: selectedDealer ?? this.selectedDealer,
      selectedMenuIndex: selectedMenuIndex ?? this.selectedMenuIndex,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    products,
    filteredProducts,
    dealers,
    productPagination,
    searchQuery,
    selectedDealer,
    selectedMenuIndex,
    isLoadingMore,
  ];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
