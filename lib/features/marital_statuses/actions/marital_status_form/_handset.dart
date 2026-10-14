import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/marital_statuses/cubit/marital_status_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_marital_status.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class MaritalStatusFormViewHandset extends StatefulWidget {
  const MaritalStatusFormViewHandset({
    required this.onSaved,
    this.maritalStatus,
    super.key,
  });

  final PRFMaritalStatus? maritalStatus;
  final VoidCallback onSaved;

  @override
  State<MaritalStatusFormViewHandset> createState() =>
      _MaritalStatusFormViewHandsetState();
}

class _MaritalStatusFormViewHandsetState
    extends State<MaritalStatusFormViewHandset> {
  late final TextEditingController _nameController;
  late PRFActiveStatus _activeStatus;

  String? _nameError;
  bool _showValidation = false;

  bool get _isEditing => widget.maritalStatus != null;

  bool get _isFormValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final maritalStatus = widget.maritalStatus;
    _nameController = TextEditingController(text: maritalStatus?.name ?? '');
    _activeStatus = maritalStatus?.isActive ?? PRFActiveStatus.active;
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
      _nameError = context.l10n.commonNameRequired;
    }

    setState(() {
      _showValidation = true;
    });

    return _nameError == null;
  }

  void _submitForm() {
    if (!_validateForm()) {
      Gaimon.warning();
      PRFSnackbar.error(context, context.l10n.commonFixHighlightedFields);
      return;
    }

    final cubit = context.read<MaritalStatusResourceCubit>();

    if (_isEditing) {
      cubit.updateMaritalStatus(
        ulid: widget.maritalStatus!.ulid,
        name: _nameController.text.trim(),
        isActive: _activeStatus,
      );
      return;
    }

    cubit.createMaritalStatus(name: _nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      MaritalStatusResourceCubit,
      ResourceState<PRFMaritalStatus>
    >(
      listenWhen: (prev, curr) =>
          (prev is ResourceMutating<PRFMaritalStatus> &&
              curr is ResourceListLoaded<PRFMaritalStatus>) ||
          curr is ResourceError<PRFMaritalStatus>,
      listener: (context, state) {
        switch (state) {
          case ResourceListLoaded<PRFMaritalStatus>():
            Gaimon.success();
            Navigator.pop(context);
            PRFSnackbar.success(
              context,
              _isEditing
                  ? context.l10n.maritalStatusesUpdated
                  : context.l10n.maritalStatusesCreated,
            );
            widget.onSaved();
          case ResourceError<PRFMaritalStatus>():
            Gaimon.error();
            PRFSnackbar.error(context, context.l10n.commonSaveErrorMessage);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFMaritalStatus> ||
          curr is ResourceError<PRFMaritalStatus>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFMaritalStatus>;
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
                              PRFFormSection(
                                icon: Icons.favorite_outlined,
                                title: l10n.commonNameLabel,
                                isRequired: true,

                                margin: const EdgeInsets.only(
                                  bottom: PRFSpacingTokens.md,
                                ),
                                child: PRFTextField(
                                  hintText: l10n.maritalStatusesNameHint,
                                  labelText: l10n.commonNameLabel,
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
                                  title: l10n.commonStatusLabel,
                                  margin: const EdgeInsets.only(
                                    bottom: PRFSpacingTokens.md,
                                  ),
                                  child: SwitchListTile(
                                    title: Text(
                                      _activeStatus == PRFActiveStatus.active
                                          ? l10n.commonActive
                                          : l10n.commonInactive,
                                      style: theme.textTheme.bodyMedium,
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
                            ? l10n.maritalStatusesSave
                            : l10n.maritalStatusesCreate,
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
            theme.colorScheme.primary.withValues(alpha: PRFOpacities.stronger),
          ],
        ),
        borderRadius: BorderRadius.circular(PRFRadiusTokens.lg),
        boxShadow: PRFShadowTokens.raised(theme.colorScheme.primary),
      ),
      child: Column(
        children: [
          Icon(
            _isEditing ? Icons.edit_outlined : Icons.favorite_outlined,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing
                ? context.l10n.maritalStatusesEdit
                : context.l10n.maritalStatusesAdd,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? context.l10n.maritalStatusesFormEditSubtitle
                : context.l10n.maritalStatusesFormCreateSubtitle,
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
