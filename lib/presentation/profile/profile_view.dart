import 'package:bili_sense/core/constants/app_router.dart';
import 'package:bili_sense/core/network/di.dart';
import 'package:bili_sense/core/service/shared_prefs_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<SharedPreferenceHelper>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 35,
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prefs.userModel.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            prefs.userModel.email,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              onTap: () {
                // TODO: Navigate to Privacy Policy screen
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.gavel,
              title: 'Terms & Conditions',
              onTap: () {
                // TODO: Navigate to Terms & Conditions screen
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'BiliSense',
                  applicationVersion: 'v1.0.0',
                  applicationLegalese: '© 2025 CareNX Innovations',
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.login_outlined,
              title: 'Logout',
              onTap: () async {
                await getIt<SharedPreferenceHelper>().clearAll();
                await getIt<FirebaseAuth>().signOut();
                context.goNamed(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}



