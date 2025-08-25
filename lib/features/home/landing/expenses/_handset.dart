import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:leadership/enums/prf_charge_type.dart';
import 'package:leadership/enums/prf_entry_type.dart';
import 'package:leadership/features/home/cubit/get_expense_categories_cubit.dart';
import 'package:leadership/features/home/cubit/get_members_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/add_allocation_entry_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocation_entries_cubit.dart';
import 'package:leadership/features/home/landing/expenses/cubit/get_allocations_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_allocation.dart';
import 'package:leadership/models/remote/prf_allocation_entry.dart';
import 'package:leadership/models/remote/prf_expense_category.dart';
import 'package:leadership/models/remote/prf_member.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class AccountingEventExpensesViewHandset extends StatefulWidget {
  const AccountingEventExpensesViewHandset({
    required this.accountingEventUlid,
    super.key,
  });

  final String accountingEventUlid;

  @override
  State<AccountingEventExpensesViewHandset> createState() =>
      _AccountingEventExpensesViewHandsetState();
}

class _AccountingEventExpensesViewHandsetState
    extends State<AccountingEventExpensesViewHandset> {
  String get accountingEventUlid => widget.accountingEventUlid;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GetAllocationEntriesCubit>().getAllocationEntries(
      accountingEventUlid: accountingEventUlid,
    );
    context.read<GetExpenseCategoriesCubit>().getExpenseCategories();
    context.read<GetMembersCubit>().getMembers();
    context.read<GetAllocationsCubit>().getAllocations(
      accountingEventUlid: accountingEventUlid,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocListener<AddAllocationEntryCubit, AddAllocationEntryState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            success: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.expenseAddedSuccessfully),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
              _loadData();
              context.read<AddAllocationEntryCubit>().resetState();
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            },
          );
        },
        child: Column(
          children: [
            Expanded(
              child:
                  BlocBuilder<
                    GetAllocationEntriesCubit,
                    GetAllocationEntriesState
                  >(
                    builder: (context, state) {
                      return state.when(
                        initial: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        loaded: (entries) =>
                            _buildExpensesList(context, entries),
                        empty: () => _buildEmptyState(context, l10n),
                        error: (message) => _buildErrorState(context, message),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    List<PRFAllocationEntry> entries,
  ) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildExpenseCard(context, entry)
              .animate()
              .fadeIn(
                duration: 300.ms,
                delay: (index * 50).ms,
              )
              .slideX(begin: 0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildExpenseCard(BuildContext context, PRFAllocationEntry entry) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isCredit = entry.entryType == PRFEntryType.credit;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _showExpenseDetails(context, entry),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.add : Icons.remove,
                      color: isCredit
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.expenseCategory?.name ?? l10n.unknownCategory,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.member?.fullName ?? l10n.unknownMember,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        NumberFormat.currency(
                          symbol: 'KES ',
                          decimalDigits: 0,
                        ).format(entry.amount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCredit
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(entry.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (entry.narration.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.narration,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    context,
                    isCredit ? l10n.credit : l10n.debit,
                    isCredit ? Icons.trending_up : Icons.trending_down,
                    isCredit
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.errorContainer,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    context,
                    entry.chargeType.name,
                    Icons.payment,
                    theme.colorScheme.secondaryContainer,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    String label,
    IconData icon,
    Color backgroundColor,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noExpensesYet,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapTheButtonBelowToAddAnExpense,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showAddExpenseModal(BuildContext context) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) => [
        _buildAddExpenseModalPage(context),
      ],
    );
  }

  WoltModalSheetPage _buildAddExpenseModalPage(BuildContext context) {
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: Text(context.l10n.addExpense),
      isTopBarLayerAlwaysVisible: true,
      child: _AddExpenseForm(
        accountingEventUlid: accountingEventUlid,
        onSuccess: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showExpenseDetails(BuildContext context, PRFAllocationEntry entry) {
    WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (context) => [
        _buildExpenseDetailsModalPage(context, entry),
      ],
    );
  }

  WoltModalSheetPage _buildExpenseDetailsModalPage(
    BuildContext context,
    PRFAllocationEntry entry,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isCredit = entry.entryType == PRFEntryType.credit;

    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: Text(l10n.expenseDetails),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              context,
              l10n.category,
              entry.expenseCategory?.name ?? l10n.unknownCategory,
              Icons.category,
            ),
            _buildDetailRow(
              context,
              l10n.member,
              entry.member?.fullName ?? l10n.unknownMember,
              Icons.person,
            ),
            _buildDetailRow(
              context,
              l10n.type,
              isCredit ? l10n.credit : l10n.debit,
              isCredit ? Icons.trending_up : Icons.trending_down,
              valueColor: isCredit
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
            _buildDetailRow(
              context,
              l10n.paymentMethod,
              entry.chargeType.name,
              Icons.payment,
            ),
            _buildAmountRow(
              context,
              l10n.amount,
              entry.amount,
              isTotal: true,
            ),
            _buildAmountRow(
              context,
              l10n.unitCost,
              entry.unitCost,
            ),
            _buildAmountRow(
              context,
              l10n.quantity,
              entry.quantity,
              isQuantity: true,
            ),
            _buildAmountRow(
              context,
              l10n.charge,
              entry.charge,
            ),
            if (entry.narration.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.description,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.narration,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (entry.confirmationMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                l10n.confirmationMessage,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.confirmationMessage,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 16),
            _buildDetailRow(
              context,
              l10n.dateCreated,
              DateFormat('MMMM dd, yyyy - HH:mm').format(entry.createdAt),
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: valueColor ?? theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    int amount, {
    bool isQuantity = false,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final formattedAmount = isQuantity
        ? amount.toString()
        : NumberFormat.currency(
            symbol: 'KES ',
            decimalDigits: 0,
          ).format(amount);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isQuantity ? Icons.numbers : Icons.attach_money,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  formattedAmount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
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

class _AddExpenseForm extends StatefulWidget {
  const _AddExpenseForm({
    required this.accountingEventUlid,
    required this.onSuccess,
  });

  final String accountingEventUlid;
  final VoidCallback onSuccess;

  @override
  State<_AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<_AddExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _narrationController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _quantityController = TextEditingController();
  final _chargeController = TextEditingController();

  PRFEntryType _selectedEntryType = PRFEntryType.debit;
  PRFChargeType _selectedChargeType = PRFChargeType.cash;
  PRFExpenseCategory? _selectedCategory;
  PRFMember? _selectedMember;
  PRFAllocation? _selectedAllocation;

  @override
  void dispose() {
    _narrationController.dispose();
    _confirmationController.dispose();
    _unitCostController.dispose();
    _quantityController.dispose();
    _chargeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocListener<AddAllocationEntryCubit, AddAllocationEntryState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          success: () => widget.onSuccess(),
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          },
        );
      },
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEntryTypeSelector(context, l10n),
              const SizedBox(height: 16),
              _buildCategoryDropdown(context, l10n),
              const SizedBox(height: 16),
              _buildMemberDropdown(context, l10n),
              const SizedBox(height: 16),
              _buildAllocationDropdown(context, l10n),
              const SizedBox(height: 16),
              _buildChargeTypeDropdown(context, l10n),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _unitCostController,
                      label: l10n.unitCost,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterUnitCost;
                        }
                        if (double.tryParse(value) == null) {
                          return l10n.pleaseEnterValidAmount;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _quantityController,
                      label: l10n.quantity,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseEnterQuantity;
                        }
                        if (int.tryParse(value) == null) {
                          return l10n.pleaseEnterValidQuantity;
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _chargeController,
                label: l10n.charge,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterCharge;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _narrationController,
                label: l10n.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterDescription;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _confirmationController,
                label: l10n.confirmationMessage,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterConfirmationMessage;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              BlocBuilder<AddAllocationEntryCubit, AddAllocationEntryState>(
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.maybeWhen(
                      loading: () => null,
                      orElse: () => _submitForm,
                    ),
                    child: state.maybeWhen(
                      loading: () => const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      orElse: () => Text(l10n.addExpense),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryTypeSelector(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.type,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<PRFEntryType>(
                title: Text(l10n.credit),
                value: PRFEntryType.credit,
                groupValue: _selectedEntryType,
                onChanged: (value) {
                  setState(() {
                    _selectedEntryType = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<PRFEntryType>(
                title: Text(l10n.debit),
                value: PRFEntryType.debit,
                groupValue: _selectedEntryType,
                onChanged: (value) {
                  setState(() {
                    _selectedEntryType = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<GetExpenseCategoriesCubit, GetExpenseCategoriesState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (categories) => DropdownButtonFormField<PRFExpenseCategory>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: l10n.category,
              border: const OutlineInputBorder(),
            ),
            items: categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return l10n.pleaseSelectCategory;
              }
              return null;
            },
          ),
          error: (message) => Text('Error loading categories: $message'),
        );
      },
    );
  }

  Widget _buildMemberDropdown(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<GetMembersCubit, GetMembersState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (members) => DropdownButtonFormField<PRFMember>(
            initialValue: _selectedMember,
            decoration: InputDecoration(
              labelText: l10n.member,
              border: const OutlineInputBorder(),
            ),
            items: members.map((member) {
              return DropdownMenuItem(
                value: member,
                child: Text(member.fullName),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedMember = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return l10n.pleaseSelectMember;
              }
              return null;
            },
          ),
          error: (message) => Text('Error loading members: $message'),
        );
      },
    );
  }

  Widget _buildAllocationDropdown(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<GetAllocationsCubit, GetAllocationsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(child: CircularProgressIndicator()),
          loaded: (allocations) => DropdownButtonFormField<PRFAllocation>(
            initialValue: _selectedAllocation,
            decoration: InputDecoration(
              labelText: l10n.allocation,
              border: const OutlineInputBorder(),
            ),
            items: allocations.map((allocation) {
              return DropdownMenuItem(
                value: allocation,
                child: Text(
                  NumberFormat.currency(
                    symbol: 'KES ',
                    decimalDigits: 0,
                  ).format(allocation.amount),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAllocation = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return l10n.pleaseSelectAllocation;
              }
              return null;
            },
          ),
          empty: () => Text(l10n.noAllocationsFound),
          error: (message) => Text('Error loading allocations: $message'),
        );
      },
    );
  }

  Widget _buildChargeTypeDropdown(BuildContext context, AppLocalizations l10n) {
    return DropdownButtonFormField<PRFChargeType>(
      initialValue: _selectedChargeType,
      decoration: InputDecoration(
        labelText: l10n.paymentMethod,
        border: const OutlineInputBorder(),
      ),
      items: PRFChargeType.values.map((chargeType) {
        return DropdownMenuItem(
          value: chargeType,
          child: Text(chargeType.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedChargeType = value!;
        });
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final unitCost = (double.parse(_unitCostController.text) * 100).round();
      final quantity = int.parse(_quantityController.text);
      final charge = (double.parse(_chargeController.text) * 100).round();

      context.read<AddAllocationEntryCubit>().addAllocationEntry(
        accountingEventUlid: widget.accountingEventUlid,
        allocationUlid: _selectedAllocation!.ulid,
        expenseCategoryUlid: _selectedCategory!.ulid,
        memberUlid: _selectedMember!.ulid,
        entryType: _selectedEntryType,
        chargeType: _selectedChargeType,
        charge: charge,
        unitCost: unitCost,
        quantity: quantity,
        narration: _narrationController.text,
        confirmationMessage: _confirmationController.text,
      );
    }
  }
}
