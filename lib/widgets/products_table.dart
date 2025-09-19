import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/bloc/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data_table_2/data_table_2.dart';
import '../models/data_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import 'dealer_filter.dart';
import 'product_details_popup.dart';

class ProductsTable extends StatefulWidget {
  final List<Product> filteredProducts;
  final Pagination? productPagination;
  final List<Dealer> dealers;
  final String? selectedDealer;
  final Function(String?) onDealerChanged;
  final Function(int)? onPageChanged;

  const ProductsTable({
    super.key,
    required this.filteredProducts,
    required this.productPagination,
    required this.dealers,
    required this.selectedDealer,
    required this.onDealerChanged,
    this.onPageChanged,
  });

  @override
  State<ProductsTable> createState() => _ProductsTableState();
}

class _ProductsTableState extends State<ProductsTable> {
  String sortBy = 'name';
  bool sortAscending = true;
  List<Product> sortedProducts = [];
  final int _rowsPerPage = 10;

  Map<String, List<TextEditingController>> priceControllers = {};

  @override
  void initState() {
    super.initState();
    sortedProducts = List.from(widget.filteredProducts);
    _initializePriceControllers();
    _applySorting();
  }

  void _initializePriceControllers() {
    priceControllers.clear();
    for (var product in widget.filteredProducts) {
      priceControllers[product.itemCode] = List.generate(5, (index) {
        return TextEditingController(
          text: product.getPriceByIndex(index).toStringAsFixed(2),
        );
      });
    }
  }

  @override
  void didUpdateWidget(ProductsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filteredProducts != widget.filteredProducts) {
      sortedProducts = List.from(widget.filteredProducts);
      _initializePriceControllers();
      _applySorting();
    }
  }

  @override
  void dispose() {
    for (var controllers in priceControllers.values) {
      for (var controller in controllers) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Color _getUnitColor(String unitName) {
    switch (unitName.toLowerCase()) {
      case 'กิโลกรัม':
      case 'kg':
        return Colors.green.shade600;
      case 'กรัม':
      case 'g':
        return Colors.green.shade500;
      case 'ชิ้น':
      case 'pcs':
        return Colors.orange.shade600;
      case 'ลิตร':
      case 'l':
        return Colors.blue.shade600;
      case 'มิลลิลิตร':
      case 'ml':
        return Colors.blue.shade500;
      default:
        return Colors.grey.shade600;
    }
  }

  void _updatePrice(Product product, int priceIndex, String newValue) {
    try {
      final newPrice = double.parse(newValue);
      if (newPrice >= 0) {
        context.read<ProductBloc>().add(
          UpdateProductPriceEvent(
            itemCode: product.itemCode,
            priceIndex: priceIndex,
            newPrice: newPrice,
          ),
        );
      }
    } catch (e) {
      priceControllers[product.itemCode]?[priceIndex].text = product
          .getPriceByIndex(priceIndex)
          .toStringAsFixed(2);
    }
  }

  void _applySorting() {
    setState(() {
      sortedProducts.sort((a, b) {
        int result = 0;
        switch (sortBy) {
          case 'itemCode':
            result = a.itemCode.compareTo(b.itemCode);
            break;
          case 'name':
            result = a.name.compareTo(b.name);
            break;
          case 'price1':
            result = a.getPriceByIndex(0).compareTo(b.getPriceByIndex(0));
            break;
          case 'price2':
            result = a.getPriceByIndex(1).compareTo(b.getPriceByIndex(1));
            break;
          case 'price3':
            result = a.getPriceByIndex(2).compareTo(b.getPriceByIndex(2));
            break;
          case 'price4':
            result = a.getPriceByIndex(3).compareTo(b.getPriceByIndex(3));
            break;
          case 'price5':
            result = a.getPriceByIndex(4).compareTo(b.getPriceByIndex(4));
            break;
          case 'dealer':
            result = a.dealerCode.compareTo(b.dealerCode);
            break;
          case 'date':
            result = a.activeDate.compareTo(b.activeDate);
            break;
          default:
            result = a.name.compareTo(b.name);
        }
        return sortAscending ? result : -result;
      });
    });
  }

  List<Product> get _paginatedProducts {
    // ใช้ข้อมูลจาก API โดยตรง - API ได้ filter และ paginate แล้ว
    // เราแค่ต้อง sort ข้อมูลที่ได้รับมา
    if (kDebugMode) {
      print('_paginatedProducts - Total: ${sortedProducts.length}');
      print('_paginatedProducts - Selected dealer: ${widget.selectedDealer}');
    }
    return sortedProducts;
  }

  int get _totalPages => widget.productPagination?.totalPages ?? 1;

  int get _currentPage => widget.productPagination?.page ?? 1; // Keep 1-based

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Debug: Check dealer data consistency
    if (kDebugMode) {
      print('ProductsTable - Dealers count: ${widget.dealers.length}');
      print('ProductsTable - Selected dealer: ${widget.selectedDealer}');
      if (widget.dealers.isNotEmpty) {
        print(
          'ProductsTable - First dealer: ${widget.dealers.first.dealerCode} - ${widget.dealers.first.dealerName}',
        );
      }
    }

    return Column(
      children: [
        _buildTableHeader(),
        Expanded(
          child: Container(
            //color: Colors.amber,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: DataTable2(
                showCheckboxColumn: false,
                columnSpacing: 8,
                horizontalMargin: 0,
                minWidth: 1200,
                dataRowHeight: 42,
                headingRowHeight: 50,
                headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 13,
                ),
                dataTextStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                ),
                sortColumnIndex: _getSortColumnIndex(),
                sortAscending: sortAscending,
                columns: [
                  DataColumn2(
                    label: const Center(child: Text('Barcode')),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: const Center(child: Text('รหัสสินค้า')),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) =>
                        _onSort('itemCode', ascending),
                  ),
                  DataColumn2(
                    label: const Center(child: Text('ชื่อสินค้า')),
                    size: ColumnSize.L,
                    onSort: (columnIndex, ascending) =>
                        _onSort('name', ascending),
                  ),
                  DataColumn2(
                    label: const Center(child: Text('หน่วย')),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: const Center(child: Text('ราคา 1')),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) =>
                        _onSort('price1', ascending),
                  ),
                  DataColumn2(
                    label: const Center(child: Text('ราคา 2')),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) =>
                        _onSort('price2', ascending),
                  ),
                  DataColumn2(
                    label: const Center(child: Text('ราคา 3')),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) =>
                        _onSort('price3', ascending),
                  ),
                  DataColumn2(
                    label: const Center(child: Text('ราคา 4')),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) =>
                        _onSort('price4', ascending),
                  ),
                  DataColumn2(
                    label: const Center(child: Text('ราคา 5')),
                    size: ColumnSize.S,
                    onSort: (columnIndex, ascending) =>
                        _onSort('price5', ascending),
                  ),
                  DataColumn2(
                    label: const Center(child: Text('วันที่')),
                    size: ColumnSize.M,
                    onSort: (columnIndex, ascending) =>
                        _onSort('date', ascending),
                  ),
                ],
                rows: _paginatedProducts
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildDataRow(entry.value, theme, entry.key),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        _buildCustomPagination(),
      ],
    );
  }

  void _showRowMenu(Product product) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('ดูรายละเอียด (${product.itemCode})'),
              subtitle: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.pop(ctx, 'view'),
            ),
            ListTile(
              leading: const Icon(Icons.price_change_outlined),
              title: const Text('แก้ไขราคา'),
              onTap: () => Navigator.pop(ctx, 'edit_price'),
            ),
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('คัดลอกบาร์โค้ด'),
              onTap: () => Navigator.pop(ctx, 'copy_barcode'),
            ),
            const Divider(height: 0),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'ลบสินค้า',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(ctx, 'delete'),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );

    if (!mounted || action == null) return;

    switch (action) {
      case 'view':
        ProductDetailsPopup.show(context, product);
        break;
      case 'edit_price':
        // เปิด editor ของคุณ (ตัวอย่างเรียก cell editor เดิม index 0)
        _openPriceEditor(product);
        break;
      case 'copy_barcode':
        Clipboard.setData(ClipboardData(text: product.barcode));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('คัดลอกบาร์โค้ดแล้ว')));
        break;
      case 'delete':
        _confirmDelete(product);
        break;
    }
  }

  // ตัวอย่าง helper – ใช้ editor เดิมของคุณแทนได้
  void _openPriceEditor(Product product) {
    // คุณอาจจะเปิด dialog แก้ราคา หรือโฟกัสไปที่ cell แรก
    // เช่น เรียก _buildEditablePriceCell(...) ของคุณแบบ popup
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('แก้ไขราคา: ${product.itemCode}'),
        content: _buildEditablePriceCell(product, 0, Theme.of(context)),
      ),
    );
  }

  void _confirmDelete(Product product) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ลบ ${product.itemCode} - ${product.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
    if (ok == true) {
      setState(() {
        // ลบจากแหล่งข้อมูลของคุณ
        // เช่น widget.filteredProducts.removeWhere((p) => p.itemCode == product.itemCode);
        // หรือ trigger bloc/event ให้ลบ แล้ว refresh ตาราง
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบสินค้าแล้ว')));
    }
  }

  DataRow _buildDataRow(Product product, ThemeData theme, int index) {
    return DataRow(
      onSelectChanged: (selected) {
        if (selected == true) {
          ProductDetailsPopup.show(context, product);
        }
      },
      // ✅ mobile/tablet: long press
      onLongPress: () {
        _showRowMenu(product);
      },
      // ✅ เปลี่ยน cursor เมื่อ hover
      mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
      color: WidgetStateProperty.resolveWith<Color?>((states) {
        if (index.isEven) return Colors.white;
        return Colors.grey.shade50;
      }),
      cells: [
        DataCell(
          GestureDetector(
            onSecondaryTap: () =>
                _showRowMenu(product), // ✅ desktop: right click
            child: Center(
              child: Text(
                product.barcode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            onSecondaryTap: () => _showRowMenu(product),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Text(
                  product.itemCode,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            onSecondaryTap: () => _showRowMenu(product),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                product.name,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        DataCell(
          GestureDetector(
            onSecondaryTap: () => _showRowMenu(product),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getUnitColor(product.unitName).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getUnitColor(
                      product.unitName,
                    ).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  product.unitName,
                  style: TextStyle(
                    color: _getUnitColor(product.unitName),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ),
        ),
        // ถ้าต้องการ right-click ราคา → ครอบ _buildEditablePriceCell ด้วย GestureDetector เช่นกัน
        DataCell(_buildEditablePriceCell(product, 0, theme)),
        DataCell(_buildEditablePriceCell(product, 1, theme)),
        DataCell(_buildEditablePriceCell(product, 2, theme)),
        DataCell(_buildEditablePriceCell(product, 3, theme)),
        DataCell(_buildEditablePriceCell(product, 4, theme)),
        DataCell(
          GestureDetector(
            onSecondaryTap: () => _showRowMenu(product),
            child: Center(
              child: Text(
                product.activeDate,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomPagination() {
    final totalItems = widget.productPagination?.total ?? 0;
    final perPage = widget.productPagination?.perPage ?? _rowsPerPage;
    final currentPage = widget.productPagination?.page ?? 1;

    final startIndex = totalItems == 0 ? 0 : (currentPage - 1) * perPage + 1;
    final endIndex = totalItems == 0
        ? 0
        : (currentPage * perPage).clamp(0, totalItems);

    // แสดงข้อมูล dealer ที่เลือกใน pagination
    final dealerInfo = widget.selectedDealer != null
        ? widget.dealers.firstWhere(
            (d) => d.dealerCode == widget.selectedDealer,
            orElse: () => Dealer(
              dealerCode: widget.selectedDealer!,
              dealerName: 'ไม่ทราบชื่อ',
            ),
          )
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                totalItems == 0
                    ? 'แสดง 0 ถึง 0 รายการ'
                    : 'แสดง $startIndex ถึง $endIndex จาก $totalItems รายการ',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              if (dealerInfo != null) ...[
                const SizedBox(height: 2),
                Text(
                  'ร้าน: ${dealerInfo.dealerName} (${dealerInfo.dealerCode})',
                  style: TextStyle(
                    color: Colors.blue.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 8,
            children: [
              // First page button (<<)
              _buildPaginationIconButton('<<', _currentPage > 1, () {
                if (_currentPage > 1) {
                  widget.onPageChanged?.call(1);
                }
              }),
              // Previous page button (<)
              _buildPaginationIconButton('<', _currentPage > 1, () {
                if (_currentPage > 1) {
                  widget.onPageChanged?.call(_currentPage - 1);
                }
              }),
              ..._buildPageNumbers(),
              // Next page button (>)
              _buildPaginationIconButton('>', _currentPage < _totalPages, () {
                if (_currentPage < _totalPages) {
                  widget.onPageChanged?.call(_currentPage + 1);
                }
              }),
              // Last page button (>>)
              _buildPaginationIconButton('>>', _currentPage < _totalPages, () {
                if (_currentPage < _totalPages) {
                  widget.onPageChanged?.call(_totalPages);
                }
              }),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageNumbers = [];

    if (_totalPages <= 0) {
      return pageNumbers;
    }

    const int maxVisiblePages = 5;
    int currentPage = _currentPage; // Already 1-based

    if (_totalPages <= maxVisiblePages) {
      // แสดงทุกหน้าถ้าไม่เกิน maxVisiblePages
      for (int i = 1; i <= _totalPages; i++) {
        pageNumbers.add(_buildPageButton(i, currentPage == i));
      }
    } else {
      // แสดงหน้าแรก
      pageNumbers.add(_buildPageButton(1, currentPage == 1));

      if (currentPage > 3) {
        // แสดง ... ถ้าหน้าปัจจุบันห่างจากหน้าแรก
        pageNumbers.add(_buildEllipsis());
      }

      // แสดงหน้าใกล้เคียงกับหน้าปัจจุบัน
      int start = (currentPage - 1).clamp(2, _totalPages - 1);
      int end = (currentPage + 1).clamp(2, _totalPages - 1);

      for (int i = start; i <= end; i++) {
        if (i != 1 && i != _totalPages) {
          pageNumbers.add(_buildPageButton(i, currentPage == i));
        }
      }

      if (currentPage < _totalPages - 2) {
        // แสดง ... ถ้าหน้าปัจจุบันห่างจากหน้าสุดท้าย
        pageNumbers.add(_buildEllipsis());
      }

      // แสดงหน้าสุดท้าย
      if (_totalPages > 1) {
        pageNumbers.add(
          _buildPageButton(_totalPages, currentPage == _totalPages),
        );
      }
    }

    return pageNumbers;
  }

  Widget _buildPageButton(int pageNumber, bool isActive) {
    return GestureDetector(
      onTap: () {
        widget.onPageChanged?.call(pageNumber);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.shade400 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.blue.shade400 : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          '$pageNumber',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: const Text(
        '...',
        style: TextStyle(
          color: Colors.black54,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildPaginationIconButton(
    String text,
    bool enabled,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.black87 : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  int? _getSortColumnIndex() {
    switch (sortBy) {
      case 'itemCode':
        return 1;
      case 'name':
        return 2;
      case 'price1':
        return 4;
      case 'price2':
        return 5;
      case 'price3':
        return 6;
      case 'price4':
        return 7;
      case 'price5':
        return 8;
      case 'date':
        return 9;
      default:
        return null;
    }
  }

  void _onSort(String column, bool ascending) {
    setState(() {
      sortBy = column;
      sortAscending = ascending;
      _applySorting();
    });
  }

  Widget _buildEditablePriceCell(
    Product product,
    int priceIndex,
    ThemeData theme,
  ) {
    final controller = priceControllers[product.itemCode]?[priceIndex];

    if (controller == null) {
      return Center(
        child: Text(
          '฿${product.getPriceByIndex(priceIndex).toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      width: 85,
      //height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          prefix: const Text(
            '฿',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade600, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 4,
          ),
          isDense: true,
        ),
        onFieldSubmitted: (value) {
          _updatePrice(product, priceIndex, value);
        },
        onEditingComplete: () {
          _updatePrice(product, priceIndex, controller.text);
        },
        onTapOutside: (event) {
          _updatePrice(product, priceIndex, controller.text);
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 200,
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final isLoading = state is ProductLoaded && state.isLoadingMore;
                return DealerFilter(
                  selectedDealer: widget.selectedDealer,
                  dealers: widget.dealers,
                  onDealerChanged: widget.onDealerChanged,
                  isLoading: isLoading, // ⚡ ส่ง loading state
                );
              },
            ),
          ),

          const Spacer(),
          // Sort dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: sortBy,
              isDense: true,
              underline: const SizedBox(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              icon: const Icon(Icons.sort, size: 16),
              items: const [
                DropdownMenuItem(value: 'name', child: Text('เรียงตามชื่อ')),
                DropdownMenuItem(
                  value: 'itemCode',
                  child: Text('เรียงตามรหัส'),
                ),
                DropdownMenuItem(
                  value: 'price1',
                  child: Text('เรียงตามราคา 1'),
                ),
                DropdownMenuItem(
                  value: 'price2',
                  child: Text('เรียงตามราคา 2'),
                ),
                DropdownMenuItem(
                  value: 'price3',
                  child: Text('เรียงตามราคา 3'),
                ),
                DropdownMenuItem(
                  value: 'price4',
                  child: Text('เรียงตามราคา 4'),
                ),
                DropdownMenuItem(
                  value: 'price5',
                  child: Text('เรียงตามราคา 5'),
                ),
                DropdownMenuItem(value: 'date', child: Text('เรียงตามวันที่')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    sortBy = value;
                    _applySorting();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
