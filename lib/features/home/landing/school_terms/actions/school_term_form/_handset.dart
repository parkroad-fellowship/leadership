import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/home/landing/missions/cubit/school_term_resource_cubit.dart';
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
    _yearController = TextEditingController(
      text: term?.year.toString() ?? '',
    );
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
      _nameError = 'Term name is required';
    }

    final year = int.tryParse(yearText);
    if (yearText.isEmpty) {
      _yearError = 'Year is required';
    } else if (year == null || year < 1) {
      _yearError = 'Enter a valid year';
    }

    setState(() {
      _showValidation = true;
    });

    return [_nameError, _yearError].every((error) => error == null);
  }

  void _submitForm() {
    if (!_validateForm()) {
      Gaimon.warning();
      PRFSnackbar.error(
        context,
        'Please fix the highlighted fields and try again.',
      );
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

    cubit.createSchoolTerm(
      name: _nameController.text.trim(),
      year: year,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SchoolTermResourceCubit, ResourceState<PRFSchoolTerm>>(
      listenWhen: (prev, curr) =>
          (curr is ResourceMutated<PRFSchoolTerm> &&
              curr.operation != ResourceOperation.delete) ||
          curr is ResourceError<PRFSchoolTerm>,
      listener: (context, state) {
        switch (state) {
          case ResourceMutated<PRFSchoolTerm>(:final operation):
            if (operation == ResourceOperation.create ||
                operation == ResourceOperation.update) {
              Gaimon.success();
              Navigator.pop(context);
              PRFSnackbar.success(
                context,
                _isEditing
                    ? 'School term updated successfully'
                    : 'School term created successfully',
              );
              widget.onSaved();
            }
          case ResourceError<PRFSchoolTerm>(:final message):
            Gaimon.error();
            PRFSnackbar.error(context, message);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFSchoolTerm> ||
          curr is ResourceError<PRFSchoolTerm>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFSchoolTerm>;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  Theme.of(context).colorScheme.surface,
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
                        .slideY(begin: -0.3)
                        .fadeIn(duration: PRFMotionTokens.enterShort),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(PRFSpacingTokens.xl),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(
                              PRFRadiusTokens.lg,
                            ),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.shadow.withValues(alpha: 0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
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
                        .animate(delay: PRFMotionTokens.stagger3)
                        .slideX(begin: -0.2)
                        .fadeIn(),
                    const SizedBox(height: PRFSpacingTokens.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: PRFPrimaryButton(
                        onPressed: _submitForm,
                        title: _isEditing
                            ? 'Update School Term'
                            : 'Create School Term',
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
            isEditing ? Icons.edit_outlined : Icons.calendar_today_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            isEditing ? 'Edit School Term' : 'Create School Term',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            isEditing
                ? 'Update the school term details'
                : 'Add a new school term with name and year',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields(bool isLoading) {
    return Column(
      children: [
        PRFFormSection(
          icon: Icons.calendar_today_outlined,
          title: 'Term Name',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFTextInput(
            hintText: 'Term name',
            labelText: 'Term Name *',
            helperText: 'Required',
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
          title: 'Year',
          isRequired: true,

          margin: const EdgeInsets.only(bottom: PRFSpacingTokens.md),
          child: PRFNumberInput(
            hintText: 'e.g. ${DateTime.now().year}',
            labelText: 'Year *',
            helperText: 'Required',
            errorText: _showValidation ? _yearError : null,
            controller: _yearController,
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PRFSpacingTokens.md,
        vertical: PRFSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? PRFColors.successLight.withValues(alpha: 0.5)
            : PRFColors.gray100.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.md),
        border: Border.all(
          color: isActive
              ? PRFColors.success.withValues(alpha: 0.3)
              : PRFColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 20,
            color: isActive ? PRFColors.successDark : PRFColors.gray500,
          ),
          const SizedBox(width: PRFSpacingTokens.sm),
          Expanded(
            child: Text(
              'Active Status',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
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
