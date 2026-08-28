import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// بيانات الجهاز المستخدمة في التقرير التفصيلي.
class ExportDeviceRow {
  const ExportDeviceRow({
    required this.category,
    required this.company,
    required this.model,
    required this.wattage,
    required this.quantity,
    required this.dayHours,
    required this.nightHours,
  });

  final String category;
  final String company;
  final String model;
  final double wattage;
  final double quantity;
  final double dayHours;
  final double nightHours;

  double get dayEnergy => wattage * quantity * dayHours;
  double get nightEnergy => wattage * quantity * nightHours;
  double get dailyEnergy => dayEnergy + nightEnergy;
}

/// ينشئ ملفي PDF وExcel التفصيليين ثم يفتح نافذة المشاركة.
class ReportExportService {
  ReportExportService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<void> exportPdf({
    required int reportId,
    required Map<String, dynamic> result,
  }) async {
    final data = await _loadReportData(reportId, result);
    final document = pw.Document();
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Amiri-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Amiri-Bold.ttf'),
    );

    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(26),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        textDirection: pw.TextDirection.rtl,
        build: (_) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  'شمسنا - تقرير تفصيلي لنتيجة الحساب',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(font: boldFont, fontSize: 19),
                ),
                pw.SizedBox(height: 8),
                _pdfLine('اسم المستخدم', data.displayName, regularFont),
                _pdfLine('اسم التقرير', data.title, regularFont),
                _pdfLine('رقم التقرير', '$reportId', regularFont),
                _pdfLine('تاريخ الإنشاء', data.createdAt, regularFont),
                _pdfLine('جهد النظام', '${data.voltage} فولت', regularFont),
                _pdfLine('نوع البطارية', data.batteryName, regularFont),
                pw.SizedBox(height: 14),
                pw.Text(
                  'ملخص الأحمال والطاقة',
                  style: pw.TextStyle(font: boldFont, fontSize: 15),
                ),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  headers: const ['البيان', 'القيمة'],
                  data: _summaryRows(data.result),
                  headerStyle: pw.TextStyle(font: boldFont, fontSize: 9),
                  cellStyle: pw.TextStyle(font: regularFont, fontSize: 8),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey100,
                  ),
                  cellAlignment: pw.Alignment.centerRight,
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  'تفاصيل الأجهزة والأحمال',
                  style: pw.TextStyle(font: boldFont, fontSize: 15),
                ),
                pw.SizedBox(height: 6),
                pw.TableHelper.fromTextArray(
                  headers: const [
                    'الفئة',
                    'الشركة',
                    'الموديل',
                    'واط',
                    'الكمية',
                    'نهار',
                    'ليل',
                    'اليومي',
                  ],
                  data: data.devices
                      .map(
                        (device) => [
                          device.category,
                          device.company,
                          device.model,
                          _format(device.wattage),
                          _format(device.quantity),
                          _format(device.dayHours),
                          _format(device.nightHours),
                          _format(device.dailyEnergy),
                        ],
                      )
                      .toList(growable: false),
                  headerStyle: pw.TextStyle(font: boldFont, fontSize: 7),
                  cellStyle: pw.TextStyle(font: regularFont, fontSize: 6.5),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey100,
                  ),
                  cellAlignment: pw.Alignment.centerRight,
                  border: pw.TableBorder.all(color: PdfColors.grey400),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  'النتائج تقديرية وفق بيانات الأحمال والافتراضات المعتمدة في المحرك.',
                  style: pw.TextStyle(font: regularFont, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/shamsuna_report_$reportId.pdf');
    await file.writeAsBytes(await document.save(), flush: true);
    await _share(file, 'تقرير شمسنا PDF رقم $reportId');
  }

  Future<void> exportExcel({
    required int reportId,
    required Map<String, dynamic> result,
  }) async {
    final data = await _loadReportData(reportId, result);
    final excel = Excel.createExcel();
    final sheet = excel['تقرير شمسنا'];

    sheet.appendRow([TextCellValue('تقرير شمسنا التفصيلي رقم $reportId')]);
    sheet.appendRow([TextCellValue('بيانات التقرير')]);
    _appendExcelRow(sheet, 'اسم المستخدم', data.displayName);
    _appendExcelRow(sheet, 'اسم التقرير', data.title);
    _appendExcelRow(sheet, 'رقم التقرير', '$reportId');
    _appendExcelRow(sheet, 'تاريخ الإنشاء', data.createdAt);
    _appendExcelRow(sheet, 'جهد النظام', '${data.voltage} فولت');
    _appendExcelRow(sheet, 'نوع البطارية', data.batteryName);

    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([TextCellValue('ملخص الأحمال والطاقة')]);
    for (final row in _summaryRows(data.result)) {
      sheet.appendRow([TextCellValue(row[0]), TextCellValue(row[1])]);
    }

    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([TextCellValue('تفاصيل الأجهزة والأحمال')]);
    sheet.appendRow([
      TextCellValue('الفئة'),
      TextCellValue('الشركة'),
      TextCellValue('الموديل'),
      TextCellValue('القدرة بالواط'),
      TextCellValue('الكمية'),
      TextCellValue('ساعات النهار'),
      TextCellValue('ساعات الليل'),
      TextCellValue('استهلاك النهار واط ساعة'),
      TextCellValue('استهلاك الليل واط ساعة'),
      TextCellValue('الاستهلاك اليومي واط ساعة'),
    ]);

    for (final device in data.devices) {
      sheet.appendRow([
        TextCellValue(device.category),
        TextCellValue(device.company),
        TextCellValue(device.model),
        DoubleCellValue(device.wattage),
        DoubleCellValue(device.quantity),
        DoubleCellValue(device.dayHours),
        DoubleCellValue(device.nightHours),
        DoubleCellValue(device.dayEnergy),
        DoubleCellValue(device.nightEnergy),
        DoubleCellValue(device.dailyEnergy),
      ]);
    }

    for (var index = 0; index < 10; index++) {
      sheet.setColumnWidth(index, index < 3 ? 24 : 18);
    }

    final bytes = excel.encode();
    if (bytes == null) throw Exception('تعذر إنشاء ملف Excel');

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/shamsuna_report_$reportId.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    await _share(file, 'تقرير شمسنا Excel رقم $reportId');
  }

  Future<_ExportData> _loadReportData(
    int reportId,
    Map<String, dynamic> result,
  ) async {
    final report = await _client
        .from('system_reports')
        .select('title, created_at, battery_id, voltage_id, user_id')
        .eq('report_id', reportId)
        .single();

    // هذه الطلبات مستقلة، لذلك تنفيذها بالتوازي يقلل زمن الانتظار الكلي.
    final metadata = await Future.wait<dynamic>([
      _client
          .from('profiles')
          .select('display_name')
          .eq('user_id', report['user_id'])
          .maybeSingle(),
      _client
          .from('system_voltages')
          .select('voltage_value')
          .eq('voltage_id', report['voltage_id'])
          .single(),
      _client
          .from('battery_types')
          .select('name')
          .eq('battery_id', report['battery_id'])
          .single(),
      _client
          .from('report_device_details')
          .select(
<<<<<<< HEAD
            'device_id, custom_device_id, quantity, day_hours, night_hours, category_name_snapshot, company_name_snapshot, model_name_snapshot, wattage_w_snapshot',
=======
            'device_id, quantity, day_hours, night_hours, category_name_snapshot, company_name_snapshot, model_name_snapshot, wattage_w_snapshot',
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
          )
          .eq('report_id', reportId)
          .order('detail_id'),
    ]);

    final profile = metadata[0] as Map<String, dynamic>?;
    final voltageRow = metadata[1] as Map<String, dynamic>;
    final batteryRow = metadata[2] as Map<String, dynamic>;
    final detailRows = metadata[3] as List<dynamic>;

    final deviceIds = detailRows
<<<<<<< HEAD
        .where((row) => row['device_id'] != null)
=======
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
        .map((row) => (row['device_id'] as num).toInt())
        .toSet()
        .toList(growable: false);
    final deviceRows = deviceIds.isEmpty
        ? const <dynamic>[]
        : await _client
              .from('catalog_devices')
              .select(
                'device_id, category_id, company_id, model_name, wattage_w',
              )
              .inFilter('device_id', deviceIds);

    final categoryIds = deviceRows
        .map((row) => (row['category_id'] as num).toInt())
        .toSet()
        .toList(growable: false);
    final companyIds = deviceRows
        .map((row) => (row['company_id'] as num).toInt())
        .toSet()
        .toList(growable: false);
    final lookupRows = await Future.wait<dynamic>([
      categoryIds.isEmpty
          ? Future.value(const <dynamic>[])
          : _client
                .from('device_categories')
                .select('category_id, name_ar')
                .inFilter('category_id', categoryIds),
      companyIds.isEmpty
          ? Future.value(const <dynamic>[])
          : _client
                .from('catalog_companies')
                .select('company_id, name')
                .inFilter('company_id', companyIds),
    ]);
    final categories = lookupRows[0] as List<dynamic>;
    final companies = lookupRows[1] as List<dynamic>;

    final categoryNames = <int, String>{
      for (final row in categories)
        (row['category_id'] as num).toInt(): '${row['name_ar']}',
    };
    final companyNames = <int, String>{
      for (final row in companies)
        (row['company_id'] as num).toInt(): '${row['name']}',
    };
    final deviceById = <int, dynamic>{
      for (final row in deviceRows) (row['device_id'] as num).toInt(): row,
    };

    final devices = detailRows
        .map((row) {
<<<<<<< HEAD
          final deviceId = (row['device_id'] as num?)?.toInt();
          final device = deviceId == null ? null : deviceById[deviceId];
=======
          final device = deviceById[(row['device_id'] as num).toInt()];
>>>>>>> ec2563a0ac07910e35562165fb3765b4c3ba9ba4
          final wattage = device == null
              ? _asDouble(row['wattage_w_snapshot'])
              : _asDouble(device['wattage_w']);
          final category = '${row['category_name_snapshot'] ?? ''}'.trim();
          final company = '${row['company_name_snapshot'] ?? ''}'.trim();
          final model = '${row['model_name_snapshot'] ?? ''}'.trim();
          return ExportDeviceRow(
            category: category.isEmpty
                ? categoryNames[(device?['category_id'] as num?)?.toInt()] ??
                      'غير محدد'
                : category,
            company: company.isEmpty
                ? companyNames[(device?['company_id'] as num?)?.toInt()] ??
                      'غير محدد'
                : company,
            model: model.isEmpty
                ? '${device?['model_name'] ?? 'غير محدد'}'
                : model,
            wattage: wattage,
            quantity: _asDouble(row['quantity']),
            dayHours: _asDouble(row['day_hours']),
            nightHours: _asDouble(row['night_hours']),
          );
        })
        .toList(growable: false);

    return _ExportData(
      displayName: '${profile?['display_name'] ?? 'غير محدد'}',
      title: '${report['title']}',
      createdAt: '${report['created_at']}',
      voltage: _asDouble(voltageRow['voltage_value']).toInt().toString(),
      batteryName: '${batteryRow['name']}',
      result: result,
      devices: devices,
    );
  }

  Future<void> _share(File file, String text) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: text),
    );
  }

  void _appendExcelRow(Sheet sheet, String key, String value) {
    sheet.appendRow([TextCellValue(key), TextCellValue(value)]);
  }

  pw.Widget _pdfLine(String key, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Text(
        '$key: $value',
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  List<List<String>> _summaryRows(Map<String, dynamic> result) {
    final battery =
        '${result['battery_display'] ?? '${_formatValue(result['recommended_battery_ah'])} أمبير ساعة'}'
            .replaceAll('⋅', ' ')
            .replaceAll('·', ' ');

    return [
      ['القدرة القصوى', '${_formatValue(result['peak_load_w'])} واط'],
      ['الطاقة النهارية', '${_formatValue(result['day_energy_wh'])} واط ساعة'],
      ['الطاقة الليلية', '${_formatValue(result['night_energy_wh'])} واط ساعة'],
      ['الطاقة اليومية', '${_formatValue(result['total_energy_wh'])} واط ساعة'],
      ['الألواح الشمسية', _panelText(result)],
      ['إجمالي الألواح', '${_formatValue(result['recommended_panel_wp'])} واط'],
      ['البطارية', battery],
      ['العاكس', '${_formatValue(result['recommended_inverter_w'])} واط'],
      [
        'منظم الشحن',
        '${result['charge_controller_type'] ?? 'MPPT'} ${_formatValue(result['recommended_charge_controller_a'])} أمبير',
      ],
    ];
  }

  String _panelText(Map<String, dynamic> result) {
    final configuration = result['panel_configuration'];
    if (configuration is! List || configuration.isEmpty) {
      return '${_formatValue(result['recommended_panel_wp'])} واط';
    }
    return configuration
        .map((item) {
          final row = Map<String, dynamic>.from(item as Map);
          return '${_formatValue(row['quantity'])} × ${_formatValue(row['wattage_wp'])} واط';
        })
        .join('، ');
  }

  String _formatValue(dynamic raw) {
    final number = _asDouble(raw);
    return number == number.truncateToDouble()
        ? number.toInt().toString()
        : number.toString();
  }

  String _format(double value) => _formatValue(value);

  double _asDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse('$raw') ?? 0;
  }
}

class _ExportData {
  const _ExportData({
    required this.displayName,
    required this.title,
    required this.createdAt,
    required this.voltage,
    required this.batteryName,
    required this.result,
    required this.devices,
  });

  final String displayName;
  final String title;
  final String createdAt;
  final String voltage;
  final String batteryName;
  final Map<String, dynamic> result;
  final List<ExportDeviceRow> devices;
}
