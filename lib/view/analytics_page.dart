import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF4299e1),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('analytics').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Belum ada data analytics.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.bar_chart, color: Color(0xFF4299e1)),
                title: Text(data['title'] ?? 'No Title'),
                subtitle: Text(data['value']?.toString() ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data['timestamp'] != null
                          ? DateTime.fromMillisecondsSinceEpoch(
                              (data['timestamp'] as Timestamp).millisecondsSinceEpoch,
                            ).toLocal().toString()
                          : '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Konfirmasi Hapus'),
                            content: const Text('Yakin ingin menghapus data ini?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Batal'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await doc.reference.delete();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4299e1),
        child: const Icon(Icons.add),
        onPressed: () async {
          String? title;
          String? value;
          await showDialog(
            context: context,
            builder: (context) {
              final titleController = TextEditingController();
              final valueController = TextEditingController();
              return AlertDialog(
                title: const Text('Tambah Data Analytics'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Judul'),
                    ),
                    TextField(
                      controller: valueController,
                      decoration: const InputDecoration(labelText: 'Nilai'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      title = titleController.text;
                      value = valueController.text;
                      Navigator.pop(context);
                    },
                    child: const Text('Simpan'),
                  ),
                ],
              );
            },
          );
          if (title != null && title!.isNotEmpty && value != null && value!.isNotEmpty) {
            await FirebaseFirestore.instance.collection('analytics').add({
              'title': title,
              'value': int.tryParse(value!) ?? value,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        },
        tooltip: 'Tambah Data Analytics',
      ),
    );
  }
}