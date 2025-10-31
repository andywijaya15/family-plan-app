import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/app_bar.dart'; // 👈 import custom AppBar

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final String apiUrl = 'http://localhost:8080/api/categories';
  List categories = [];
  bool isLoading = true;
  final nameController = TextEditingController();

  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetch();
  }

  Future<void> _loadTokenAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    await fetchCategories();
  }

  Future<void> fetchCategories() async {
    if (token == null) return;

    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          categories = jsonDecode(response.body);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Tambah Kategori'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Nama kategori'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              addCategory();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> addCategory() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'name': name}),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        nameController.clear();
        fetchCategories();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah kategori: ${response.body}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> confirmDeleteCategory(int id, String name) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Konfirmasi Hapus'),
        content: Text('Hapus kategori "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              deleteCategory(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$apiUrl/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) fetchCategories();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(title: 'Kategori'), // ✅ pakai appbar global
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Card(
                  color: Colors.grey[850],
                  child: ListTile(
                    title: Text(cat['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () =>
                          confirmDeleteCategory(cat['id'], cat['name']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
