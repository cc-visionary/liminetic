// lib/src/features/farm_os/team/presentation/screens/my_team_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liminetic/src/common_widgets/responsive_scaffold.dart';
import 'package:liminetic/src/features/farm_os/settings/team/presentation/controllers/team_controller.dart';

/// A screen for displaying and managing the members of a farm team.
class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  /// A helper method to show the dialog for adding a new team member.
  void _showAddMemberDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const AddMemberDialog());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the stream provider to get the list of team members.
    final teamAsyncValue = ref.watch(teamProvider);

    // Listen to the controller's state to show a SnackBar on error.
    ref.listen<AsyncValue<void>>(teamControllerProvider, (_, state) {
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('My Team')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMemberDialog(context),
        child: const Icon(Icons.person_add_alt_1),
      ),
      body: teamAsyncValue.when(
        data: (members) {
          if (members.isEmpty) {
            return const Center(child: Text('Add your first team member!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      member.username.isNotEmpty
                          ? member.username[0].toUpperCase()
                          : '',
                    ),
                  ),
                  title: Text(
                    member.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(member.role),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to member details/permissions screen
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Failed to load team: $error')),
      ),
    );
  }
}

/// A dialog form for creating a new team member.
class AddMemberDialog extends ConsumerStatefulWidget {
  const AddMemberDialog({super.key});
  @override
  ConsumerState<AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends ConsumerState<AddMemberDialog> {
  // This part remains exactly the same as the previous correct version.
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref
          .read(teamControllerProvider.notifier)
          .addMember(
            username: _usernameController.text.trim(),
            password: _passwordController.text.trim(),
            role: _roleController.text.trim(),
          );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamControllerProvider);
    return AlertDialog(
      title: const Text('Add Team Member'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Username cannot be empty'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role (e.g., Field Worker)',
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? 'Please assign a role'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Temporary Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordObscured = !_isPasswordObscured,
                    ),
                  ),
                ),
                validator: (value) => (value?.length ?? 0) < 6
                    ? 'Password must be at least 6 characters'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: teamState.isLoading ? null : _submit,
          child: teamState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Member'),
        ),
      ],
    );
  }
}
