import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../models/round_config.dart';
import '../../utils/neumorphic_adapter.dart';

class WeightDialog extends StatefulWidget {
  final RoundConfig config;
  
  const WeightDialog({
    super.key,
    required this.config,
  });
  
  @override
  State<WeightDialog> createState() => _WeightDialogState();
}

class _WeightDialogState extends State<WeightDialog> {
  final TextEditingController _weightController = TextEditingController();
  
  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.config.label),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(
              labelText: 'Waga (kg)',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Anuluj'),
        ),
        CustomNeumorphicButton(
          style: NeumorphicStyle(
            color: Theme.of(context).primaryColor,
          ),
          child: const Text(
            'Zatwierdź',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            final weight = int.tryParse(_weightController.text);
            if (weight == null || weight <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wprowadź poprawną wagę')),
              );
              return;
            }
            
            Navigator.pop(context, {'weight': weight});
          },
        ),
      ],
    );
  }
}
