import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'components/sidebar.dart';
import 'components/top_bar.dart';
import 'widgets/stat_card.dart';
import 'widgets/products_table.dart';
import 'models/menu_item.dart';
import 'bloc/product_bloc.dart';
import 'bloc/product_event.dart';
import 'bloc/product_state.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<MenuItem> menuItems = [
    MenuItem(
      Icons.inventory_2_outlined,
      Icons.inventory_2,
      'สินค้า',
      const Color(0xFF6366F1), // Indigo
    ),
    MenuItem(
      Icons.store_outlined,
      Icons.store,
      'ร้านค้า',
      const Color(0xFF8B5CF6), // Violet
    ),
    MenuItem(
      Icons.analytics_outlined,
      Icons.analytics,
      'รายงาน',
      const Color(0xFF06B6D4), // Cyan
    ),
    MenuItem(
      Icons.settings_outlined,
      Icons.settings,
      'ตั้งค่า',
      const Color(0xFF10B981), // Emerald
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load data when widget initializes - will auto-select first dealer
    context.read<ProductBloc>().add(const LoadProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: MediaQuery.of(context).size.width < 1024
          ? Drawer(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final selectedIndex = state is ProductLoaded
                      ? state.selectedMenuIndex
                      : 0;

                  return ModernSidebar(
                    menuItems: menuItems,
                    selectedMenuIndex: selectedIndex,
                    onMenuSelected: (index) {
                      context.read<ProductBloc>().add(ChangeMenuEvent(index));
                      Navigator.of(context).pop(); // Close drawer
                    },
                  );
                },
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 1024) {
            // Mobile/Tablet layout with drawer
            return _buildMainContent();
          } else {
            // Desktop layout with sidebar
            return Row(
              children: [
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    final selectedIndex = state is ProductLoaded
                        ? state.selectedMenuIndex
                        : 0;

                    return ModernSidebar(
                      menuItems: menuItems,
                      selectedMenuIndex: selectedIndex,
                      onMenuSelected: (index) {
                        context.read<ProductBloc>().add(ChangeMenuEvent(index));
                      },
                    );
                  },
                ),
                Expanded(child: _buildMainContent()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final selectedIndex = state is ProductLoaded
            ? state.selectedMenuIndex
            : 0;

        return Column(
          children: [
            TopBar(
              menuItems: menuItems,
              selectedMenuIndex: selectedIndex,
              onSearchChanged: (query) {
                context.read<ProductBloc>().add(SearchProductsEvent(query));
              },
            ),
            Expanded(
              child: selectedIndex == 0
                  ? _buildProductsContent()
                  : _buildOtherContent(selectedIndex),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsContent() {
    return BlocConsumer<ProductBloc, ProductState>(
      listener: (context, state) {
        if (state is ProductError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('กำลังโหลดข้อมูล...'),
              ],
            ),
          );
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('เกิดข้อผิดพลาด', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductBloc>().add(const LoadProductsEvent());
                  },
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          );
        }

        if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ไม่พบข้อมูลสินค้า', style: TextStyle(fontSize: 18)),
                  Text(
                    'กรุณาตรวจสอบไฟล์ข้อมูล',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 600 ? 8 : 16,
            ),
            child: Column(
              children: [
                // Mobile search bar
                if (MediaQuery.of(context).size.width <= 800) ...[
                  _buildMobileSearchBar(),
                  const SizedBox(height: 16),
                ],
                _buildFiltersRow(state),
                const SizedBox(height: 24),

                Expanded(
                  child: state.filteredProducts.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'ไม่พบสินค้าที่ค้นหา',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                'ลองเปลี่ยนคำค้นหาหรือตัวกรอง',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ProductsTable(
                          filteredProducts: state.filteredProducts,
                          productPagination: state.productPagination,
                          dealers: state.dealers,
                          selectedDealer: state.selectedDealer,
                          onDealerChanged: (dealerCode) {
                            context.read<ProductBloc>().add(
                              FilterByDealerEvent(dealerCode),
                            );
                          },
                          onPageChanged: (page) {
                            context.read<ProductBloc>().add(
                              LoadProductsEvent(
                                page: page,
                                perPage: 10,
                                dealerCode: state.selectedDealer,
                                search: state.searchQuery,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildMobileSearchBar() {
    final theme = Theme.of(context);

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (query) {
          context.read<ProductBloc>().add(SearchProductsEvent(query));
        },
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'ค้นหาสินค้า, รหัสสินค้า หรือ barcode...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFiltersRow(ProductLoaded state) {
    // Now only show stats cards since DealerFilter is moved to ProductsTable header
    return _buildStatsCards(state);
  }

  Widget _buildStatsCards(ProductLoaded state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get parent constraints to determine layout
        final parentWidth = MediaQuery.of(context).size.width;

        if (parentWidth < 600) {
          // Very small screens: Single column
          return Column(
            children: [
              StatCard(
                title: 'สินค้าทั้งหมด',
                value:
                    '${state.productPagination?.total ?? state.products.length}',
                icon: Icons.inventory_2,
                color: const Color(0xFF6366F1), // Indigo
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'ร้านค้า',
                      value: '${state.dealers.length}',
                      icon: Icons.store,
                      color: const Color(0xFF8B5CF6), // Violet
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      title: 'แสดงผล',
                      value: '${state.filteredProducts.length}',
                      icon: Icons.visibility,
                      color: const Color(0xFF06B6D4), // Cyan
                    ),
                  ),
                ],
              ),
            ],
          );
        } else if (parentWidth < 500) {
          // Medium screens: 2x2 grid or horizontal
          return Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'สินค้าทั้งหมด',
                  value:
                      '${state.productPagination?.total ?? state.products.length}',
                  icon: Icons.inventory_2,
                  color: const Color(0xFF6366F1), // Indigo
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'ร้านค้า',
                  value: '${state.dealers.length}',
                  icon: Icons.store,
                  color: const Color(0xFF8B5CF6), // Violet
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatCard(
                  title: 'แสดงผล',
                  value: '${state.filteredProducts.length}',
                  icon: Icons.visibility,
                  color: const Color(0xFF06B6D4), // Cyan
                ),
              ),
            ],
          );
        } else {
          // Large screens: Horizontal layout
          return Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'สินค้าทั้งหมด',
                  value:
                      '${state.productPagination?.total ?? state.products.length}',
                  icon: Icons.inventory_2,
                  color: const Color(0xFF6366F1), // Indigo
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'ร้านค้า',
                  value: '${state.dealers.length}',
                  icon: Icons.store,
                  color: const Color(0xFF8B5CF6), // Violet
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  title: 'แสดงผล',
                  value: '${state.filteredProducts.length}',
                  icon: Icons.visibility,
                  color: const Color(0xFF06B6D4), // Cyan
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildOtherContent(int selectedIndex) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            menuItems[selectedIndex].icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'เนื้อหาของ${menuItems[selectedIndex].title}',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'กำลังพัฒนา...',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
