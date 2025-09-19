import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/data_model.dart';
import '../services/api_data_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  ProductBloc() : super(const ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<FilterByDealerEvent>(_onFilterByDealer);
    on<ChangeMenuEvent>(_onChangeMenu);
    on<UpdateProductPriceEvent>(_onUpdateProductPrice);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      // Keep current state data if available during pagination
      final currentState = state is ProductLoaded
          ? state as ProductLoaded
          : null;

      // Show loading for initial load, or isLoadingMore for pagination
      if (currentState == null) {
        emit(const ProductLoading());
      } else {
        // Show loading indicator for pagination
        emit(currentState.copyWith(isLoadingMore: true));
      }

      // Load dealers first if we don't have them
      DealerResponse dealerResponse;
      if (currentState?.dealers.isNotEmpty == true) {
        dealerResponse = DealerResponse(
          data: currentState!.dealers,
          pagination: Pagination(
            resource: 'dealers',
            page: 1,
            perPage: 50,
            total: currentState.dealers.length,
            totalPages: 1,
          ),
        );
      } else {
        dealerResponse = await ApiDataService.getDealers();
      }

      // Determine which dealer to use
      String? dealerToUse = event.dealerCode ?? currentState?.selectedDealer;

      // Load products with server-side filtering
      final productResponse = await ApiDataService.getProducts(
        page: event.page,
        perPage: event.perPage,
        dealerCode: dealerToUse,
        search: event.search,
      );

      emit(
        ProductLoaded(
          products: productResponse.data,
          filteredProducts: productResponse.data,
          dealers: dealerResponse.data,
          productPagination: productResponse.pagination,
          selectedDealer: dealerToUse,
          searchQuery: event.search ?? '',
          selectedMenuIndex: currentState?.selectedMenuIndex ?? 0,
          isLoadingMore: false,
        ),
      );

      if (kDebugMode) {
        print('📊 Products loaded:');
        print('   Total from API: ${productResponse.data.length}');
        print('   Page ${event.page}: ${productResponse.data.length} products');
        print('   Selected dealer: $dealerToUse');
        print('   Total available: ${productResponse.pagination.total}');
      }
    } catch (e) {
      emit(ProductError('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e'));
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      // Reload products with new search query from API
      add(
        LoadProductsEvent(
          page: 1, // Reset to first page when searching
          perPage: 10,
          dealerCode: currentState.selectedDealer,
          search: event.query.isEmpty ? null : event.query,
        ),
      );
    }
  }

  Future<void> _onFilterByDealer(
    FilterByDealerEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      try {
        // แสดง loading state ทันที
        emit(
          currentState.copyWith(
            selectedDealer: event.dealerCode,
            isLoadingMore: true,
          ),
        );

        // โหลดข้อมูลสินค้าใหม่จาก API ด้วย server-side filtering
        final productResponse = await ApiDataService.getProducts(
          page: 1,
          perPage: 10,
          dealerCode: event.dealerCode,
          search: currentState.searchQuery,
        );

        // อัพเดท state ด้วยข้อมูลใหม่
        emit(
          currentState.copyWith(
            products: productResponse.data,
            filteredProducts: productResponse.data,
            productPagination: productResponse.pagination,
            selectedDealer: event.dealerCode,
            isLoadingMore: false,
          ),
        );

        if (kDebugMode) {
          print('🔍 Dealer Filter Applied:');
          print('   Selected dealer: ${event.dealerCode}');
          print('   Products returned: ${productResponse.data.length}');
          print('   Total available: ${productResponse.pagination.total}');
        }
      } catch (e) {
        // หากเกิด error ให้กลับไปสถานะเดิม
        emit(currentState.copyWith(isLoadingMore: false));
        debugPrint('Error filtering by dealer: $e');
      }
    }
  }

  void _onChangeMenu(ChangeMenuEvent event, Emitter<ProductState> emit) {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;
      emit(currentState.copyWith(selectedMenuIndex: event.menuIndex));
    }
  }

  Future<void> _onUpdateProductPrice(
    UpdateProductPriceEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductLoaded) {
      final currentState = state as ProductLoaded;

      try {
        // Update price via API service
        final success = await ApiDataService.updateProductPrice(
          itemCode: event.itemCode,
          priceIndex: event.priceIndex,
          newPrice: event.newPrice,
        );

        if (success) {
          // Update local data
          final updatedProducts = currentState.products.map((product) {
            if (product.itemCode == event.itemCode &&
                product.prices.isNotEmpty) {
              final updatedPrices = List<double>.from(product.prices);
              if (event.priceIndex >= 0 &&
                  event.priceIndex < updatedPrices.length) {
                updatedPrices[event.priceIndex] = event.newPrice;
              }

              return Product(
                barcode: product.barcode,
                itemCode: product.itemCode,
                name: product.name,
                unitCode: product.unitCode,
                unitName: product.unitName,
                prices: updatedPrices,
                dealerCode: product.dealerCode,
                activeDate: product.activeDate,
              );
            }
            return product;
          }).toList();

          // Update filtered products to match the current view
          final filteredProducts = updatedProducts;

          emit(
            currentState.copyWith(
              products: updatedProducts,
              filteredProducts: filteredProducts,
            ),
          );
        }
      } catch (e) {
        // Handle error silently or show a snackbar
        debugPrint('Failed to update price: $e');
      }
    }
  }
}
