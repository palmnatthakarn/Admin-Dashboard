import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class ModernSidebar extends StatefulWidget {
  final List<MenuItem> menuItems;
  final int selectedMenuIndex;
  final Function(int) onMenuSelected;

  const ModernSidebar({
    super.key,
    required this.menuItems,
    required this.selectedMenuIndex,
    required this.onMenuSelected,
  });

  @override
  State<ModernSidebar> createState() => _ModernSidebarState();
}

class _ModernSidebarState extends State<ModernSidebar> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isCollapsed ? 80 : 280,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 253, 253, 253), // Blue 500
            Color.fromARGB(255, 255, 255, 255), // Blue 700
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildMenuItems()),
          _buildUserProfile(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isExpanded = !_isCollapsed;
    final theme = Theme.of(context);

    // ไม่ต้องให้ padding ใหญ่เกินไปตอนหุบ เพื่อลดโอกาส overflow
    final padding = EdgeInsets.symmetric(
      horizontal: isExpanded ? 15 : 15,
      vertical: 21,
    );

    // แสดงปุ่ม toggle เฉพาะตอน "ขยาย" เท่านั้น
    final showToggle = isExpanded;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white30.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // โซนซ้าย: Dashboard (ทำให้คลิกเพื่อสลับหุบ/ขยายได้เสมอ)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _isCollapsed = !_isCollapsed);
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? const Color.fromARGB(255, 219, 215, 215)
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.dashboard_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  if (isExpanded) ...[
                    const SizedBox(width: 8),
                    // ใช้ ConstrainedBox + SizedBox ช่วยกันล้น
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 180),
                      child: Text(
                        'Admin Dashboard',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ดันทุกอย่างไปชิดขวา
          const Spacer(),

          // โซนขวา: ปุ่ม toggle (แสดงเฉพาะตอน "ขยาย")
          if (showToggle)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    setState(() => _isCollapsed = !_isCollapsed);
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Icon(
                      _isCollapsed ? Icons.menu : Icons.menu_open,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    final isExpanded = !_isCollapsed;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isExpanded ? 15 : 8,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: Text(
                'เมนูหลัก',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.black12.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          ...List.generate(
            widget.menuItems.length,
            (index) => _buildMenuItem(index, isExpanded),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(int index, bool isExpanded) {
    if (index >= widget.menuItems.length) return const SizedBox.shrink();

    final item = widget.menuItems[index];
    final isSelected = widget.selectedMenuIndex == index;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // เลื่อน callback ไปหลังเฟรม เพื่อลด assert ของ MouseTracker
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              widget.onMenuSelected(index);
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 8,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected
                        ? const Color.fromARGB(255, 0, 0, 0)
                        : Colors.black.withValues(alpha: 0.3),
                    size: 18,
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : const Color.fromARGB(
                                255,
                                0,
                                0,
                                0,
                              ).withValues(alpha: 0.9),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final isExpanded = !_isCollapsed;
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isExpanded ? 8 : 6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face',
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin User',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'ผู้ดูแลระบบ',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.more_horiz,
                    color: Colors.black.withValues(alpha: 0.7),
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
