import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';

class DeviceContact {
  const DeviceContact({
    required this.name,
    required this.phoneNumber,
    this.email,
  });

  final String name;
  final String phoneNumber;
  final String? email;
}

class ContactInviteService {
  ContactInviteService._();
  static final ContactInviteService instance = ContactInviteService._();

  /// Mock contact list representing contacts on the user's device
  static const List<DeviceContact> sampleContacts = [
    DeviceContact(
      name: 'Emma Watson',
      phoneNumber: '+1 (555) 234-5678',
      email: 'emma.watson@example.com',
    ),
    DeviceContact(
      name: 'Liam Smith',
      phoneNumber: '+1 (555) 876-5432',
      email: 'liam.smith@example.com',
    ),
    DeviceContact(
      name: 'Olivia Davis',
      phoneNumber: '+1 (555) 345-6789',
      email: 'olivia.d@example.com',
    ),
    DeviceContact(
      name: 'Noah Wilson',
      phoneNumber: '+1 (555) 987-6543',
      email: 'noah.w@example.com',
    ),
    DeviceContact(
      name: 'Sophia Taylor',
      phoneNumber: '+1 (555) 456-7890',
      email: 'sophia.t@example.com',
    ),
  ];

  static const String inviteUrl = 'https://caffora.cafe/invite?ref=CAFFORA20';
  static const String defaultShareMessage =
      'Hey! Join me for freshly roasted coffee at Caffora Café. Use my invite link https://caffora.cafe/invite?ref=CAFFORA20 to get 20% off your first order! ☕';

  /// Opens the complete Invite Hub modal with Copy Link, WhatsApp, and Phone Contact picker
  Future<void> openInviteHub(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final palette = ctx.appColors;
        return Container(
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: palette.border),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            32 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: palette.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.softSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.card_giftcard_rounded, color: palette.accentDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invite Friends & Get 20% Off',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Share your link or invite from your phone contacts',
                          style: TextStyle(color: palette.body, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: palette.muted, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Copy link box
              Text(
                'YOUR REFERRAL LINK',
                style: TextStyle(
                  color: palette.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        inviteUrl,
                        style: TextStyle(
                          color: palette.ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: inviteUrl));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Expanded(child: Text('Invite link copied! Share with friends on WhatsApp or Messages.')),
                              ],
                            ),
                            backgroundColor: Color(0xFF4C8A65),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy, size: 15),
                      label: const Text('Copy'),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.accentDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // WhatsApp Share Action
              InkWell(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: defaultShareMessage));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Expanded(child: Text('WhatsApp message copied! Paste it in your WhatsApp chat.')),
                        ],
                      ),
                      backgroundColor: Color(0xFF25D366),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF25D366),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Share via WhatsApp',
                              style: TextStyle(
                                color: Color(0xFF1E7E34),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Pre-fills invite message & referral link',
                              style: TextStyle(color: Color(0xFF2E5B37), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF1E7E34)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Pick from Phone Contacts Action
              InkWell(
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final contact = await pickContact(context);
                  if (contact != null && context.mounted) {
                    await showInviteSheet(context, contact);
                  }
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: palette.softSurface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: palette.accentDark.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.contacts, color: palette.accentDark, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Select from Phone Contacts',
                              style: TextStyle(
                                color: palette.ink,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Pick a friend directly from your device contact book',
                              style: TextStyle(color: palette.body, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: palette.muted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Privacy Notice
              Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: palette.muted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Privacy note: Device contacts are never stored or uploaded to our system.',
                      style: TextStyle(color: palette.muted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Prompts permission and opens contact picker sheet
  Future<DeviceContact?> pickContact(BuildContext context) async {
    // 1. Request permission confirmation
    final bool? permissionGranted = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final palette = ctx.appColors;
        return AlertDialog(
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.contacts_outlined, color: palette.accentDark),
              const SizedBox(width: 10),
              Text(
                'Access Contacts',
                style: TextStyle(color: palette.ink, fontSize: 18),
              ),
            ],
          ),
          content: Text(
            'Caffora would like to access your device contacts to let you easily invite friends and share referral discounts.',
            style: TextStyle(color: palette.body, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text('Don\'t Allow', style: TextStyle(color: palette.muted)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: FilledButton.styleFrom(backgroundColor: palette.accentDark),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );

    if (permissionGranted != true || !context.mounted) {
      return null;
    }

    // 2. Open Device Contact Picker Modal
    return showModalBottomSheet<DeviceContact>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final palette = ctx.appColors;
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Icon(Icons.contacts, color: palette.accentDark, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          'Select a Contact to Invite',
                          style: TextStyle(
                            color: palette.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: palette.border, height: 1),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: sampleContacts.length,
                      separatorBuilder: (_, _) =>
                          Divider(color: palette.border, height: 1, indent: 64),
                      itemBuilder: (_, index) {
                        final contact = sampleContacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: palette.accentDark.withValues(alpha: 0.12),
                            child: Text(
                              contact.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: palette.accentDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: TextStyle(
                              color: palette.ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            contact.phoneNumber,
                            style: TextStyle(color: palette.body, fontSize: 12),
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: palette.muted,
                            size: 18,
                          ),
                          onTap: () => Navigator.of(ctx).pop(contact),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Opens invite preview dialog with selected contact and pre-filled message
  Future<void> showInviteSheet(BuildContext context, DeviceContact contact) async {
    final messageController = TextEditingController(
      text:
          'Hey ${contact.name.split(' ').first}! Join me for freshly roasted coffee at Caffora Café. Use my invite link https://caffora.cafe/invite?ref=ALEX20 to get 20% off your first order! ☕',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final palette = ctx.appColors;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: palette.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: palette.accentDark.withValues(alpha: 0.15),
                      child: Icon(Icons.person, color: palette.accentDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inviting ${contact.name}',
                            style: TextStyle(
                              color: palette.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            contact.phoneNumber,
                            style: TextStyle(color: palette.body, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Pre-filled Invite Message',
                  style: TextStyle(
                    color: palette.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  style: TextStyle(color: palette.ink, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: palette.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: palette.accentDark, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('Invitation sent to ${contact.name}!'),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF4C8A65),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Send Invitation'),
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accentDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
