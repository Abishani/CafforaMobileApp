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

  String _selectedCategory = 'Beverages';
  String _selectedEmoji = '☕';
  bool _isSaving = false;

  /// The 4 standard database category types
  static const _categories = ['Beverages', 'Snacks', 'Meals', 'Desserts'];

  static const _emojiOptions = [
    '☕', '🍵', '🧋', '🥐', '🥯', '🥪', '🍰', '🍪', '🧇', '🥞',
  ];

  /// Standard database catalog presets used for fast lookup & auto-completion
  static final List<MenuProduct> _catalogDatabaseTemplates = [
    const MenuProduct(
      id: 101,
      name: 'Craft Flat White',
      description: 'Double shot of single-origin espresso with silky textured milk.',
      price: '4.50',
      rawPrice: 4.50,
      calories: 280,
      category: 'Beverages',
      image: '☕',
    ),
    const MenuProduct(
      id: 102,
      name: 'Iced Honey Oat Latte',
      description: 'Organic oat milk combined with raw local honey and blonde roast cold brew.',
      price: '5.25',
      rawPrice: 5.25,
      calories: 340,
      category: 'Beverages',
      image: '🧋',
    ),
    const MenuProduct(
      id: 103,
      name: 'Cinnamon Swirl Bun',
      description: 'Freshly baked sourdough bun with Ceylon cinnamon and brown sugar glaze.',
      price: '3.75',
      rawPrice: 3.75,
      calories: 280,
      category: 'Snacks',
      image: '🥐',
    ),
    const MenuProduct(
      id: 104,
      name: 'Matcha Jasmine Crepe',
      description: 'Delicate matcha crepe layers with airy jasmine-infused pastry cream.',
      price: '7.50',
      rawPrice: 7.50,
      calories: 340,
      category: 'Snacks',
      image: '🥞',
    ),
    const MenuProduct(
      id: 105,
      name: 'Avocado Sourdough Toast',
      description: 'Crushed Hass avocado, cherry tomatoes, and feta on organic levain.',
      price: '11.50',
      rawPrice: 11.50,
      calories: 280,
      category: 'Meals',
      image: '🥪',
    ),
    const MenuProduct(
      id: 106,
      name: 'Smoked Turkey Ciabatta',
      description: 'Hand-carved turkey breast, heirloom tomatoes, pesto, and melted provolone.',
      price: '12.00',
      rawPrice: 12.00,
      calories: 340,
      category: 'Meals',
      image: '🥪',
    ),
    const MenuProduct(
      id: 107,
      name: 'Pistachio Raspberry Tart',
      description: 'Sweet pastry shell filled with rich pistachio cream and fresh raspberries.',
      price: '6.50',
      rawPrice: 6.50,
      calories: 280,
      category: 'Desserts',
      image: '🍰',
    ),
    const MenuProduct(
      id: 108,
      name: 'Sourdough Chocolate Cookie',
      description: 'Crispy edges with gooey, rich dark chocolate pools and flaked sea salt.',
      price: '3.25',
      rawPrice: 3.25,
      calories: 340,
      category: 'Desserts',
      image: '🍪',
    ),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  String _normalizeCategory(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('beverage') || lower.contains('coffee') || lower.contains('tea')) {
      return 'Beverages';
    }
    if (lower.contains('snack') || lower.contains('pastr')) {
      return 'Snacks';
    }
    if (lower.contains('meal') || lower.contains('brunch') || lower.contains('sand')) {
      return 'Meals';
    }
    if (lower.contains('dessert') || lower.contains('sweet') || lower.contains('cake') || lower.contains('cookie') || lower.contains('tart')) {
      return 'Desserts';
    }
    return 'Beverages';
  }

  /// Automatically fetch and populate Category, Description, Price, and Image by Item Name from Database
  void _fetchDetailsByName(String name) {
    final cleanName = name.trim().toLowerCase();
    if (cleanName.isEmpty) return;

    MenuProduct? match;

    // 1. Search in live database products
    for (final p in MenuData.products) {
      if (p.name.toLowerCase() == cleanName || p.name.toLowerCase().contains(cleanName)) {
        match = p;
        break;
      }
    }

    // 2. Search in standard database seed templates
    if (match == null) {
      for (final t in _catalogDatabaseTemplates) {
        if (t.name.toLowerCase() == cleanName || t.name.toLowerCase().contains(cleanName)) {
          match = t;
          break;
        }
      }
    }

    if (match != null) {
      setState(() {
        _nameCtrl.text = match!.name;
        _selectedCategory = _normalizeCategory(match.category);
        _descCtrl.text = match.description;
        _priceCtrl.text = match.numericPrice.toStringAsFixed(2);
        if (_emojiOptions.contains(match.image)) {
          _selectedEmoji = match.image;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Details for "${match.name}" fetched from database!'),
          duration: const Duration(milliseconds: 1400),
          backgroundColor: const Color(0xFF4C8A65),
        ),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final rawPrice = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;

    // Resolve category ID for backend
    int categoryId = 1;
    final catLower = _selectedCategory.toLowerCase();
    for (final c in MenuData.categories) {
      final nameLower = c.name.toLowerCase();
      if (nameLower == catLower || nameLower.startsWith(catLower)) {
        categoryId = c.id;
        break;
      }
    }

    final newItem = await MenuData.createProduct(
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      price: rawPrice,
      categoryId: categoryId,
      categoryName: _selectedCategory,
      imageUrl: _selectedEmoji,
    );

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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 64),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Emoji / Image Picker ──────────────────────────────
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
                        'Item Image / Icon',
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

                // ── Category / 4 Types ────────────────────────────
                const _SectionLabel(label: 'Type (Category)'),
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

                // ── Item name with Auto-Fetch ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionLabel(label: 'Item name'),
                    Text(
                      'Auto-fetches details from DB',
                      style: TextStyle(
                        fontSize: 11,
                        color: palette.accentDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _StyledField(
                  controller: _nameCtrl,
                  hint: 'e.g. Craft Flat White',
                  icon: Icons.fastfood_outlined,
                  suffixIcon: IconButton(
                    icon: Icon(Icons.download_outlined, color: palette.accentDark),
                    tooltip: 'Fetch details from database',
                    onPressed: () => _fetchDetailsByName(_nameCtrl.text),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 8),

                // Quick database catalog chips
                Text(
                  'Quick database items (tap name to auto-fill details):',
                  style: TextStyle(color: palette.muted, fontSize: 11),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final item in _catalogDatabaseTemplates)
                      ActionChip(
                        label: Text(item.name, style: const TextStyle(fontSize: 11)),
                        backgroundColor: palette.softSurface,
                        side: BorderSide(color: palette.border),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () => _fetchDetailsByName(item.name),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

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
                const SizedBox(height: 36),
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
    this.suffixIcon,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Widget? suffixIcon;
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
        suffixIcon: suffixIcon,
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
