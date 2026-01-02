import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/delete_contact_cubit.dart';
import 'package:leadership/models/remote/prf_contact.dart';
import 'package:leadership/shared_widgets/_index.dart';

class DeleteContactDialog extends StatelessWidget {
  const DeleteContactDialog({
    required this.contact,
    required this.onContactDeleted,
    super.key,
  });

  final PRFContact contact;
  final VoidCallback onContactDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: context.read<DeleteContactCubit>(),
      child: AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocConsumer<DeleteContactCubit, DeleteContactState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${contact.name} deleted successfully'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                  onContactDeleted();
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
                    context.read<DeleteContactCubit>().deleteContact(
                      ulid: contact.ulid,
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
