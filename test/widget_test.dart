import 'package:flutter_test/flutter_test.dart';
import 'package:nowa_aplikacja_pracy/main.dart';
import 'package:flutter/widgets.dart'; // Dodaj ten import

void main() {
  testWidgets('Tracker czasu pracy - test podstawowy', (WidgetTester tester) async {
    // Zbuduj naszą aplikację i wyzwól ramkę.
    await tester.pumpWidget(const WorkTimeTrackerApp());

    // Sprawdź, czy podstawowe elementy interfejsu są obecne
    expect(find.text('Pozostały czas pracy:'), findsOneWidget);
    expect(find.text('Przerwy w pracy'), findsOneWidget);

    // Sprawdź, czy rundy są wyświetlane
    expect(find.text('Runda 1'), findsOneWidget);
    expect(find.text('Runda 2'), findsOneWidget);
    expect(find.text('Runda 3'), findsOneWidget);
    expect(find.text('Runda 4'), findsOneWidget);
    expect(find.text('Runda MAX'), findsOneWidget);

    // Sprawdź, czy wykres z normą jest obecny
    expect(find.text('Wykres z normą'), findsOneWidget);

    // Sprawdź, czy przycisk start/stop jest obecny
    expect(find.text('Start/Stop'), findsOneWidget);

    // Sprawdź, czy przycisk reset jest obecny
    expect(find.text('Reset'), findsOneWidget);

    // Sprawdź, czy licznik czasu jest obecny
    expect(find.byKey(const Key('timeCounter')), findsOneWidget);

    // Sprawdź, czy funkcja serwisowa jest obecna
    expect(find.text('Funkcja serwisowa'), findsOneWidget);

    // Sprawdź, czy funkcja awaria jest obecna
    expect(find.text('Awaria'), findsOneWidget);

    // Sprawdź, czy wskaźnik normy jest obecny
    expect(find.text('Wskaźnik normy'), findsOneWidget);

    // Sprawdź, czy przycisk włączania rundy serwisowej jest obecny
    expect(find.text('Włącz rundę serwisową'), findsOneWidget);

    // Włącz rundę serwisową i sprawdź, czy tekst się zmienia
    await tester.tap(find.text('Włącz rundę serwisową'));
    await tester.pump();
    expect(find.text('Wyłącz rundę serwisową'), findsOneWidget);

    // Sprawdź, czy tekst informacyjny o rundzie serwisowej jest obecny
    expect(find.text('Runda serwisowa - czas nie jest odejmowany od puli godzin ani kilogramy i ubytek'), findsOneWidget);
  });
}