import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:showscape/core/constants/app_colors.dart';
import 'package:showscape/core/theme/app_radius.dart';
import 'package:showscape/core/theme/app_spacing.dart';
import 'package:showscape/core/theme/app_typography.dart';
import 'package:showscape/features/booking/domain/models/booking_draft.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/food/presentation/widgets/indian_diet_badge.dart';

class ItemCustomisationSheet extends StatefulWidget {
  final FnbItem item;
  final ValueChanged<FnbCartItem> onAddToCart;

  const ItemCustomisationSheet({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  @override
  State<ItemCustomisationSheet> createState() => _ItemCustomisationSheetState();
}

class _ItemCustomisationSheetState extends State<ItemCustomisationSheet> {
  late String _selectedSize;
  late double _sizeDelta;
  late String _selectedFlavour;
  late double _flavourDelta;
  int _quantity = 1;

  List<Map<String, dynamic>> _sizeOptions = [];
  List<Map<String, dynamic>> _flavourOptions = [];

  @override
  void initState() {
    super.initState();

    final cat = widget.item.category.toLowerCase();
    if (cat.contains('popcorn')) {
      _sizeOptions = [
        {'name': 'Regular', 'delta': 0.0, 'desc': 'Ideal for 1 person'},
        {'name': 'Large', 'delta': 60.0, 'desc': 'Ideal for 2 people'},
        {'name': 'Jumbo Tub', 'delta': 110.0, 'desc': 'Sharing tub with tub refill'},
      ];
      _flavourOptions = [
        {'name': 'Classic Salted', 'delta': 0.0},
        {'name': 'Butter Burst', 'delta': 30.0},
        {'name': 'Spicy Peri-Peri', 'delta': 40.0},
        {'name': 'Caramel & Cheese Duo', 'delta': 60.0},
      ];
    } else if (cat.contains('beverage') || cat.contains('drink')) {
      _sizeOptions = [
        {'name': 'Medium (450ml)', 'delta': 0.0, 'desc': 'Standard cup'},
        {'name': 'Large (650ml)', 'delta': 40.0, 'desc': 'Cinema big size'},
      ];
      _flavourOptions = [
        {'name': 'Regular Ice', 'delta': 0.0},
        {'name': 'Less Ice', 'delta': 0.0},
        {'name': 'No Ice', 'delta': 0.0},
        {'name': 'Fresh Lemon Twist', 'delta': 15.0},
      ];
    } else {
      _sizeOptions = [
        {'name': 'Regular Portion', 'delta': 0.0, 'desc': 'Standard serving'},
        {'name': 'Loaded Portion', 'delta': 50.0, 'desc': 'Extra toppings & dip'},
      ];
      _flavourOptions = [
        {'name': 'Classic Seasoned', 'delta': 0.0},
        {'name': 'Fiery Peri-Peri Dip', 'delta': 30.0},
        {'name': 'Molten Cheese Dip', 'delta': 45.0},
      ];
    }

    _selectedSize = _sizeOptions.first['name'] as String;
    _sizeDelta = _sizeOptions.first['delta'] as double;
    _selectedFlavour = _flavourOptions.first['name'] as String;
    _flavourDelta = _flavourOptions.first['delta'] as double;
  }

  double get _unitPrice => widget.item.price + _sizeDelta + _flavourDelta;
  double get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.sheetTop28,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lavenderMuted.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Item Header info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.border12,
                  child: CachedNetworkImage(
                    imageUrl: widget.item.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.surfaceElevated),
                    errorWidget: (_, __, ___) => const Icon(Icons.fastfood_rounded),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IndianDietBadge(isVeg: widget.item.isVeg, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.item.name,
                              style: AppTypography.heading20().copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.vertical4,
                      Text(
                        '₹${widget.item.price.toInt()} base price',
                        style: AppTypography.body14(color: AppColors.spotlightCoral).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.item.calories != null)
                        Text(
                          '${widget.item.calories} kcal',
                          style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.lavenderMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.surfaceBorder, height: 24),

          // Scrollable Customisation Options
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Size selection
                  Text(
                    'Select Size',
                    style: AppTypography.heading20().copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.vertical8,
                  ..._sizeOptions.map((opt) {
                    final name = opt['name'] as String;
                    final delta = opt['delta'] as double;
                    final desc = opt['desc'] as String?;
                    final isSelected = _selectedSize == name;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSize = name;
                          _sizeDelta = delta;
                        });
                      },
                      borderRadius: AppRadius.border12,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.spotlightCoral.withOpacity(0.12)
                              : AppColors.surfaceElevated,
                          border: Border.all(
                            color: isSelected ? AppColors.spotlightCoral : AppColors.surfaceBorder,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          borderRadius: AppRadius.border12,
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: name,
                              groupValue: _selectedSize,
                              activeColor: AppColors.spotlightCoral,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedSize = val;
                                    _sizeDelta = delta;
                                  });
                                }
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: AppTypography.body14(
                                      color: isSelected ? AppColors.spotlightCoral : AppColors.lavender,
                                    ).copyWith(
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    ),
                                  ),
                                  if (desc != null)
                                    Text(
                                      desc,
                                      style: AppTypography.caption12(color: AppColors.lavenderMuted).copyWith(
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              delta > 0 ? '+₹${delta.toInt()}' : 'Free',
                              style: AppTypography.caption12(
                                color: isSelected ? AppColors.spotlightCoral : AppColors.lavenderMuted,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  AppSpacing.vertical16,

                  // Flavour selection
                  Text(
                    'Select Flavour / Dip',
                    style: AppTypography.heading20().copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  AppSpacing.vertical8,
                  ..._flavourOptions.map((opt) {
                    final name = opt['name'] as String;
                    final delta = opt['delta'] as double;
                    final isSelected = _selectedFlavour == name;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFlavour = name;
                          _flavourDelta = delta;
                        });
                      },
                      borderRadius: AppRadius.border12,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.spotlightCoral.withOpacity(0.12)
                              : AppColors.surfaceElevated,
                          border: Border.all(
                            color: isSelected ? AppColors.spotlightCoral : AppColors.surfaceBorder,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                          borderRadius: AppRadius.border12,
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: name,
                              groupValue: _selectedFlavour,
                              activeColor: AppColors.spotlightCoral,
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedFlavour = val;
                                    _flavourDelta = delta;
                                  });
                                }
                              },
                            ),
                            Expanded(
                              child: Text(
                                name,
                                style: AppTypography.body14(
                                  color: isSelected ? AppColors.spotlightCoral : AppColors.lavender,
                                ).copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              delta > 0 ? '+₹${delta.toInt()}' : 'Free',
                              style: AppTypography.caption12(
                                color: isSelected ? AppColors.spotlightCoral : AppColors.lavenderMuted,
                              ).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          const Divider(color: AppColors.surfaceBorder, height: 20),

          // Bottom Bar: Quantity stepper + Add to Cart Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Stepper
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.border12,
                    border: Border.all(color: AppColors.surfaceBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        color: _quantity > 1 ? AppColors.spotlightCoral : AppColors.lavenderMuted,
                        onPressed: _quantity > 1
                            ? () {
                                HapticFeedback.lightImpact();
                                setState(() => _quantity--);
                              }
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$_quantity',
                          style: AppTypography.body16(color: AppColors.lavender, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        color: AppColors.spotlightCoral,
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() => _quantity++);
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Add to booking button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        final cartItem = FnbCartItem(
                          id: 'cart_${widget.item.id}_${DateTime.now().millisecondsSinceEpoch}',
                          item: widget.item,
                          size: _selectedSize,
                          flavour: _selectedFlavour,
                          unitPrice: _unitPrice,
                          quantity: _quantity,
                        );
                        widget.onAddToCart(cartItem);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.spotlightCoral,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.border12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Item',
                            style: AppTypography.buttonLabel(color: Colors.white),
                          ),
                          Text(
                            '₹${_totalPrice.toInt()}',
                            style: AppTypography.body16(color: Colors.white, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
