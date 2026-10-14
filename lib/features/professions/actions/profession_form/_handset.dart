import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gaimon/gaimon.dart';
import 'package:leadership/enums/prf_active_status.dart';
import 'package:leadership/features/professions/cubit/profession_resource_cubit.dart';
import 'package:leadership/l10n/l10n.dart';
import 'package:leadership/models/remote/prf_profession.dart';
import 'package:leadership/utils/crud/resource_state.dart';
import 'package:prf_design/prf_design.dart';

class ProfessionFormViewHandset extends StatefulWidget {
  const ProfessionFormViewHandset({
    required this.onSaved,
    this.profession,
    super.key,
  });

  final PRFProfession? profession;
  final VoidCallback onSaved;

  @override
  State<ProfessionFormViewHandset> createState() =>
      _ProfessionFormViewHandsetState();
}

class _ProfessionFormViewHandsetState extends State<ProfessionFormViewHandset> {
  late final TextEditingController _nameController;
  late PRFActiveStatus _activeStatus;

  String? _nameError;
  bool _showValidation = false;

  bool get _isEditing => widget.profession != null;

  bool get _isFormValid => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    final profession = widget.profession;
    _nameController = TextEditingController(text: profession?.name ?? '');
    _activeStatus = profession?.isActive ?? PRFActiveStatus.active;
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

    final cubit = context.read<ProfessionResourceCubit>();

    if (_isEditing) {
      cubit.updateProfession(
        ulid: widget.profession!.ulid,
        name: _nameController.text.trim(),
        isActive: _activeStatus,
      );
      return;
    }

    cubit.createProfession(name: _nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfessionResourceCubit, ResourceState<PRFProfession>>(
      listenWhen: (prev, curr) =>
          (prev is ResourceMutating<PRFProfession> &&
              curr is ResourceListLoaded<PRFProfession>) ||
          curr is ResourceError<PRFProfession>,
      listener: (context, state) {
        switch (state) {
          case ResourceListLoaded<PRFProfession>():
            Gaimon.success();
            Navigator.pop(context);
            PRFSnackbar.success(
              context,
              _isEditing
                  ? context.l10n.professionsUpdated
                  : context.l10n.professionsCreated,
            );
            widget.onSaved();
          case ResourceError<PRFProfession>():
            Gaimon.error();
            PRFSnackbar.error(context, context.l10n.commonSaveErrorMessage);
          default:
            break;
        }
      },
      buildWhen: (prev, curr) =>
          curr is ResourceMutating<PRFProfession> ||
          curr is ResourceError<PRFProfession>,
      builder: (context, state) {
        final isLoading = state is ResourceMutating<PRFProfession>;
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
                                icon: Icons.work_outlined,
                                title: l10n.commonNameLabel,
                                isRequired: true,

                                margin: const EdgeInsets.only(
                                  bottom: PRFSpacingTokens.md,
                                ),
                                child: PRFTextField(
                                  hintText: l10n.professionsNameHint,
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
                            ? l10n.professionsSave
                            : l10n.professionsCreate,
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
            _isEditing ? Icons.edit_outlined : Icons.work_outlined,
            size: PRFSizeTokens.iconXl,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(height: PRFSpacingTokens.sm),
          Text(
            _isEditing
                ? context.l10n.professionsEdit
                : context.l10n.professionsAdd,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PRFSpacingTokens.xs),
          Text(
            _isEditing
                ? context.l10n.professionsFormEditSubtitle
                : context.l10n.professionsFormCreateSubtitle,
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
