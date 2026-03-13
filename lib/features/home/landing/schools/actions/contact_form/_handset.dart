import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:leadership/shared_widgets/input/phone/phone.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:prf_design/prf_design.dart';

class ContactFormViewHandset extends StatefulWidget {
  const ContactFormViewHandset({
    required this.schoolUlid,
    required this.contactTypes,
    required this.onSaved,
    this.contact,
    super.key,
  });

  final PRFContact? contact;
  final String schoolUlid;
  final List<PRFContactType> contactTypes;
  final VoidCallback onSaved;

  @override
  State<ContactFormViewHandset> createState() => _ContactFormViewHandsetState();
}

class _ContactFormViewHandsetState extends State<ContactFormViewHandset> {
  late final TextEditingController _nameController;
  late final PhoneController _phoneController;
  late final TextEditingController _emailController;

  PRFContactType? _selectedContactType;
  late List<PRFContactType> _availableTypes;

  bool get _isEditing => widget.contact != null;

  @override
  void initState() {
    super.initState();
    final contact = widget.contact;
    _nameController = TextEditingController(
      text: contact?.name ?? '',
    );
    _phoneController = contact != null
        ? _buildPhoneController(contact.phone)
        : PhoneController(
            initialValue: const PhoneNumber(
              isoCode: IsoCode.KE,
              nsn: '',
            ),
          );
    _emailController = TextEditingController(
      text: contact?.email ?? '',
    );
    _availableTypes = List.of(widget.contactTypes);

    if (contact?.contactType != null) {
      _selectedContactType = contact!.contactType;
    } else if (_availableTypes.isNotEmpty) {
      _selectedContactType = _availableTypes.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final name = _nameController.text.trim();
    final phone = _phoneController.value.nsn.trim();

    if (name.isEmpty || phone.isEmpty) {
      PRFSnackbar.error(
        context,
        'Please fill in all required fields',
      );
      return false;
    }

    if (_selectedContactType == null) {
      PRFSnackbar.error(
        context,
        'Please select a contact type',
      );
      return false;
    }

    return true;
  }

  void _submitForm() {
    if (!_validateForm()) return;

    final cubit = context.read<ContactCubit>();

    if (_isEditing) {
      cubit.updateContact(
        ulid: widget.contact!.ulid,
        name: _nameController.text.trim(),
        phone: _phoneController.value.international,
        email: _emailController.text.trim(),
        contactTypeUlid: _selectedContactType?.ulid,
      );
    } else {
      cubit.createContact(
        name: _nameController.text.trim(),
        phone: _phoneController.value.international,
        email: _emailController.text.trim(),
        contactTypeUlid: _selectedContactType?.ulid,
        schoolUlid: widget.schoolUlid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ContactCubit, ResourceState<PRFContact>>(
      listenWhen: (prev, curr) =>
          (curr is ResourceMutated<PRFContact> &&
              curr.operation != ResourceOperation.delete) ||
          curr is ResourceError<PRFContact>,
      listener: (context, state) {
        switch (state) {
          case ResourceMutated<PRFContact>(
            :final operation,
          ):
            if (operation == ResourceOperation.create ||
                operation == ResourceOperation.update) {
              Navigator.pop(context);
              PRFSnackbar.success(
                context,
                _isEditing
                    ? 'Contact updated successfully'
                    : 'Contact created successfully',
              );
              widget.onSaved();
            }
          case ResourceError<PRFContact>(
            :final message,
          ):
            PRFSnackbar.error(context, message);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFContact> ||
          curr is ResourceError<PRFContact>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFContact>;

        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: PRFSpacingTokens.lg,
                ),
                _buildFields(theme, isLoading),
                const SizedBox(
                  height: PRFSpacingTokens.xxl,
                ),
                SizedBox(
                  width: double.infinity,
                  child: PRFPrimaryButton(
                    onPressed: _submitForm,
                    title: _isEditing ? 'Update Contact' : 'Add Contact',
                    disabled: isLoading,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(
                  height: PRFSpacingTokens.xxxl,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFields(
    ThemeData theme,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Contact Name
        const PRFFormFieldLabel(
          label: 'Contact Name',
          isRequired: true,
        ),
        PRFTextInput(
          hintText: 'Enter contact name',
          controller: _nameController,
          enabled: !isLoading,
        ),
        const SizedBox(height: PRFSpacingTokens.lg),

        // Contact Type
        const PRFFormFieldLabel(
          label: 'Contact Type',
          isRequired: true,
        ),
        const SizedBox(
          height: PRFSpacingTokens.sm,
        ),
        PRFCategoryChips<PRFContactType>(
          categories: _availableTypes,
          labelBuilder: (type) => type.name,
          selectedCategory: _selectedContactType,
          showAllOption: false,
          onCategorySelected: (type) {
            setState(() {
              _selectedContactType = type;
            });
          },
        ),
        const SizedBox(
          height: PRFSpacingTokens.sm,
        ),
        _buildNewTypeButton(theme),
        const SizedBox(height: PRFSpacingTokens.lg),

        // Phone Number
        const PRFFormFieldLabel(
          label: 'Phone Number',
          isRequired: true,
        ),
        PRFPhoneInput(
          hintText:
              'Enter phone number '
              '(e.g., 254712345678)',
          controller: _phoneController,
          enabled: !isLoading,
        ),
        const SizedBox(height: PRFSpacingTokens.lg),

        // Email Address
        const PRFFormFieldLabel(
          label: 'Email Address',
        ),
        PRFTextInput(
          hintText: 'Enter email address (optional)',
          controller: _emailController,
          enabled: !isLoading,
        ),
      ],
    );
  }

  Widget _buildNewTypeButton(ThemeData theme) {
    return GestureDetector(
      onTap: () => _showNewTypeDialog(theme),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PRFSpacingTokens.md,
          vertical: PRFSpacingTokens.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            PRFRadiusTokens.full,
          ),
          border: Border.all(
            color: PRFColors.limeGreen.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.add,
              size: 16,
              color: PRFColors.limeGreen,
            ),
            const SizedBox(
              width: PRFSpacingTokens.xs,
            ),
            Text(
              'New Type',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: PRFColors.limeGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewTypeDialog(ThemeData theme) {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New Contact Type'),
          content: PRFTextInput(
            hintText: 'Enter type name',
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isEmpty) return;

                final cubit = context.read<ContactTypeCubit>()
                  ..createContactType(name: name);
                Navigator.pop(dialogContext);

                _listenForNewType(cubit, name);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
  }

  void _listenForNewType(
    ContactTypeCubit cubit,
    String name,
  ) {
    late final void Function() cancel;
    final sub = cubit.stream.listen((state) {
      if (state case ResourceMutated<PRFContactType>(
        :final items,
      )) {
        final newType = items.cast<PRFContactType?>().firstWhere(
          (t) => t!.name.toLowerCase() == name.toLowerCase(),
          orElse: () => null,
        );

        if (newType != null && mounted) {
          setState(() {
            _availableTypes = List.of(items);
            _selectedContactType = newType;
          });
        }
        cancel();
      }
      if (state is ResourceError<PRFContactType>) {
        cancel();
      }
    });
    cancel = sub.cancel;
  }

  PhoneController _buildPhoneController(
    String rawPhone,
  ) {
    try {
      final parsed = PhoneNumber.parse(rawPhone);
      return PhoneController(
        initialValue: parsed,
      );
    } catch (_) {
      return PhoneController(
        initialValue: const PhoneNumber(
          isoCode: IsoCode.KE,
          nsn: '',
        ),
      );
    }
  }
}
