import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ThemePreviewCard extends StatelessWidget {
  const ThemePreviewCard({
    super.key,
    required this.label,
    required this.background,
    required this.panel,
    required this.line,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color panel;
  final Color line;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 116,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.accentDark
                      : const Color(0xFFE8CECA),
                  width: selected ? 2 : 1,
                ),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x26C86240),
                          blurRadius: 12,
                          offset: Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 6,
                    decoration: BoxDecoration(
                      color: line,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Container(
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: line.withValues(alpha: .35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.accentDark,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 4,
                          decoration: BoxDecoration(
                            color: line,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 20,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: line.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Center(
                    child: Icon(
                      icon,
                      size: 14,
                      color: selected ? AppColors.accentDark : line,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.accentDark : AppColors.body,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: .24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemePreferenceOption extends StatelessWidget {
  const ThemePreferenceOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? const Color(0xCCFFF1ED) : Colors.white,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFFDCD1)
                    : AppColors.softSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: selected ? AppColors.accentDark : AppColors.body,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.body,
                      fontSize: 12,
                      height: 18 / 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? AppColors.accentDark
                      : const Color(0xFFDCC1B8),
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      decoration: const BoxDecoration(
                        color: AppColors.accentDark,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
