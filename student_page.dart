import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/student.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  List<Student> _students = [];
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    _refreshStudents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _refreshStudents() async {
    final data = await DatabaseHelper.instance.getStudents();
    setState(() => _students = data);
  }

  void _showMessage(String message, [Color color = Colors.green]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _addOrUpdateStudent() async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    if (name.isEmpty || ageText.isEmpty) {
      _showMessage("Please enter both name and age", Colors.red);
      return;
    }
    final age = int.tryParse(ageText);
    if (age == null || age <= 0) {
      _showMessage("Age must be a valid positive number", Colors.red);
      return;
    }

    if (_selectedId == null) {
      await DatabaseHelper.instance.insertStudent(Student(name: name, age: age));
      _showMessage("Student Added Successfully");
    } else {
      await DatabaseHelper.instance.updateStudent(
        Student(id: _selectedId, name: name, age: age),
      );
      _showMessage("Student Updated Successfully");
    }

    _nameController.clear();
    _ageController.clear();
    _selectedId = null;
    _refreshStudents();
  }

  Future<void> _deleteStudent(int id) async {
    await DatabaseHelper.instance.deleteStudent(id);
    _showMessage("Student Deleted", Colors.orange);
    _refreshStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Database")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: "Age"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _addOrUpdateStudent,
              child: Text(_selectedId == null ? "Add Student" : "Update Student"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _students.isEmpty
                  ? const Center(child: Text("No students found"))
                  : ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return Card(
                    child: ListTile(
                      title: Text(student.name),
                      subtitle: Text("Age: ${student.age}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _nameController.text = student.name;
                              _ageController.text = student.age.toString();
                              _selectedId = student.id;
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStudent(student.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
