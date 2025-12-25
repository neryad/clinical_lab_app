import 'package:clinical_lab_app/core/models/user_profile.dart';
import 'package:clinical_lab_app/features/users/presentation/users_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final _searchQueryProvider = StateProvider<String>((ref) => '');

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersListProvider);
    final searchQuery = ref.watch(_searchQueryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) =>
                  ref.read(_searchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
          Expanded(
            child: usersAsync.when(
              data: (users) {
                final filteredUsers = users.where((user) {
                  final name = user.fullName?.toLowerCase() ?? '';
                  final email = user.email.toLowerCase();
                  final query = searchQuery.toLowerCase();
                  return name.contains(query) || email.contains(query);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron usuarios.'),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    return _UserListItem(user: filteredUsers[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserListItem extends ConsumerWidget {
  final UserProfile user;

  const _UserListItem({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const mobileBreakpoint = 600;
          const tabletBreakpoint = 900;

          if (constraints.maxWidth < mobileBreakpoint) {
            // Mobile layout
            return ExpansionTile(
              title: Text(user.fullName ?? '-'),
              subtitle: Text(user.email),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Rol',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          _buildRoleChip(theme),
                        ],
                      ),
                      const Divider(height: 24),
                      Center(
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Cambiar Rol'),
                          onPressed: () => _showRoleDialog(context, ref, user),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (constraints.maxWidth < tabletBreakpoint) {
            // Tablet layout
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName ?? '-',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(user.email, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRoleChip(theme),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Cambiar Rol',
                        onPressed: () => _showRoleDialog(context, ref, user),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else {
            // Desktop layout
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(flex: 2, child: Text(user.fullName ?? '-')),
                  Expanded(flex: 3, child: Text(user.email)),
                  Expanded(flex: 1, child: _buildRoleChip(theme)),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Cambiar Rol',
                        onPressed: () => _showRoleDialog(context, ref, user),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildRoleChip(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: user.role == 'admin'
            ? Colors.orange.withOpacity(0.2)
            : Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        user.role.toUpperCase(),
        style: TextStyle(
          color: user.role == 'admin' ? Colors.orange : Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, WidgetRef ref, UserProfile user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cambiar Rol'),
        content: Text('Selecciona el nuevo rol para ${user.email}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(usersRepositoryProvider)
                  .updateUserRole(user.id, 'client');
              if (context.mounted) Navigator.pop(ctx);
              ref.refresh(usersListProvider);
            },
            child: const Text('Cliente'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(usersRepositoryProvider)
                  .updateUserRole(user.id, 'admin');
              if (context.mounted) Navigator.pop(ctx);
              ref.refresh(usersListProvider);
            },
            child: const Text('Admin'),
          ),
        ],
      ),
    );
  }
}
