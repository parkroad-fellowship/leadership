import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/missions/cubit/school_term_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_school_term.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class SchoolTermFormViewHandset extends StatefulWidget {
  const SchoolTermFormViewHandset({
    required this.onSaved,
    this.term,
    super.key,
  });

  final PRFSchoolTerm? term;
  final VoidCallback onSaved;

  @override
  State<SchoolTermFormViewHandset> createState() =>
      _SchoolTermFormViewHandsetState();
}

class _SchoolTermFormViewHandsetState extends State<SchoolTermFormViewHandset> {
  late final TextEditingController _nameController;
  late final TextEditingController _yearController;

  late PRFActiveStatus _activeStatus;

  String? _nameError;
  String? _yearError;

  bool _showValidation = false;

  bool get _isEditing => widget.term != null;

  bool get _isFormValid {
    final year = int.tryParse(_yearController.text.trim());

    return _nameController.text.trim().isNotEmpty && year != null && year > 0;
  }

  @override
  void initState() {
    super.initState();
    final term = widget.term;
    _nameController = TextEditingController(text: term?.name ?? '');
    _yearController = TextEditingController(text: term?.year.toString() ?? '');
    _activeStatus = term?.isActive ?? PRFActiveStatus.active;

    _nameController.addListener(_onFormChanged);
    _yearController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _clearErrors() {
    _nameError = null;
    _yearError = null;
  }

  bool _validateForm() {
    _clearErrors();

    final name = _nameController.text.trim();
    final yearText = _yearController.text.trim();

    if (name.isEmpty) {
      _nameError = context.l10n.schoolTermsNameRequired;
    }

    final year = int.tryParse(yearText);
    if (yearText.isEmpty) {
      _yearError = context.l10n.schoolTermsYearRequired;
    } else if (year == null || year < 1) {
      _yearError = context.l10n.schoolTermsYearInvalid;
    }

    setState(() {
      _showValidation = true;
    });

    return [_nameError, _yearError].every((error) => error == null);
  }

  void _submitForm() {
    if (!_validateForm()) {
      Gaimon.warning();
      PRFSnackbar.error(context, context.l10n.commonFixHighlightedFields);
      return;
    }

    final year = int.parse(_yearController.text.trim());
    final cubit = context.read<SchoolTermResourceCubit>();

    if (_isEditing) {
      cubit.updateSchoolTerm(
        ulid: widget.term!.ulid,
        name: _nameController.text.trim(),
        year: year,
        isActive: _activeStatus,
      );
      return;
    }

    cubit.createSchoolTerm(name: _nameController.text.trim(), year: year);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SchoolTermResourceCubit, ResourceState<PRFSchoolTerm>>(
      listenWhen: (prev, curr) =>
          (prev is ResourceMutating<PRFSchoolTerm> &&
              curr is ResourceListLoaded<PRFSchoolTerm>) ||
          curr is ResourceError<PRFSchoolTerm>,
      listener: (context, state) {
        switch (state) {
          case ResourceListLoaded<PRFSchoolTerm>():
            Gaimon.success();
            Navigator.pop(context);
            PRFSnackbar.success(
              context,
              _isEditing
                  ? context.l10n.schoolTermsUpdated
                  : context.l10n.schoolTermsCreated,
            );
            widget.onSaved();
          case ResourceError<PRFSchoolTerm>():
            Gaimon.error();
            PRFSnackbar.error(context, context.l10n.commonSaveErrorMessage);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFSchoolTerm> ||
          curr is ResourceError<PRFSchoolTerm>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFSchoolTerm>;
        final l10n = context.l10n;
        final theme = Theme.of(context);
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
                    _buildHeaderCard(context)
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
                          child: Column(
                            children: [
                              _buildFormFields(isLoading),
                              if (_isEditing) ...[
                                const SizedBox(height: PRFSpacingTokens.md),
                                _buildActiveToggle(isLoading),
                              ],
                            ],
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
                        onPressed: _submitForm,
                        title: _isEditing
                            ? l10n.schoolTermsSave
                            : l10n.schoolTermsAdd,
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

  Widget _buildHeaderCard(BuildContext context) {
    final isEditing = _isEditing;
    final theme = Theme.of(context);

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
            isEditing ? Icons.edit_outlined : Icons.calendar_today_outlined,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            isEditing
                ? context.l10n.schoolTermsEdit
                : context.l10n.schoolTermsAdd,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            isEditing
                ? context.l10n.schoolTermsFormEditSubtitle
                : context.l10n.schoolTermsFormCreateSubtitle,
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

  Widget _buildFormFields(bool isLoading) {
    final l10n = context.l10n;
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.calendar_today_outlined,
          title: l10n.schoolTermsNameLabel,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.schoolTermsNameHint,
            labelText: l10n.schoolTermsNameLabel,
            errorText: _showValidation ? _nameError : null,
            controller: _nameController,
            enabled: !isLoading,
            onChanged: (_) {
              if (_showValidation) {
                _validateForm();
              }
            },
          ),
        ),
        PRFFormSection(
          icon: Icons.date_range_outlined,
          title: l10n.schoolTermsYearLabel,
          isRequired: true,
          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextField(
            hintText: l10n.schoolTermsYearExample('${DateTime.now().year}'),
            labelText: l10n.schoolTermsYearLabel,
            errorText: _showValidation ? _yearError : null,
            controller: _yearController,
            type: PRFTextFieldType.number,
            enabled: !isLoading,
            isLoading: isLoading,
            onChanged: (_) {
              if (_showValidation) {
                _validateForm();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActiveToggle(bool isLoading) {
    final theme = Theme.of(context);
    final isActive = _activeStatus == PRFActiveStatus.active;
    final success = context.statusColors.success;
    final foreground = isActive
        ? success.foreground
        : theme.colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.md,
        vertical: PRFSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? success.background
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(
          color: isActive
              ? success.main.withValues(alpha: PRFOpacities.glow)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: PRFSizeTokens.iconMd,
            color: foreground,
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          Expanded(
            child: Text(
              isActive
                  ? context.l10n.commonActive
                  : context.l10n.commonInactive,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: foreground,
              ),
            ),
          ),
          Switch.adaptive(
            value: isActive,
            onChanged: isLoading
                ? null
                : (value) {
                    setState(() {
                      _activeStatus = value
                          ? PRFActiveStatus.active
                          : PRFActiveStatus.inactive;
                    });
                  },
          ),
        ],
      ),
    );
  }
}
