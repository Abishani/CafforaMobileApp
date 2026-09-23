import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/auth/auth_scope.dart';

class ProfileIdentityCard extends StatelessWidget {
  const ProfileIdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    final displayName = AuthScope.maybeOf(context)?.displayName ?? 'Alex';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
        boxShadow: [BoxShadow(color: palette.cardShadow, blurRadius: 2)],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: palette.accentDark.withValues(alpha: .2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipOval(child: Image.asset(AppAssets.profile)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$displayName Morgan',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 18,
                    height: 24 / 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${displayName.toLowerCase()}.morgan@example.com',
                  style: TextStyle(
                    color: palette.body,
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.edit_outlined,
              size: 18,
              color: palette.accentDark,
            ),
            tooltip: 'Edit profile',
          ),
        ],
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.fromBorderSide(
          BorderSide(color: palette.border),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class ProfileActionTile extends StatelessWidget {
  const ProfileActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: palette.softSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: palette.accentDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: palette.ink,
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: palette.body,
                      fontSize: 12,
                      height: 16 / 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: palette.body, size: 20),
          ],
        ),
      ),
    );
  }
}

class ProfileDivider extends StatelessWidget {
  const ProfileDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Divider(height: 1, indent: 64, color: palette.border);
  }
}
