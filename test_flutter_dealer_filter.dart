import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'lib/bloc/product_bloc.dart';
import 'lib/bloc/product_event.dart';
import 'lib/bloc/product_state.dart';

void main() {
  runApp(TestDealerFilterApp());
}

class TestDealerFilterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Dealer Filter',
      home: BlocProvider(
        create: (context) => ProductBloc()..add(LoadProductsEvent()),
        child: TestDealerFilterPage(),
      ),
    );
  }
}

class TestDealerFilterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Dealer Filter'),
        backgroundColor: Colors.blue,
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(LoadProductsEvent());
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductLoaded) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dealer Filter
                  Text(
                    'Select Dealer:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: state.selectedDealer,
                      isExpanded: true,
                      underline: SizedBox(),
                      hint: Text('Select a dealer'),
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Dealers'),
                        ),
                        ...state.dealers.map((dealer) {
                          return DropdownMenuItem<String>(
                            value: dealer.dealerCode,
                            child: Text(
                              '${dealer.dealerName} (${dealer.dealerCode})',
                            ),
                          );
                        }),
                      ],
                      onChanged: (dealerCode) {
                        context.read<ProductBloc>().add(
                          FilterByDealerEvent(dealerCode),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 24),

                  // Results Summary
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Results Summary:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Selected Dealer: ${state.selectedDealer ?? "All"}',
                        ),
                        Text(
                          'Total Products: ${state.productPagination?.total ?? 0}',
                        ),
                        Text(
                          'Showing: ${state.filteredProducts.length} products',
                        ),
                        Text(
                          'Page: ${state.productPagination?.page ?? 1} of ${state.productPagination?.totalPages ?? 1}',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Products List
                  Text(
                    'Products:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),

                  Expanded(
                    child: state.isLoadingMore
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: state.filteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = state.filteredProducts[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  title: Text(product.name),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Code: ${product.itemCode}'),
                                      Text('Dealer: ${product.dealerCode}'),
                                      Text(
                                        'Price: ฿${product.mainPrice.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Pagination
                  if (state.productPagination != null &&
                      state.productPagination!.totalPages > 1)
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: state.productPagination!.prevPage != null
                                ? () {
                                    context.read<ProductBloc>().add(
                                      LoadProductsEvent(
                                        page:
                                            state.productPagination!.prevPage!,
                                        dealerCode: state.selectedDealer,
                                        search: state.searchQuery,
                                      ),
                                    );
                                  }
                                : null,
                            child: Text('Previous'),
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Page ${state.productPagination!.page} of ${state.productPagination!.totalPages}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: state.productPagination!.nextPage != null
                                ? () {
                                    context.read<ProductBloc>().add(
                                      LoadProductsEvent(
                                        page:
                                            state.productPagination!.nextPage!,
                                        dealerCode: state.selectedDealer,
                                        search: state.searchQuery,
                                      ),
                                    );
                                  }
                                : null,
                            child: Text('Next'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }

          return Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
