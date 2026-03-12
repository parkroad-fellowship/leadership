import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/delete_contact_type_cubit.dart';
import 'package:leadership/models/remote/prf_contact_type.dart';
import 'package:prf_design/prf_design.dart';

class DeleteContactTypeDialog extends StatelessWidget {
  const DeleteContactTypeDialog({
    required this.contactType,
    required this.onContactTypeDeleted,
    super.key,
  });

  final PRFContactType contactType;
  final VoidCallback onContactTypeDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: context.read<DeleteContactTypeCubit>(),
      child: PRFConfirmationDialog(
        title: 'Delete Contact Type',
        message: 'Are you sure you want to delete "${contactType.name}"?',
        isDestructive: true,
        customActions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocConsumer<DeleteContactTypeCubit, DeleteContactTypeState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${contactType.name} deleted successfully',
                      ),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                  onContactTypeDeleted();
                },
                error: (message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(message),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                },
                orElse: () {},
              );
            },
            builder: (context, state) {
              return state.maybeWhen(
                loading: () => const PRFCircularProgressIndicator(),
                orElse: () => TextButton(
                  onPressed: () {
                    context.read<DeleteContactTypeCubit>().deleteContactType(
                      ulid: contactType.ulid,
                    );
                  },
                  child: Text(
                    'Delete',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
