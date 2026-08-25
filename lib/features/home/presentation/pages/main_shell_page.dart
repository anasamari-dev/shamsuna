import 'package:flutter/material.dart';

import '../../../../core/widgets/shamsuna_bottom_bar.dart';
import '../../../calculation/presentation/pages/report_devices_page.dart';
import '../../../calculation/presentation/pages/report_setup_page.dart';
import '../../../reports/presentation/pages/compare_reports_page.dart';
import '../../../reports/presentation/pages/my_reports_page.dart';
import '../../../suggestions/presentation/pages/suggest_device_page.dart';
import 'home_page.dart';

/// الحاوية الرئيسية التي تبقي الشريط ثابتًا وتحرك محتوى body فقط.
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _currentIndex = 2; // الرئيسية هي التبويب الافتراضي.

  void _selectTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          ReportSetupPage(
            showBottomBar: false,
            onContinue: (draft) => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ReportDevicesPage(draft: draft, showBottomBar: false),
              ),
            ),
          ),
          const MyReportsPage(showBottomBar: false),
          const HomePage(showBottomBar: false),
          const CompareReportsPage(showBottomBar: false),
          const SuggestDevicePage(showBottomBar: false),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: ShamsunaBottomBar(
          currentIndex: _currentIndex,
          onCreateReport: () => _selectTab(0),
          onMyReports: () => _selectTab(1),
          onHome: () => _selectTab(2),
          onCompare: () => _selectTab(3),
          onSuggestDevice: () => _selectTab(4),
        ),
      ),
    );
  }
}

/// مفتاح ثابت لتسهيل إعادة استخدام الحاوية في الاختبارات.
const mainShellTabCount = 5;

void assertMainShellTabs() {
  assert(mainShellTabCount == 5);
}
