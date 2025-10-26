// lib/src/features/auth/presentation/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:liminetic/src/features/auth/presentation/controllers/profile_controller.dart';
import 'package:liminetic/src/features/auth/presentation/session_provider.dart';

/// A screen for editing the current user's profile information, specifically their username.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field with the user's current username from the session.
    // Reading from the provider in initState is safe.
    final user = ref.read(sessionProvider).value?.appUser;
    _usernameController.text = user?.username ?? '';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  /// Triggers the profile update process using the ProfileController.
  void _saveChanges() {
    final user = ref.read(sessionProvider).value?.appUser;
    if (user != null && _usernameController.text.trim().isNotEmpty) {
      ref
          .read(profileControllerProvider.notifier)
          .updateProfile(
            uid: user.uid,
            username: _usernameController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes from the controller to show feedback.
    ref.listen<AsyncValue<void>>(profileControllerProvider, (_, state) {
      // If an error occurs, show it in a SnackBar.
      if (state.hasError && !state.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error.toString()),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      // On successful update, show a confirmation and pop the screen.
      if (!state.hasError && !state.isLoading && state is AsyncData<void>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        context.pop();
      }
    });

    // Watch the providers to get the current state and user data.
    final profileState = ref.watch(profileControllerProvider);
    final user = ref.watch(sessionProvider).value?.appUser;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              // The UI is simplified to show the user's initial.
              child: CircleAvatar(
                radius: 60,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Text(
                  user?.username.isNotEmpty == true
                      ? user!.username[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              // Use a key to ensure the field updates if the user changes.
              key: ValueKey(user?.email),
              initialValue: user?.email ?? 'No email provided',
              decoration: const InputDecoration(labelText: 'Email Address'),
              enabled: false, // Email is not editable.
            ),
            const SizedBox(height: 32),
            Text(
              'Security',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                title: const Text('Change Password'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  /* TODO: Navigate to a dedicated change password screen */
                },
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: profileState.isLoading ? null : _saveChanges,
              child: profileState.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
