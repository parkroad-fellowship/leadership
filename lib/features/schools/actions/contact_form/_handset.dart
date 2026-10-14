import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/features/schools/cubit/contact_cubit.dart';
import 'package:leadership/features/schools/cubit/contact_type_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
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
    _nameController = TextEditingController(text: contact?.name ?? '');
    _phoneController = contact != null
        ? _buildPhoneController(contact.phone)
        : PhoneController(
            initialValue: const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
          );
    _emailController = TextEditingController(text: contact?.email ?? '');
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
    final l10n = context.l10n;

    if (name.isEmpty) {
      _nameError = l10n.schoolContactsNameRequired;
    }

    if (phone.isEmpty) {
      _phoneError = l10n.schoolContactsPhoneRequired;
    }

    if (_selectedContactType == null) {
      _typeError = l10n.schoolContactsTypeRequired;
    }

    if (email.isNotEmpty && !_isValidEmail(email)) {
      _emailError = l10n.schoolContactsEmailInvalid;
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
      PRFSnackbar.error(context, l10n.commonFixHighlightedFields);
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
          (prev is ResourceMutating<PRFContact> &&
              prev.operation != ResourceOperation.delete &&
              curr is ResourceListLoaded<PRFContact>) ||
          curr is ResourceError<PRFContact>,
      listener: (context, state) {
        switch (state) {
          case ResourceListLoaded<PRFContact>():
            Gaimon.success();
            Navigator.pop(context);
            PRFSnackbar.success(
              context,
              _isEditing
                  ? context.l10n.schoolContactsUpdated
                  : context.l10n.schoolContactsCreated,
            );
            widget.onSaved();
          case ResourceError<PRFContact>():
            Gaimon.error();
            PRFSnackbar.error(context, context.l10n.commonSaveErrorMessage);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFContact> ||
          curr is ResourceError<PRFContact>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFContact>;
        final enter = PRFMotionTokens.resolve(
          context,
          PRFMotionTokens.enterShort,
        );

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withValues(
                    alpha: PRFOpacities.faint,
                  ),
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
                        .slideY(begin: -0.3, duration: enter)
                        .fadeIn(duration: enter),
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
                                alpha: PRFOpacities.muted,
                              ),
                            ),
                            boxShadow: PRFShadowTokens.card(
                              theme.colorScheme.shadow,
                            ),
                          ),
                          child: _buildFields(theme, isLoading),
                        )
                        .animate(
                          delay: PRFMotionTokens.resolve(
                            context,
                            PRFMotionTokens.stagger3,
                          ),
                        )
                        .slideX(begin: -0.2, duration: enter)
                        .fadeIn(duration: enter),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: PRFButton(
                        onPressed: _submitForm,
                        title: _isEditing
                            ? context.l10n.schoolContactsSave
                            : context.l10n.schoolContactsAdd,
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.raised(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            _isEditing ? Icons.edit_outlined : Icons.person_add_alt_1,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing
                ? context.l10n.schoolContactsEdit
                : context.l10n.schoolContactsAdd,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? context.l10n.schoolContactsFormEditSubtitle
                : context.l10n.schoolContactsFormCreateSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFields(ThemeData theme, bool isLoading) {
    final l10n = context.l10n;
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.badge_outlined,
          title: l10n.schoolContactsNameLabel,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.schoolContactsNameHint,
            labelText: l10n.schoolContactsNameLabel,
            errorText: _showValidation ? _nameError : null,
            controller: _nameController,
            enabled: !isLoading,
          ),
        ),
        PRFFormSection(
          icon: Icons.category_outlined,
          title: l10n.schoolContactsTypeLabel,
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
                  final chipRadius = BorderRadius.circular(PRFRadiusTokens.xl);
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: type.name,
                    excludeSemantics: true,
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        borderRadius: chipRadius,
                        onTap: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedContactType = type;
                                  _typeError = null;
                                });
                              },
                        child: AnimatedContainer(
                          duration: PRFMotionTokens.resolve(
                            context,
                            PRFMotionTokens.standard,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: PRFSpacingTokens.lg,
                            vertical: PRFSpacingTokens.sm,
                          ),
                          constraints: BoxConstraints(
                            minHeight: PRFSizeTokens.minTouchTarget,
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: chipRadius,
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
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
          title: l10n.schoolContactsPhoneLabel,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PRFPhoneInput(
                hintText: l10n.schoolContactsPhoneHint,
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
          title: l10n.schoolContactsEmailLabel,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.schoolContactsEmailHint,
            labelText: l10n.schoolContactsEmailLabel,
            helperText: l10n.schoolsFormOptional,
            errorText: _showValidation ? _emailError : null,
            controller: _emailController,
            enabled: !isLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildNewTypeButton(ThemeData theme) {
    final l10n = context.l10n;
    final foreground = theme.colorScheme.primary;
    return Tooltip(
      message: l10n.schoolContactsNewTypeTooltip,
      child: Semantics(
        button: true,
        label: l10n.schoolContactsNewTypeTooltip,
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          shape: StadiumBorder(
            side: BorderSide(
              color: foreground.withValues(alpha: PRFOpacities.half),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showNewTypeDialog(theme),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: PRFSizeTokens.minTouchTarget,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PRFSpacingTokens.lg,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: PRFSizeTokens.iconSm,
                      color: foreground,
                    ),
                    const SizedBox(width: PRFSpacingTokens.xs),
                    Text(
                      l10n.schoolContactsNewType,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: foreground,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNewTypeDialog(ThemeData theme) async {
    final typeName = await PRFBottomSheet.show<String>(
      context,
      title: context.l10n.schoolContactsNewTypeTitle,
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

  void _listenForNewType(ContactTypeCubit cubit, String name) {
    late final void Function() cancel;
    final sub = cubit.stream.listen((state) {
      if (state case ResourceListLoaded<PRFContactType>(:final items)) {
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
        if (mounted) {
          PRFSnackbar.error(
            context,
            context.l10n.schoolContactsTypeCreateFailed,
          );
        }
        cancel();
      }
    });
    cancel = sub.cancel;
  }

  PhoneController _buildPhoneController(String rawPhone) {
    try {
      final parsed = PhoneNumber.parse(rawPhone);
      return PhoneController(initialValue: parsed);
    } catch (_) {
      return PhoneController(
        initialValue: const PhoneNumber(isoCode: IsoCode.KE, nsn: ''),
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
      _error = isValid ? null : context.l10n.schoolContactsTypeNameRequired;
    });
    return isValid;
  }

  void _submit() {
    if (!_validate()) {
      Gaimon.warning();
      PRFSnackbar.error(context, context.l10n.commonFixHighlightedFields);
      return;
    }

    Gaimon.success();
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final enter = PRFMotionTokens.resolve(context, PRFMotionTokens.enterShort);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(alpha: PRFOpacities.faint),
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
                    .slideY(begin: -0.3, duration: enter)
                    .fadeIn(duration: enter),
                const SizedBox(height: PRFSpacingTokens.xxl),
                Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(
                            alpha: PRFOpacities.muted,
                          ),
                        ),
                        boxShadow: PRFShadowTokens.card(
                          theme.colorScheme.shadow,
                        ),
                      ),
                      child: PRFFormSection(
                        icon: Icons.category_outlined,
                        title: l10n.schoolContactsTypeNameLabel,
                        isRequired: true,
                        margin: EdgeInsets.zero,
                        child: PRFTextField(
                          hintText: l10n.schoolContactsTypeNameHint,
                          labelText: l10n.schoolContactsTypeNameLabel,
                          controller: _controller,
                          errorText: _showValidation ? _error : null,
                        ),
                      ),
                    )
                    .animate(
                      delay: PRFMotionTokens.resolve(
                        context,
                        PRFMotionTokens.stagger3,
                      ),
                    )
                    .slideX(begin: -0.2, duration: enter)
                    .fadeIn(duration: enter),
                const SizedBox(height: PRFSpacingTokens.xxl),
                SizedBox(
                  width: double.infinity,
                  child: PRFButton(
                    onPressed: _submit,
                    title: l10n.schoolContactsCreateType,
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.raised(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            Icons.add_card_outlined,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            context.l10n.schoolContactsNewTypeTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            context.l10n.schoolContactsNewTypeSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(
                alpha: PRFOpacities.nearOpaque,
              ),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
