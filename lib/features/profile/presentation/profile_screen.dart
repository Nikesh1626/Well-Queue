import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/presentation/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthService>().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) {
      return const Center(child: Text('No user data'));
    }
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 390;

    final initials = '${user.firstName.isNotEmpty ? user.firstName[0] : 'U'}${user.lastName.isNotEmpty ? user.lastName[0] : ''}'.toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: Color(0xFF00695C)),
            SizedBox(width: 8),
            Text('WellQueue'),
          ],
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: isCompact ? 16 : 20),
            CircleAvatar(
              radius: isCompact ? 54 : 62,
              backgroundColor: Colors.white,
              child: Text(
                initials,
                style: TextStyle(fontSize: isCompact ? 34 : 42, fontWeight: FontWeight.w700, color: const Color(0xFF00695C)),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                user.fullName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: isCompact ? 34 : 42, fontWeight: FontWeight.w700, height: 1.05),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                user.email,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: const Color(0xFF5A7078), fontSize: isCompact ? 15 : 17),
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE1EAEE)),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFD8ECEE), child: Icon(Icons.phone, color: Color(0xFF4B616B))),
                      title: const Text('Phone', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(user.phone ?? '-'),
                    ),
                    ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFD8ECEE), child: Icon(Icons.cake, color: Color(0xFF4B616B))),
                      title: const Text('Age', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(user.age?.toString() ?? '-'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleLogout(context),
                  icon: const Icon(Icons.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD44E4E),
                    minimumSize: Size.fromHeight(isCompact ? 46 : 50),
                  ),
                  label: const Text('Sign Out'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
