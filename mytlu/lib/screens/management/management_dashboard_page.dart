import 'package:flutter/material.dart';
import 'subject_management_page.dart';
import 'attendance_history_page.dart';

class ManagementDashboardPage extends StatelessWidget {
  const ManagementDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D47A1),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: <Widget>[
            _buildManagementButton(
              context: context,
              icon: Icons.school_outlined,
              label: 'Quản lý môn học',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SubjectManagementPage()),
                );
              },
            ),
            _buildManagementButton(
              context: context,
              icon: Icons.school_outlined,
              label: 'Quản lý lớp học',
              onTap: () {},
            ),
            _buildManagementButton(
              context: context,
              icon: Icons.people_outline,
              label: 'Quản lý sinh viên',
              onTap: () {},
            ),
            _buildManagementButton(
              context: context,
              icon: Icons.checklist_rtl_outlined,
              label: 'Quản lý điểm danh',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AttendanceHistoryPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}