import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/prediction_record.dart';
import '../../providers/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/prediction_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_card.dart';
import '../notifications/notifications_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final user = appState.profile;
    final uid = appState.authService.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.blueBg,
                        backgroundImage: user?.photoUrl != null ? NetworkImage(user!.photoUrl!) : null,
                        child: user?.photoUrl == null
                            ? const Icon(Icons.person, color: AppColors.primaryBlue, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user?.fullName ?? '—',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 2),
                            Text(user?.email ?? '', style: const TextStyle(color: AppColors.subText, fontSize: 12.5)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (uid != null)
                    StreamBuilder<List<PredictionRecord>>(
                      stream: PredictionService().watchPredictions(uid),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return Row(
                          children: [
                            Expanded(child: _stat('Predictions', '$count', AppColors.blueBg, AppColors.primaryBlue)),
                            const SizedBox(width: 10),
                            Expanded(child: _stat('Reports', '$count', AppColors.tealBg, AppColors.teal)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _stat('Age', user?.age != null ? '${user!.age}' : '—', AppColors.purpleBg, AppColors.purple),
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _menuSection(context, 'Account', [
              _MenuItem(Icons.person_outline, 'Personal Information', 'Name, email, contact',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              _MenuItem(Icons.medical_information_outlined, 'Medical History', 'Conditions, allergies',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
              _MenuItem(Icons.notifications_none_rounded, 'Notifications', 'Alerts & reminders',
                  () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            ]),
            const SizedBox(height: 16),
            _menuSection(context, 'Privacy & Data', [
              _MenuItem(Icons.lock_outline, 'Privacy Settings', 'Data sharing preferences', () {}),
              _MenuItem(Icons.folder_outlined, 'Data Export', 'Download your data', () {}),
              _MenuItem(Icons.delete_outline, 'Delete Account', 'Permanent action',
                  () => _confirmDeleteAccount(context),
                  danger: true),
            ]),
            const SizedBox(height: 16),
            _menuSection(context, 'About', [
              _MenuItem(Icons.description_outlined, 'Terms of Service', '', () {}),
              _MenuItem(Icons.shield_outlined, 'Privacy Policy', '', () {}),
              _MenuItem(Icons.support_agent_outlined, 'Help & Support', 'Contact our team', () {}),
              _MenuItem(Icons.info_outline, 'About MaxilloAI', 'App version 1.0.0', () {}),
            ]),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout, color: AppColors.risk),
              label: const Text('Log Out', style: TextStyle(color: AppColors.risk, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFFECACA))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.subText)),
        ],
      ),
    );
  }

  Widget _menuSection(BuildContext context, String title, List<_MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.placeholder, letterSpacing: 0.5)),
        ),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.onTap,
                    leading: Icon(item.icon, color: item.danger ? AppColors.risk : AppColors.subText, size: 22),
                    title: Text(item.label,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: item.danger ? AppColors.risk : AppColors.heading)),
                    subtitle: item.sub.isEmpty ? null : Text(item.sub, style: const TextStyle(fontSize: 11.5)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.placeholder, size: 20),
                  ),
                  if (i != items.length - 1) const Divider(height: 1, indent: 56),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of MaxilloAI?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AppState>().signOut();
            },
            child: const Text('Log Out', style: TextStyle(color: AppColors.risk)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Account'),
        content: const Text(
          'This will permanently delete your account, profile, predictions and reports. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService().deleteAccount();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please sign in again to delete your account: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.risk)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final bool danger;
  _MenuItem(this.icon, this.label, this.sub, this.onTap, {this.danger = false});
}
