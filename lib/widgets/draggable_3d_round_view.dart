// Restore the draggable 3D round view code
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/work_provider.dart';

class Draggable3DRoundView extends StatefulWidget {
  const Draggable3DRoundView({super.key});

  @override
  _Draggable3DRoundViewState createState() => _Draggable3DRoundViewState();
}

class _Draggable3DRoundViewState extends State<Draggable3DRoundView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Draggable(
              feedback: Opacity(
                opacity: 0.5,
                child: Container(
                  width: 100,
                  height: 100.0,
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha((0.5 * 255).round()),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              childWhenDragging: Container(
                width: 100,
                height: 100.0,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: Container(
                width: 100,
                height: 100.0,
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha((0.5 * 255).round()),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            _buildProductivityWidget(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityWidget(BuildContext context) {
    final workProvider = Provider.of<WorkProvider>(context);
    
    double currentWeight = workProvider.getCurrentWeight();
    double netWeight = workProvider.calculateNetWeight(currentWeight);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.2 * 255).round()),
            spreadRadius: 2,
            blurRadius: 5,
          )
        ]
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Aktualna produktywność',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Aktualna waga: ${currentWeight.toStringAsFixed(1)} kg',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Waga netto: ${netWeight.toStringAsFixed(1)} kg',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Norma 1', '${workProvider.hourlyNorm1.toStringAsFixed(1)} kg/h'),
              _buildStatItem('Norma 2', '${workProvider.hourlyNorm2.toStringAsFixed(1)} kg/h'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Text(title + ': ' + value);
  }

  void myFunction(BuildContext context) {
    print('myFunction was called');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('myFunction was called')));
  }
}
