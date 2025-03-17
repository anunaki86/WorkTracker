import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../models/round_config.dart';
import '../../utils/neumorphic_adapter.dart';

class FailureDialog extends StatefulWidget {
  final RoundConfig config;
  
  const FailureDialog({
    super.key,
    required this.config,
  });
  
  @override
  State<FailureDialog> createState() => _FailureDialogState();
}

class _FailureDialogState extends State<FailureDialog> {
  final TextEditingController _detailsController = TextEditingController();
  
  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Zgłoś awarię'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _detailsController,
            decoration: const InputDecoration(
              labelText: 'Opis awarii',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
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
            if (_detailsController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wprowadź opis awarii')),
              );
              return;
            }
            
            Navigator.pop(
              context, 
              {'details': _detailsController.text},
            );
          },
        ),
      ],
    );
  }
}
