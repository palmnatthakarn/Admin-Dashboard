import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/data_model.dart';

class DealerFilter extends StatelessWidget {
  final String? selectedDealer;
  final List<Dealer> dealers;
  final ValueChanged<String?> onDealerChanged;
  final bool isLoading; // ⚡ เพิ่ม loading state

  const DealerFilter({
    super.key,
    required this.selectedDealer,
    required this.dealers,
    required this.onDealerChanged,
    this.isLoading = false, // ⚡ default false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Debug: Check dealer data
    if (kDebugMode) {
      print('DealerFilter - Dealers count: ${dealers.length}');
      print('DealerFilter - Selected: $selectedDealer');
      for (var dealer in dealers.take(3)) {
        print(
          'DealerFilter - Dealer: ${dealer.dealerCode} -> ${dealer.dealerName}',
        );
      }
    }

    return SizedBox(
      // ✅ ให้ความสูงชัดเจน
      height: 38,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
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
        child: DropdownButton<String>(
          value: selectedDealer,
          isExpanded: true, // ✅ ให้กินเต็มความกว้าง
          menuMaxHeight: 360, // (ออปชัน) กันเมนูยาวเกิน
          underline: const SizedBox(),
          dropdownColor: Colors.white,
          icon: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                )
              : Icon(
                  Icons.expand_more_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          borderRadius: BorderRadius.circular(12),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          hint: Text(
            dealers.isEmpty ? 'ไม่มีข้อมูลร้าน' : 'กรุณาเลือกร้าน',
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          items: [
            ...dealers.map((dealer) {
              return DropdownMenuItem<String>(
                value: dealer.dealerCode,
                child: Row(
                  children: [
                    Icon(
                      Icons.store_outlined,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      // ✅ ใช้ Flexible แบบหลวม แทน Expanded
                      child: Text(
                        '${dealer.dealerName} (${dealer.dealerCode})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onDealerChanged,
        ),
      ),
    );
  }
}
