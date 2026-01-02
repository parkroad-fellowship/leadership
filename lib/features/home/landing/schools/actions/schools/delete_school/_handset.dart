import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leadership/features/home/landing/schools/cubit/delete_school_cubit.dart';
import 'package:leadership/models/remote/prf_school.dart';
import 'package:leadership/shared_widgets/_index.dart';

class DeleteSchoolDialog extends StatelessWidget {
  const DeleteSchoolDialog({
    required this.school,
    required this.onSchoolDeleted,
    super.key,
  });

  final PRFSchool school;
  final VoidCallback onSchoolDeleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: context.read<DeleteSchoolCubit>(),
      child: AlertDialog(
        title: const Text('Delete School'),
        content: Text('Are you sure you want to delete ${school.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocConsumer<DeleteSchoolCubit, DeleteSchoolState>(
            listener: (context, state) {
              state.maybeWhen(
                loaded: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${school.name} deleted successfully'),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                  onSchoolDeleted();
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
                    context.read<DeleteSchoolCubit>().deleteSchool(
                      ulid: school.ulid,
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
