import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../../../ai_assistant/domain/services/ai_token_service.dart';

/// Account settings screen
class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final settings = ref.watch(settingsProvider);
    final tokenUsage = ref.watch(tokenUsageProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
      ),
      body: ListView(
        children: [
          // User info section
          if (authState.user != null) ...[
            _buildUserHeader(context, authState.user!),
            const Divider(),
          ],

          // Sync status
          _buildSyncStatusSection(context, settings),

          const Divider(),

          // AI Token Usage
          _buildTokenUsageSection(context, tokenUsage),

          const Divider(),

          // Account management
          _buildSectionHeader(context, 'Account Management'),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Profile'),
            subtitle: const Text('Update your name and avatar'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditProfileDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Change Email'),
            subtitle: Text(authState.user?.email ?? 'Not set'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangeEmailDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordDialog(context, ref),
          ),

          const Divider(),

          // Connected accounts
          _buildSectionHeader(context, 'Connected Accounts'),
          ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            title: const Text('Google'),
            subtitle: Text(_getGoogleStatus(authState)),
            trailing: _buildConnectButton(context, ref, 'google', authState),
          ),
          ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.apple, color: Colors.white, size: 16),
            ),
            title: const Text('Apple'),
            subtitle: Text(_getAppleStatus(authState)),
            trailing: _buildConnectButton(context, ref, 'apple', authState),
          ),

          const Divider(),

          // Data & Storage
          _buildSectionHeader(context, 'Data & Storage'),
          ListTile(
            leading: const Icon(Icons.cloud_sync_outlined),
            title: const Text('Sync Status'),
            subtitle: const Text('Last synced: Just now'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showSyncDetails(context),
          ),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Connected Devices'),
            subtitle: const Text('1 device'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showConnectedDevices(context),
          ),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Export Data'),
            subtitle: const Text('Download your data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showExportDialog(context, ref),
          ),

          const Divider(),

          // Danger zone
          _buildSectionHeader(context, 'Danger Zone'),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text('Sign Out', style: TextStyle(color: theme.colorScheme.error)),
            onTap: () => _showSignOutDialog(context, ref),
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text('Delete Account', style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text('Permanently delete your account and all data'),
            onTap: () => _showDeleteAccountDialog(context, ref),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: user.avatarUrl != null
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: user.avatarUrl == null
                ? Text(
                    user.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusSection(BuildContext context, settings) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'All changes synced',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last sync: ${DateTime.now().toString().substring(0, 16)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenUsageSection(BuildContext context, TokenUsageState tokenUsage) {
    final usagePercentage = tokenUsage.usagePercentage;
    final isNearLimit = tokenUsage.isNearLimit;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.psychology, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'AI Tokens',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${tokenUsage.remaining.toLocaleString()} / ${tokenUsage.limit.toLocaleString()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isNearLimit
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: usagePercentage.clamp(0.0, 1.0),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearLimit
                    ? Theme.of(context).colorScheme.error
                    : tokenUsage.tier == UserTier.free
                        ? Colors.amber
                        : Theme.of(context).colorScheme.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          // Tier info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Plan: ${_getTierLabel(tokenUsage.tier)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (tokenUsage.tier == UserTier.free)
                TextButton(
                  onPressed: () => _showUpgradeDialog(context),
                  child: const Text('Upgrade'),
                ),
            ],
          ),
          if (isNearLimit) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You\'ve used ${(usagePercentage * 100).toInt()}% of your monthly tokens.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getTierLabel(UserTier tier) {
    switch (tier) {
      case UserTier.free:
        return 'Free';
      case UserTier.pro:
        return 'Pro';
      case UserTier.enterprise:
        return 'Enterprise';
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade Your Plan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a plan that fits your needs:'),
            SizedBox(height: 16),
            _PlanOption(
              name: 'Pro',
              tokens: '100,000',
              price: '\$9.99/month',
              features: ['Priority processing', 'Advanced AI features'],
            ),
            SizedBox(height: 12),
            _PlanOption(
              name: 'Enterprise',
              tokens: '1,000,000',
              price: '\$49.99/month',
              features: ['Unlimited processing', 'Custom AI models', 'API access'],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Select Plan'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, WidgetRef ref, String provider, AuthState authState) {
    bool isConnected = false;
    if (provider == 'google') {
      isConnected = authState.user?.providers?.contains('google') ?? false;
    } else if (provider == 'apple') {
      isConnected = authState.user?.providers?.contains('apple') ?? false;
    }

    if (isConnected) {
      return TextButton(
        onPressed: () => _disconnectAccount(context, ref, provider),
        child: const Text('Disconnect'),
      );
    }

    return TextButton(
      onPressed: () => _connectAccount(context, ref, provider),
      child: const Text('Connect'),
    );
  }

  String _getGoogleStatus(AuthState authState) {
    if (authState.user?.providers?.contains('google') ?? false) {
      return 'Connected';
    }
    return 'Not connected';
  }

  String _getAppleStatus(AuthState authState) {
    if (authState.user?.providers?.contains('apple') ?? false) {
      return 'Connected';
    }
    return 'Not connected';
  }

  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController(text: ref.read(authProvider).user?.displayName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Update profile
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Change email
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Change password
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showSyncDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sync Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              const ListTile(
                leading: Icon(Icons.task_alt),
                title: Text('Tasks synced'),
                subtitle: Text('All 45 tasks up to date'),
              ),
              const ListTile(
                leading: Icon(Icons.label_outline),
                title: Text('Tags synced'),
                subtitle: Text('All 8 tags up to date'),
              ),
              const ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text('Settings synced'),
                subtitle: Text('Last synced just now'),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.sync),
                label: const Text('Force Sync Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConnectedDevices(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Connected Devices', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.phone_android),
                title: const Text('iPhone 15 Pro'),
                subtitle: const Text('Current device • Active now'),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  // TODO: Sign out other devices
                  Navigator.pop(context);
                },
                child: const Text('Sign Out All Other Devices'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Your Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose export format:'),
            SizedBox(height: 16),
            RadioListTile<String>(
              title: Text('JSON'),
              subtitle: Text('Best for backup and restore'),
              value: 'json',
              groupValue: 'json',
              onChanged: null,
            ),
            RadioListTile<String>(
              title: Text('CSV'),
              subtitle: Text('Best for spreadsheets'),
              value: 'csv',
              groupValue: 'json',
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: Export data
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export started...')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
              Navigator.pop(context);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This action cannot be undone.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('All your data will be permanently deleted, including:'),
            SizedBox(height: 8),
            Text('• All tasks and subtasks'),
            Text('• Tags and categories'),
            Text('• Points and achievements'),
            Text('• Settings and preferences'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              // TODO: Delete account
              Navigator.pop(context);
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _connectAccount(BuildContext context, WidgetRef ref, String provider) {
    // TODO: Implement OAuth connection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to $provider...')),
    );
  }

  void _disconnectAccount(BuildContext context, WidgetRef ref, String provider) {
    // TODO: Implement account disconnection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Disconnecting $provider...')),
    );
  }
}

/// Helper widget for plan options in upgrade dialog
class _PlanOption extends StatelessWidget {
  final String name;
  final String tokens;
  final String price;
  final List<String> features;

  const _PlanOption({
    required this.name,
    required this.tokens,
    required this.price,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                price,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$tokens tokens/month',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 2),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 12, color: Colors.green),
                const SizedBox(width: 6),
                Text(
                  feature,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

/// Extension for int to add locale formatting
extension IntExtension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(0)},',
    );
  }
}
