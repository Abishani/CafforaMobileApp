import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../menu/data/menu_data.dart';

class AddFoodItemPage extends StatefulWidget {
  const AddFoodItemPage({super.key});

  @override
  State<AddFoodItemPage> createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  String _selectedCategory = 'Coffee';
  String _selectedEmoji = '☕';
  bool _isSaving = false;

  static const _categories = ['Coffee', 'Tea', 'Pastries', 'Brunch'];

  static const _emojiOptions = [
    '☕', '🍵', '🧋', '🥐', '🥯', '🥪', '🍰', '🍪', '🧇', '🥞',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final rawPrice = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final formattedPrice = '\$${rawPrice.toStringAsFixed(2)}';

    final newItem = MenuProduct(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: formattedPrice,
      image: _selectedEmoji,
      category: _selectedCategory,
      isCustom: true,
    );

    MenuData.addProduct(newItem);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${newItem.name}" added to menu!'),
          backgroundColor: AppColors.accentDark,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop(newItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18, color: palette.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Add Menu Item',
          style: TextStyle(
            color: palette.ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -.4,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: palette.accent,
                    ),
                  )
                : TextButton(
                    onPressed: _save,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: palette.accentDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Emoji picker ──────────────────────────────
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: palette.softSurface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.fromBorderSide(
                            BorderSide(color: palette.border),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _selectedEmoji,
                          style: const TextStyle(fontSize: 46),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Choose icon',
                        style: TextStyle(
                          color: palette.body,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _emojiOptions.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final e = _emojiOptions[i];
                            final selected = e == _selectedEmoji;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedEmoji = e),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? palette.accent.withValues(alpha: .15)
                                      : palette.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? palette.accent
                                        : palette.border,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(e, style: const TextStyle(fontSize: 22)),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Category chips ────────────────────────────
                const _SectionLabel(label: 'Category'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final cat in _categories) ...[
                        GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedCategory == cat
                                  ? palette.accent
                                  : palette.chipSurface,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: _selectedCategory == cat
                                    ? Colors.white
                                    : palette.body,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (cat != _categories.last) const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Item name ─────────────────────────────────
                const _SectionLabel(label: 'Item name'),
                const SizedBox(height: 8),
                _StyledField(
                  controller: _nameCtrl,
                  hint: 'e.g. Caramel Oat Latte',
                  icon: Icons.fastfood_outlined,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // ── Description ───────────────────────────────
                const _SectionLabel(label: 'Description'),
                const SizedBox(height: 8),
                _StyledField(
                  controller: _descCtrl,
                  hint: 'Short description of the item...',
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Description is required'
                      : null,
                ),
                const SizedBox(height: 16),

                // ── Price ─────────────────────────────────────
                const _SectionLabel(label: 'Price (USD)'),
                const SizedBox(height: 8),
                _StyledField(
                  controller: _priceCtrl,
                  hint: '0.00',
                  icon: Icons.attach_money,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Price is required';
                    final d = double.tryParse(v.trim());
                    if (d == null || d <= 0) return 'Enter a valid price';
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // ── Save button ───────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: palette.accentDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor:
                          palette.accentDark.withValues(alpha: .5),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline,
                                  size: 20, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Add to Menu',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: palette.body,
        letterSpacing: .1,
      ),
    );
  }
}

class _StyledField extends StatelessWidget {
  const _StyledField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final palette = context.appColors;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontSize: 14, color: palette.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: palette.muted, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: palette.body),
        filled: true,
        fillColor: palette.surface,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE05A5A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE05A5A), width: 1.5),
        ),
      ),
    );
  }
}
