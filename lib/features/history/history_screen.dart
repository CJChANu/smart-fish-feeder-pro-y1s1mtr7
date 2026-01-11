import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../core/services/firebase_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feeding History'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseService().streamHistory(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading history'));
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('No history yet'));
          }

          final map = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
          final sorted = map.entries.toList()
            ..sort((a, b) => b.key.compareTo(a.key));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, index) {
              final entry = sorted[index];
              final data = Map<String, dynamic>.from(entry.value as Map);
              final success = data['success'] ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    success ? Icons.check_circle : Icons.error,
                    color: success ? Colors.green : Colors.red,
                  ),
                  title: Text('Fed ${(data['amount'] ?? 0).toString()}g'),
                  subtitle: Text(entry.key),
                  trailing: Text(data['timestamp'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
