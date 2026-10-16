import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MachineHealthApp());
}

// ============================================================
// APP
// ============================================================

class MachineHealthApp extends StatelessWidget {
  const MachineHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Machine Health Monitor',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
      ),
      home: const DashboardScreen(),
    );
  }
}

// ============================================================
// DASHBOARD
// ============================================================

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Machine Health Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Add sample machines',
            onPressed: () async {
              await addSampleMachines();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sample machines added to Firestore'),
                ),
              );
            },
            icon: const Icon(Icons.cloud_upload_outlined),
          ),
        ],
      ),

      // REAL-TIME FIRESTORE LISTENER
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('machines')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final machines = snapshot.data?.docs ?? [];

          if (machines.isEmpty) {
            return EmptyMachineView(
              onAdd: () async {
                await addSampleMachines();
              },
            );
          }

          int running = 0;
          int idle = 0;
          int error = 0;

          for (final machine in machines) {
            final state = machine.data()['state'];

            if (state == 'running') {
              running++;
            } else if (state == 'idle') {
              idle++;
            } else if (state == 'error') {
              error++;
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              await addSampleMachines();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // SUMMARY
                Row(
                  children: [
                    Expanded(
                      child: StatusSummaryCard(
                        title: 'Running',
                        count: running,
                        icon: Icons.play_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusSummaryCard(
                        title: 'Idle',
                        count: idle,
                        icon: Icons.pause_circle,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatusSummaryCard(
                        title: 'Error',
                        count: error,
                        icon: Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                const Text(
                  'Machines',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // MACHINE LIST
                ...machines.map(
                  (doc) {
                    final data = doc.data();

                    final name =
                        data['name'] ?? 'Unknown Machine';

                    final state =
                        data['state'] ?? 'idle';

                    final temperature =
                        ((data['temperature'] ?? 0) as num)
                            .toDouble();

                    final vibration =
                        ((data['vibration'] ?? 0) as num)
                            .toDouble();

                    return MachineCard(
                      machineId: doc.id,
                      name: name.toString(),
                      state: state.toString(),
                      temperature: temperature,
                      vibration: vibration,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// MACHINE CARD
// ============================================================

class MachineCard extends StatelessWidget {
  final String machineId;
  final String name;
  final String state;
  final double temperature;
  final double vibration;

  const MachineCard({
    super.key,
    required this.machineId,
    required this.name,
    required this.state,
    required this.temperature,
    required this.vibration,
  });

  @override
  Widget build(BuildContext context) {
    Color stateColor;

    IconData stateIcon;

    if (state == 'running') {
      stateColor = Colors.green;
      stateIcon = Icons.play_circle_fill;
    } else if (state == 'idle') {
      stateColor = Colors.orange;
      stateIcon = Icons.pause_circle_filled;
    } else {
      stateColor = Colors.red;
      stateIcon = Icons.error;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),

        leading: CircleAvatar(
          radius: 28,
          backgroundColor: stateColor.withValues(alpha: 0.15),
          child: Icon(
            Icons.precision_manufacturing,
            color: stateColor,
            size: 30,
          ),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Icon(
                stateIcon,
                size: 18,
                color: stateColor,
              ),
              const SizedBox(width: 5),
              Text(
                state.toUpperCase(),
                style: TextStyle(
                  color: stateColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MachineDetailScreen(
                machineId: machineId,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// MACHINE DETAIL SCREEN
// ============================================================

class MachineDetailScreen extends StatelessWidget {
  final String machineId;

  const MachineDetailScreen({
    super.key,
    required this.machineId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Machine Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // FETCH SENSOR DATA FROM FIRESTORE
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('machines')
            .doc(machineId)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Machine not found'),
            );
          }

          final data = snapshot.data!.data()!;

          final name =
              data['name'] ?? 'Machine';

          final state =
              data['state'] ?? 'idle';

          final temperature =
              ((data['temperature'] ?? 0) as num)
                  .toDouble();

          final vibration =
              ((data['vibration'] ?? 0) as num)
                  .toDouble();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [

              // MACHINE HEADER
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.precision_manufacturing,
                        size: 80,
                        color: Colors.blue,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        name.toString(),
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      StatusChip(
                        state: state.toString(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Sensor Readings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // TEMPERATURE
              SensorCard(
                title: 'Temperature',
                value: '${temperature.toStringAsFixed(1)} °C',
                icon: Icons.thermostat,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              // VIBRATION
              SensorCard(
                title: 'Vibration',
                value: '${vibration.toStringAsFixed(2)} mm/s',
                icon: Icons.vibration,
                color: Colors.purple,
              ),

              const SizedBox(height: 20),

              // HEALTH STATUS
              HealthStatusCard(
                temperature: temperature,
                vibration: vibration,
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// STATUS CHIP
// ============================================================

class StatusChip extends StatelessWidget {
  final String state;

  const StatusChip({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    if (state == 'running') {
      color = Colors.green;
    } else if (state == 'idle') {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        state.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// SENSOR CARD
// ============================================================

class SensorCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEALTH STATUS
// ============================================================

class HealthStatusCard extends StatelessWidget {
  final double temperature;
  final double vibration;

  const HealthStatusCard({
    super.key,
    required this.temperature,
    required this.vibration,
  });

  @override
  Widget build(BuildContext context) {
    final bool warning =
        temperature > 80 || vibration > 5;

    return Card(
      color: warning
          ? Colors.red.shade50
          : Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              warning
                  ? Icons.warning
                  : Icons.check_circle,
              color: warning
                  ? Colors.red
                  : Colors.green,
                  size: 35,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                warning
                    ? 'Warning: Abnormal sensor readings detected.'
                    : 'Machine health is normal.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: warning
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class StatusSummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const StatusSummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
            ),

            const SizedBox(height: 5),

            Text(
              '$count',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY VIEW
// ============================================================

class EmptyMachineView extends StatelessWidget {
  final VoidCallback onAdd;

  const EmptyMachineView({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.precision_manufacturing_outlined,
              size: 80,
              color: Colors.grey,
            ),

            const SizedBox(height: 15),

            const Text(
              'No machines found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add sample machine data to Firestore.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 18),

            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Add Sample Machines'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FIRESTORE - ADD SAMPLE DATA
// ============================================================

Future<void> addSampleMachines() async {
  final firestore = FirebaseFirestore.instance;

  final machines = [
    {
      'id': 'machine_01',
      'name': 'Machine 01',
      'state': 'running',
      'temperature': 72.5,
      'vibration': 2.4,
    },
    {
      'id': 'machine_02',
      'name': 'Machine 02',
      'state': 'idle',
      'temperature': 45.2,
      'vibration': 0.8,
    },
    {
      'id': 'machine_03',
      'name': 'Machine 03',
      'state': 'error',
      'temperature': 91.7,
      'vibration': 6.3,
    },
  ];

  final batch = firestore.batch();

  for (final machine in machines) {
    final id = machine['id'] as String;

    final ref = firestore
        .collection('machines')
        .doc(id);

    batch.set(
      ref,
      {
        'name': machine['name'],
        'state': machine['state'],
        'temperature': machine['temperature'],
        'vibration': machine['vibration'],
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  await batch.commit();
}