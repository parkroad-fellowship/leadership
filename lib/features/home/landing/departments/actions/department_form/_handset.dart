import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/home/landing/departments/cubit/department_resource_cubit.dart';
import 'package:leadership/models/remote/prf_department.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class DepartmentFormViewHandset extends StatefulWidget {
  const DepartmentFormViewHandset({
    required this.onSaved,
    this.department,
    super.key,
  });

  final PRFDepartment? department;
  final VoidCallback onSaved;

  @override
  State<DepartmentFormViewHandset> createState() =>
      _DepartmentFormViewHandsetState();
}

class _DepartmentFormViewHandsetState extends State<DepartmentFormViewHandset> {
  late final TextEditingController _nameController;
  late PRFActiveStatus _activeStatus;

  String? _nameError;
  bool _showValidation = false;

  bool get _isEditing => widget.department != null;

  bool get _isFormValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final department = widget.department;
    _nameController = TextEditingController(text: department?.name ?? '');
    _activeStatus = department?.isActive ?? PRFActiveStatus.active;
    _nameController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _nameError = null;

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameError = 'Name is required';
    }

    setState(() {
      _showValidation = true;
    });

    return _nameError == null;
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

    final cubit = context.read<DepartmentResourceCubit>();

    if (_isEditing) {
      cubit.updateDepartment(
        ulid: widget.department!.ulid,
        name: _nameController.text.trim(),
        isActive: _activeStatus,
      );
      return;
    }

    cubit.createDepartment(
      name: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DepartmentResourceCubit, ResourceState<PRFDepartment>>(
      listenWhen: (prev, curr) =>
          (curr is ResourceMutated<PRFDepartment> &&
              curr.operation != ResourceOperation.delete) ||
          curr is ResourceError<PRFDepartment>,
      listener: (context, state) {
        switch (state) {
          case ResourceMutated<PRFDepartment>(:final operation):
            if (operation == ResourceOperation.create ||
                operation == ResourceOperation.update) {
              Gaimon.success();
              Navigator.pop(context);
              PRFSnackbar.success(
                context,
                _isEditing
                    ? 'Department updated successfully'
                    : 'Department created successfully',
              );
              widget.onSaved();
            }
          case ResourceError<PRFDepartment>(:final message):
            Gaimon.error();
            PRFSnackbar.error(context, message);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFDepartment> ||
          curr is ResourceError<PRFDepartment>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFDepartment>;

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
                              PRFFormSection(
                                icon: Icons.group_work_outlined,
                                title: 'Name',
                                isRequired: true,

                                margin: const EdgeInsets.only(
                                  bottom: PRFSpacingTokens.md,
                                ),
                                child: PRFTextInput(
                                  hintText: 'Department name',
                                  labelText: 'Name *',
                                  helperText: 'Required',
                                  errorText: _showValidation
                                      ? _nameError
                                      : null,
                                  controller: _nameController,
                                  enabled: !isLoading,
                                  onChanged: (_) {
                                    if (_showValidation) {
                                      _validateForm();
                                    }
                                  },
                                ),
                              ),
                              if (_isEditing)
                                PRFFormSection(
                                  icon: Icons.toggle_on_outlined,
                                  title: 'Status',
                                  subtitle: 'Active or inactive',
                                  margin: const EdgeInsets.only(
                                    bottom: PRFSpacingTokens.md,
                                  ),
                                  child: SwitchListTile(
                                    title: Text(
                                      _activeStatus == PRFActiveStatus.active
                                          ? 'Active'
                                          : 'Inactive',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    value:
                                        _activeStatus == PRFActiveStatus.active,
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _activeStatus = value
                                                  ? PRFActiveStatus.active
                                                  : PRFActiveStatus.inactive;
                                            });
                                          },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
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
                            ? 'Update Department'
                            : 'Create Department',
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
            _isEditing ? Icons.edit_outlined : Icons.group_work_outlined,
            size: 32,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing ? 'Edit Department' : 'Create Department',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? 'Update department details'
                : 'Add a new department to the system',
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
