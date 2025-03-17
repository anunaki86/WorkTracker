import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/employee.dart';

class EmployeeProfileScreen extends StatelessWidget {
  final Employee employee;

  const EmployeeProfileScreen({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil: ${employee.name}'),
      ),
      body: Column(
        children: [
          _buildProfileHeader(),
          _buildHistoryList(),
          _buildStatistics(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                employee.name.characters.first,
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              employee.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('Nr pracownika: ${employee.employeeNumber}'),
            Text('Stanowisko: ${employee.position}'),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Expanded(
      child: ListView.builder(
        itemCount: employee.workHistory.length,
        itemBuilder: (context, index) {
          final history = employee.workHistory[index];
          return Card(
            child: ListTile(
              title: Text(dateFormat.format(history.date)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zmiana: ${history.shiftType}'),
                  Text('Czas pracy: ${(history.workingMinutes / 60).toStringAsFixed(1)}h'),
                ],
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Brutto: ${history.grossWeight.toStringAsFixed(1)} kg'),
                  Text('Netto: ${history.netWeight.toStringAsFixed(1)} kg'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatistics() {
    final totalHours = employee.workHistory.fold<double>(
      0, (sum, h) => sum + h.workingMinutes / 60);
    
    final totalNetWeight = employee.workHistory.fold<double>(
      0, (sum, h) => sum + h.netWeight);
      
    final averagePerHour = totalHours > 0 
        ? totalNetWeight / totalHours 
        : 0.0;
        
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Przepracowane\ngodziny', '${totalHours.toStringAsFixed(1)}h'),
            _buildStatItem('Suma netto', '${totalNetWeight.toStringAsFixed(1)} kg'),
            _buildStatItem('Średnia/h', '${averagePerHour.toStringAsFixed(1)} kg/h'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
