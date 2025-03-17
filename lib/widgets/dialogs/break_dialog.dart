import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import '../../models/round_config.dart';
import '../../utils/neumorphic_adapter.dart';

class BreakDialog extends StatefulWidget {
  final RoundConfig config;
  
  const BreakDialog({
    super.key,
    required this.config,
  });
  
  @override
  State<BreakDialog> createState() => _BreakDialogState();
}

class _BreakDialogState extends State<BreakDialog> {
  final TextEditingController _detailsController = TextEditingController();
  
  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Przerwa - ${widget.config.label}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Czy chcesz dodać przerwę (${widget.config.minutes} minut)?'),
          TextField(
            controller: _detailsController,
            decoration: const InputDecoration(
              labelText: 'Powód przerwy (opcjonalnie)',
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
            Navigator.pop(context, {});
          },
        ),
      ],
    );
  }
}
