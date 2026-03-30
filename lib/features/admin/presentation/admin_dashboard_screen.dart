import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WellQueue Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthService>().signOut();
            },
          ),
        ],
      ),
      body: [
        _buildDashboardTab(),
        _buildClinicsTab(),
        _buildQueuesTab(),
        _buildUsersTab(),
      ][_currentTabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_hospital),
            label: 'Clinics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue),
            label: 'Queues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Total Clinics', '0'),
              _buildStatCard('Active Queues', '0'),
              _buildStatCard('Total Users', '0'),
              _buildStatCard('Today\'s Appointments', '0'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClinicsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Show add clinic dialog
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Clinic'),
          ),
          const SizedBox(height: 16),
          const Expanded(
            child: Center(
              child: Text('Clinics management coming soon'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueuesTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text('Queue management coming soon'),
      ),
    );
  }

  Widget _buildUsersTab() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text('Users management coming soon'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
