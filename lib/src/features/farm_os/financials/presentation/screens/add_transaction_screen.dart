// lib/src/features/farm_os/financials/presentation/screens/add_transaction_screen.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/common_widgets/general_form_params_provider.dart';
import 'package:liminetic/src/features/farm_os/financials/domain/financial_transaction_model.dart';
import 'package:liminetic/src/features/farm_os/financials/presentation/controllers/financials_controller.dart';
import 'package:liminetic/src/features/farm_os/inventory/domain/inventory_item_model.dart';
import 'package:liminetic/src/features/farm_os/inventory/presentation/controllers/inventory_controller.dart';

/// A helper class to manage the state of a single line item in a transaction.
class TransactionLineItem {
  final InventoryItem item;
  final TextEditingController quantityController = TextEditingController(
    text: '1',
  );
  final TextEditingController priceController = TextEditingController();

  TransactionLineItem({required this.item});

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}

/// A dynamic screen for adding all types of financial transactions.
/// Its UI adapts based on the selected transaction category.
class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType initialType;
  const AddTransactionScreen({super.key, required this.initialType});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _selectedType;
  late String _selectedCategory;

  // State for multi-item forms
  final List<TransactionLineItem> _lineItems = [];
  double _totalAmount = 0.0;

  // State for simple forms and shared fields
  final _customerOrSupplierController = TextEditingController();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _setInitialCategory();
  }

  @override
  void dispose() {
    _customerOrSupplierController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    for (final item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _setInitialCategory() {
    setState(() {
      _selectedCategory = _selectedType == TransactionType.income
          ? 'Inventory Sale'
          : 'Inventory Purchase';
      _clearLineItems();
    });
  }

  void _onTypeChanged(TransactionType newType) {
    setState(() {
      _selectedType = newType;
      // Reset the category to a sensible default for the new type.
      _selectedCategory = _selectedType == TransactionType.income
          ? 'Inventory Sale'
          : 'Inventory Purchase';
      _clearLineItems(); // Clear items as the form changes
    });
  }

  void _calculateTotal() {
    double total = 0.0;
    for (final lineItem in _lineItems) {
      final qty = double.tryParse(lineItem.quantityController.text) ?? 0.0;
      final price = double.tryParse(lineItem.priceController.text) ?? 0.0;
      total += qty * price;
    }
    setState(() => _totalAmount = total);
  }

  void _clearLineItems() {
    for (final item in _lineItems) {
      item.dispose();
    }
    _lineItems.clear();
    _calculateTotal();
  }

  /// This is the fool-proof way: an async method with a try-catch block.
  Future<void> _saveTransaction() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(financialsControllerProvider.notifier);
    final isMultiItem = [
      'Inventory Purchase',
      'Inventory Sale',
    ].contains(_selectedCategory);

    try {
      // This eliminates repetitive checks and makes the logic easier to follow.
      if (isMultiItem) {
        // --- Logic for multi-item inventory transactions ---

        // Prepare line items with cleaner data (only quantityUsed OR quantityAdded)
        final lineItemsData = _lineItems.map((li) {
          final map = <String, dynamic>{
            'itemId': li.item.id,
            'itemName': li.item.name,
            'price': double.tryParse(li.priceController.text) ?? 0.0,
          };
          if (_selectedType == TransactionType.income) {
            map['quantityUsed'] =
                double.tryParse(li.quantityController.text) ?? 0.0;
          } else {
            map['quantityAdded'] =
                double.tryParse(li.quantityController.text) ?? 0.0;
          }
          return map;
        }).toList();

        await notifier.addTransaction(
          title: _customerOrSupplierController.text.trim(),
          type: _selectedType,
          category: _selectedCategory,
          amount: _totalAmount,
          notes: _notesController.text.trim(),
          lineItems: lineItemsData,
        );
      } else {
        // --- Logic for simple, general transactions ---
        await notifier.addTransaction(
          title: _titleController.text.trim(),
          type: _selectedType,
          category: _selectedCategory,
          amount: double.tryParse(_amountController.text) ?? 0.0,
          notes: _notesController.text.trim(),
          lineItems: [], // No line items for simple transactions
        );
      }

      // --- Success Case ---
      if (!mounted) return;
      ref.invalidate(financialsProvider);
      ref.invalidate(inventoryProvider);
      context.pop();
    } catch (e) {
      if (!mounted) return;

      String errorMessage;
      if (e is FirebaseException) {
        errorMessage = e.message ?? "A Firebase error occurred.";
      } else {
        // This handles both Dart Exceptions and wrapped NativeErrors.
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formParamsAsync = ref.watch(generalFormParamsProvider);
    final state = ref.watch(financialsControllerProvider);

    final expenseCategories = [
      'Inventory Purchase',
      'General Expense',
      'Utility Bill',
    ];
    final incomeCategories = ['Inventory Sale', 'General Sale', 'Animal Sale'];
    final bool isMultiItem = [
      'Inventory Purchase',
      'Inventory Sale',
    ].contains(_selectedCategory);

    return Scaffold(
      appBar: AppBar(title: const Text('New Transaction')),
      body: formParamsAsync.when(
        data: (params) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SegmentedButton<TransactionType>(
                        segments: const [
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text('Sale'),
                          ),
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text('Expense'),
                          ),
                        ],
                        selected: {_selectedType},
                        onSelectionChanged: (selection) =>
                            _onTypeChanged(selection.first),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items:
                            (_selectedType == TransactionType.income
                                    ? incomeCategories
                                    : expenseCategories)
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() {
                          _selectedCategory = val!;
                          _clearLineItems();
                        }),
                      ),
                      const SizedBox(height: 16),
                      _buildDynamicFormBody(params.inventoryItems),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: state.isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Settle ${_selectedType == TransactionType.income ? "Sale" : "Expense"} | ₱${(isMultiItem ? _totalAmount : double.tryParse(_amountController.text) ?? 0.0).toStringAsFixed(2)}',
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  /// A helper method that returns the correct form widget based on the selected category.
  /// This is the core of our dynamic UI.
  Widget _buildDynamicFormBody(List<InventoryItem> allInventoryItems) {
    switch (_selectedCategory) {
      case 'Inventory Purchase':
      case 'Inventory Sale':
        return _InventoryTransactionForm(
          selectedType: _selectedType,
          customerOrSupplierController: _customerOrSupplierController,
          lineItems: _lineItems,
          inventoryItems: allInventoryItems,
          onAddItem: (item) {
            setState(() {
              final newLineItem = TransactionLineItem(item: item);
              newLineItem.quantityController.addListener(_calculateTotal);
              newLineItem.priceController.addListener(_calculateTotal);
              _lineItems.add(newLineItem);
            });
          },
          onRemoveItem: (index) {
            setState(() {
              _lineItems[index].dispose();
              _lineItems.removeAt(index);
              _calculateTotal();
            });
          },
        );
      default: // General Expense, General Sale, etc.
        return _GeneralTransactionForm(
          titleController: _titleController,
          amountController: _amountController,
        );
    }
  }
}

/// A reusable widget for the simple "Title" and "Amount" form fields.
/// This is a private widget because it's only used within this screen's logic.
class _GeneralTransactionForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController amountController;

  const _GeneralTransactionForm({
    required this.titleController,
    required this.amountController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(labelText: 'Title'),
          validator: (value) =>
              (value?.trim().isEmpty ?? true) ? 'Title cannot be empty' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: amountController,
          decoration: const InputDecoration(labelText: 'Amount (₱)'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
          ],
          validator: (value) =>
              (value?.trim().isEmpty ?? true) ? 'Amount cannot be empty' : null,
        ),
      ],
    );
  }
}

class _InventoryTransactionForm extends StatelessWidget {
  final TransactionType selectedType;
  final TextEditingController customerOrSupplierController;
  final List<TransactionLineItem> lineItems;
  final List<InventoryItem> inventoryItems;
  final ValueChanged<InventoryItem> onAddItem;
  final ValueChanged<int> onRemoveItem;

  const _InventoryTransactionForm({
    required this.selectedType,
    required this.customerOrSupplierController,
    required this.lineItems,
    required this.inventoryItems,
    required this.onAddItem,
    required this.onRemoveItem,
  });

  Future<void> _showSelectProductDialog(BuildContext context) async {
    final availableItems = inventoryItems
        .where((i) => !lineItems.any((li) => li.item.id == i.id))
        .toList();
    final selectedItem = await showDialog<InventoryItem>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Product'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableItems.length,
            itemBuilder: (context, index) {
              final item = availableItems[index];
              return ListTile(
                title: Text(item.name),
                onTap: () => Navigator.of(context).pop(item),
              );
            },
          ),
        ),
      ),
    );
    if (selectedItem != null) {
      onAddItem(selectedItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedType == TransactionType.income
                      ? 'Customer'
                      : 'Supplier',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: customerOrSupplierController,
                  decoration: InputDecoration(
                    hintText: selectedType == TransactionType.income
                        ? 'Select Customer'
                        : 'Enter Supplier Name',
                  ),
                  autofillHints: const [AutofillHints.name],
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? 'This field is required'
                      : null,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Item(s)', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                if (lineItems.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: lineItems.length,
                    itemBuilder: (context, index) {
                      return _LineItemWidget(
                        lineItem: lineItems[index],
                        onRemove: () => onRemoveItem(index),
                        priceLabel: selectedType == TransactionType.income
                            ? 'Selling Price'
                            : 'Unit Cost',
                        isSale: selectedType == TransactionType.income,
                      );
                    },
                  ),
                OutlinedButton.icon(
                  onPressed: () => _showSelectProductDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Select Product'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LineItemWidget extends StatelessWidget {
  final TransactionLineItem lineItem;
  final VoidCallback onRemove;
  final String priceLabel;
  final bool isSale;

  const _LineItemWidget({
    required this.lineItem,
    required this.onRemove,
    required this.priceLabel,
    this.isSale = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lineItem.item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: lineItem.quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    suffixText: lineItem.item.unit,
                  ),
                  autofillHints: const [AutofillHints.telephoneNumber],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                  validator: isSale
                      ? (value) {
                          if (value == null || value.isEmpty) return 'Req.';
                          final qty = double.tryParse(value);
                          if (qty == null) return 'Invalid';
                          if (qty > lineItem.item.quantity) {
                            return 'Max: ${lineItem.item.quantity}';
                          }
                          return null;
                        }
                      : null, // No validation for purchases
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: lineItem.priceController,
                  decoration: InputDecoration(
                    labelText: priceLabel,
                    prefixText: '₱',
                  ),
                  autofillHints: const [AutofillHints.telephoneNumber],
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
