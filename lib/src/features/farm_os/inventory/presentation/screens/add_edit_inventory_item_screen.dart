// lib/src/features/farm_os/inventory/presentation/screens/add_edit_inventory_item_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/controllers/inventory_controller.dart';

class AddEditInventoryItemScreen extends ConsumerStatefulWidget {
  final InventoryItem? item;
  const AddEditInventoryItemScreen({super.key, this.item});

  bool get isEditMode => item != null;

  @override
  ConsumerState<AddEditInventoryItemScreen> createState() =>
      _AddEditInventoryItemScreenState();
}

class _AddEditInventoryItemScreenState
    extends ConsumerState<AddEditInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _thresholdController;
  String _selectedCategory = 'Feeds';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item?.name);
    _quantityController = TextEditingController(
      text: widget.item?.quantity.toString(),
    );
    _unitController = TextEditingController(text: widget.item?.unit);
    _thresholdController = TextEditingController(
      text: widget.item?.lowStockThreshold.toString(),
    );
    _selectedCategory = widget.item?.category ?? 'Feeds';
  }

  @override
  void dispose() {
    // ... dispose all controllers
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(inventoryControllerProvider.notifier);
    try {
      if (widget.isEditMode) {
        await notifier.editItem(
          itemId: widget.item!.id,
          name: _nameController.text,
          category: _selectedCategory,
          quantity: double.parse(_quantityController.text),
          unit: _unitController.text,
          lowStockThreshold: double.parse(_thresholdController.text),
        );
      } else {
        await notifier.addItem(
          name: _nameController.text,
          category: _selectedCategory,
          quantity: double.parse(_quantityController.text),
          unit: _unitController.text,
          lowStockThreshold: double.parse(_thresholdController.text),
        );
      }
      if (mounted) context.pop();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Item' : 'Add New Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Feeds', 'Medicines', 'Supplies', 'Equipment']
                    .map(
                      (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(labelText: 'Quantity'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d*'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (e.g., kg, sacks)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _thresholdController,
                decoration: const InputDecoration(
                  labelText: 'Low Stock Threshold',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: state.isLoading ? null : _saveItem,
                child: Text(widget.isEditMode ? 'Save Changes' : 'Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
