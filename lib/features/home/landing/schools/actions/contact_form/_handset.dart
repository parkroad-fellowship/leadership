import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/home/landing/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
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

  String? _nameError;
  String? _typeError;
  String? _phoneError;
  String? _emailError;
  bool _showValidation = false;

  bool get _isEditing => widget.contact != null;
  bool get _isFormValid {
    final name = _nameController.text.trim();
    final phone = _phoneController.value.nsn.trim();
    final email = _emailController.text.trim();
    final hasValidEmail = email.isEmpty || _isValidEmail(email);

    return name.isNotEmpty &&
        phone.isNotEmpty &&
        _selectedContactType != null &&
        hasValidEmail;
  }

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

    _nameController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!mounted) {
      return;
    }

    if (_showValidation) {
      _validateForm(showSnackbar: false);
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool _validateForm({bool showSnackbar = true}) {
    final name = _nameController.text.trim();
    final phone = _phoneController.value.nsn.trim();
    final email = _emailController.text.trim();

    _nameError = null;
    _typeError = null;
    _phoneError = null;
    _emailError = null;

    if (name.isEmpty) {
      _nameError = 'Contact name is required';
    }

    if (phone.isEmpty) {
      _phoneError = 'Phone number is required';
    }

    if (_selectedContactType == null) {
      _typeError = 'Please select a contact type';
    }

    if (email.isNotEmpty && !_isValidEmail(email)) {
      _emailError = 'Enter a valid email address';
    }

    final isValid = [
      _nameError,
      _typeError,
      _phoneError,
      _emailError,
    ].every((error) => error == null);

    setState(() {
      _showValidation = true;
    });

    if (!isValid && showSnackbar) {
      Gaimon.warning();
      PRFSnackbar.error(
        context,
        'Please fix the highlighted fields and try again.',
      );
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(email);
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
              Gaimon.success();
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
            Gaimon.error();
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

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.05),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: PRFSpacingTokens.lg),
                    _buildHeaderCard(theme)
                        .animate()
                        .slideY(begin: -0.3)
                        .fadeIn(duration: PRFMotionTokens.enterShort),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.lg,
                            ),
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow.withValues(
                                  alpha: 0.1,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildFields(theme, isLoading),
                        )
                        .animate(delay: PRFMotionTokens.stagger3)
                        .slideX(begin: -0.2)
                        .fadeIn(),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: PRFPrimaryButton(
                        onPressed: _submitForm,
                        title: _isEditing ? 'Update Contact' : 'Add Contact',
                        disabled: isLoading || !_isFormValid,
                        isLoading: isLoading,
                      ),
                    ),
                    const SizedBox(height: PRFSpacingTokens.xxxl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _isEditing ? Icons.edit_outlined : Icons.person_add_alt_1,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing ? 'Edit Contact' : 'Create Contact',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? 'Update contact details for this school'
                : 'Add a contact person to this school',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFields(
    ThemeData theme,
    bool isLoading,
  ) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.badge_outlined,
          title: 'Contact Name',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Enter contact name',
            labelText: 'Contact Name *',
            helperText: 'Required',
            errorText: _showValidation ? _nameError : null,
            controller: _nameController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.category_outlined,
          title: 'Contact Type',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: PRFSpacingTokens.sm,
                runSpacing: PRFSpacingTokens.sm,
                children: _availableTypes.map((type) {
                  final isSelected = _selectedContactType?.ulid == type.ulid;
                  return GestureDetector(
                    onTap: isLoading
                        ? null
                        : () {
                            setState(() {
                              _selectedContactType = type;
                              _typeError = null;
                            });
                          },
                    child: AnimatedContainer(
                      duration: PRFMotionTokens.standard,
                      padding: const EdgeInsets.symmetric(
                        horizontal: PRFSpacingTokens.lg,
                        vertical: PRFSpacingTokens.sm,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.xl),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                      ),
                      child: Text(
                        type.name,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_showValidation && _typeError != null) ...[
                const SizedBox(height: PRFSpacingTokens.xs),
                Text(
                  _typeError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: PRFSpacingTokens.sm),
              _buildNewTypeButton(theme),
            ],
          ),
        ),
        PRFFormSection(
          icon: Icons.phone_outlined,
          title: 'Phone Number',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFPhoneInput(
                hintText:
                    'Enter phone number '
                    '(e.g., 254712345678)',
                controller: _phoneController,
                enabled: !isLoading,
              ),
              if (_showValidation && _phoneError != null) ...[
                const SizedBox(height: PRFSpacingTokens.xs),
                Text(
                  _phoneError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
        PRFFormSection(
          icon: Icons.email_outlined,
          title: 'Email Address',

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Enter email address',
            labelText: 'Email Address',
            helperText: 'Optional',
            errorText: _showValidation ? _emailError : null,
            controller: _emailController,
            enabled: !isLoading,
          ),
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

  Future<void> _showNewTypeDialog(ThemeData theme) async {
    final typeName = await PRFBottomSheet.show<String>(
      context,
      title: 'New Contact Type',
      child: const _NewContactTypeFormBody(),
    );

    if (!mounted || typeName == null || typeName.trim().isEmpty) {
      return;
    }

    final cleanedName = typeName.trim();
    final cubit = context.read<ContactTypeCubit>()
      // ignore: unawaited_futures
      ..createContactType(name: cleanedName);
    _listenForNewType(cubit, cleanedName);
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

class _NewContactTypeFormBody extends StatefulWidget {
  const _NewContactTypeFormBody();

  @override
  State<_NewContactTypeFormBody> createState() =>
      _NewContactTypeFormBodyState();
}

class _NewContactTypeFormBodyState extends State<_NewContactTypeFormBody> {
  late final TextEditingController _controller;
  bool _showValidation = false;
  String? _error;

  bool get _isFormValid => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController()..addListener(_onChanged);
  }

  void _onChanged() {
    if (_showValidation) {
      _validate();
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChanged)
      ..dispose();
    super.dispose();
  }

  bool _validate() {
    final isValid = _controller.text.trim().isNotEmpty;
    setState(() {
      _showValidation = true;
      _error = isValid ? null : 'Contact type name is required';
    });
    return isValid;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(context, 'Please fill in all required fields');
      return;
    }

    Gaimon.success();
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PRFSpacingTokens.lg,
            ),
            child: Column(
              children: [
                const SizedBox(height: PRFSpacingTokens.lg),
                _buildHeaderCard(theme)
                    .animate()
                    .slideY(begin: -0.3)
                    .fadeIn(duration: PRFMotionTokens.enterShort),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(
                              alpha: 0.1,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: PRFFormSection(
                        icon: Icons.category_outlined,
                        title: 'Contact Type Name',

                        isRequired: true,
                        margin: EdgeInsets.zero,
                        child: PRFTextInput(
                          hintText: 'Enter type name',
                          labelText: 'Contact Type Name *',
                          helperText: 'Required',
                          controller: _controller,
                          errorText: _showValidation ? _error : null,
                        ),
                      ),
                    )
                    .animate(delay: PRFMotionTokens.stagger3)
                    .slideX(begin: -0.2)
                    .fadeIn(),
                const SizedBox(height: PRFSpacingTokens.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PRFPrimaryButton(
                    onPressed: _submit,
                    title: 'Create Type',
                    disabled: !_isFormValid,
                  ),
                ),
                const SizedBox(height: PRFSpacingTokens.xxxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_card_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            'New Contact Type',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            'Create a reusable type for school contacts',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
