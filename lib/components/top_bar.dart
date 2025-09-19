import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class TopBar extends StatelessWidget {
  final List<MenuItem> menuItems;
  final int selectedMenuIndex;
  final Function(String) onSearchChanged;

  const TopBar({
    super.key,
    required this.menuItems,
    required this.selectedMenuIndex,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Container(
      height: isSmallScreen ? 70 : 80,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.surfaceContainerHighest,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Menu button for mobile
          if (MediaQuery.of(context).size.width < 1024) ...[
            Builder(
              builder: (context) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.menu,
                      color: theme.colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedMenuIndex == 0
                      ? 'จัดการสินค้า'
                      : menuItems[selectedMenuIndex].title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isSmallScreen)
                  Text(
                    selectedMenuIndex == 0
                        ? 'ระบบจัดการข้อมูลสินค้าและคลังสินค้า'
                        : 'รายละเอียดเพิ่มเติม',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (MediaQuery.of(context).size.width > 800) ...[
            _buildSearchBar(context),
            const SizedBox(width: 16),
          ],
          _buildNotificationButton(context),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    if (selectedMenuIndex != 0) return const SizedBox();

    final theme = Theme.of(context);

    return Container(
      width: 320,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.surfaceContainerHighest,
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onSearchChanged,
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

  Widget _buildNotificationButton(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.surfaceContainerHighest,
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
