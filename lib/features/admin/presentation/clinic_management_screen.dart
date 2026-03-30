import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/supabase_schema.dart';
import '../../../../core/models/clinic.dart';

class AdminClinicManagementScreen extends StatefulWidget {
  const AdminClinicManagementScreen({super.key});

  @override
  State<AdminClinicManagementScreen> createState() =>
      _AdminClinicManagementScreenState();
}

class _AdminClinicManagementScreenState
    extends State<AdminClinicManagementScreen> {
  late Future<List<Clinic>> _clinicsFuture;

  @override
  void initState() {
    super.initState();
    _clinicsFuture = _fetchClinics();
  }

  Future<List<Clinic>> _fetchClinics() async {
    final response = await Supabase.instance.client
        .from(SupabaseSchema.clinicsTable)
        .select();

    return response.map((e) => Clinic.fromJson(e)).toList();
  }

  void _showAddClinicDialog() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final latController = TextEditingController();
    final lngController = TextEditingController();
    final waitTimeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Clinic'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Clinic Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: waitTimeController,
                decoration: const InputDecoration(labelText: 'Wait Time (min)'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Supabase.instance.client
                    .from(SupabaseSchema.clinicsTable)
                    .insert({
                  SupabaseSchema.clinicName: nameController.text,
                  SupabaseSchema.clinicAddress: addressController.text,
                  SupabaseSchema.clinicLatitude:
                      double.parse(latController.text),
                  SupabaseSchema.clinicLongitude:
                      double.parse(lngController.text),
                  SupabaseSchema.clinicWaitTime:
                      int.parse(waitTimeController.text),
                  SupabaseSchema.clinicRating: 0.0,
                  SupabaseSchema.clinicCreatedAt:
                      DateTime.now().toIso8601String(),
                });

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {
                    _clinicsFuture = _fetchClinics();
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Clinic added successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinic Management'),
      ),
      body: FutureBuilder<List<Clinic>>(
        future: _clinicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final clinics = snapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(clinic.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clinic.address),
                      Text('Wait time: ${clinic.waitTimeMinutes} min'),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          // TODO: Implement edit functionality
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () async {
                          await Supabase.instance.client
                              .from(SupabaseSchema.clinicsTable)
                              .delete()
                              .eq(SupabaseSchema.clinicId, clinic.id);

                          if (mounted) {
                            setState(() {
                              _clinicsFuture = _fetchClinics();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClinicDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
