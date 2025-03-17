import '../models/work_day.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class ReportService {
  final _logger = Logger('ReportService');

  Future<void> sendWeeklyReport(String employeeEmail, List<WorkDay> workDays) async {
    final String reportText = _generateReportText(workDays);
    _logger.info('Sending report to: $employeeEmail\n$reportText');
    
    // TODO: Implement email sending with actual SMTP server
  }

  String _generateReportText(List<WorkDay> workDays) {
    final DateFormat dateFormat = DateFormat('dd.MM.yyyy');
    final sb = StringBuffer();
    
    sb.writeln('Raport tygodniowy:');
    sb.writeln('================');
    
    for (var day in workDays) {
      sb.writeln(
        '${dateFormat.format(day.date)}: ${day.hoursWorked}h '
        '(${day.wasNightShift ? "zmiana nocna" : "zmiana dzienna"})'
      );
    }
    
    final totalHours = workDays.fold<int>(
      0, (sum, day) => sum + day.hoursWorked
    );
    
    sb.writeln('================');
    sb.writeln('Suma godzin: $totalHours');
    
    return sb.toString();
  }
}