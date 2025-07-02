import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/views/reports/report_card_widget.dart';
import 'package:hospital_app/views/reports/results_bar_widget.dart';
import 'package:hospital_app/models/report.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../viewmodels/navigation_viewmodel.dart';


class ReportsListView extends StatefulWidget {
  const ReportsListView({super.key});

  @override
  State<ReportsListView> createState() => _ReportsListViewState();
}

class _ReportsListViewState extends State<ReportsListView> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _showAllReports = false;

  @override
  void initState() {
    super.initState();
    _fetchReports(); // Initial fetch when the page is first loaded
  }

  Future<void> _fetchReports() async {
    final reportVM = Provider.of<ReportViewModel>(context, listen: false);
    
    try {
      await reportVM.fetchReports();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load reports: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportVM = Provider.of<ReportViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final isReporter = authVM.getRole == 'reporter';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: CustomAppBar(
        title: 'Rapoarte',
        navigationIndex: PageKey.reports,
        useNavigator: false,
        actions: [
          IconButton(
            onPressed: () {
              final reportVM = Provider.of<ReportViewModel>(context, listen: false);
              reportVM.fetchReports();
            },
            icon: Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
            tooltip: 'Actualizează',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Filter button row (only for non-reporter, non-admin roles)
            if (authVM.getRole != 'reporter' && authVM.getRole != 'admin')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _showAllReports ? AppTheme.primaryBlue : AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.lightGray),
                    ),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _showAllReports = !_showAllReports;
                        });
                      },
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: _showAllReports ? Colors.white : AppTheme.primaryBlue,
                      ),
                      tooltip: _showAllReports ? 'Afișează doar rapoartele mele' : 'Afișează toate rapoartele',
                    ),
                  ),
                ],
              ),
            if (authVM.getRole != 'reporter' && authVM.getRole != 'admin') const SizedBox(height: 8),
            if (!isReporter) const ResultsBar(), // Only show ResultsBar for non-reporter roles
            _buildContent(reportVM, isReporter, authVM.getUsername ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ReportViewModel reportVM, bool isReporter, String username) {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
              Text(
                'Se încarcă rapoartele...',
                style: TextStyle(
                  color: AppTheme.steelGray,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.errorRed.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppTheme.errorRed,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.darkGray,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _fetchReports,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Încearcă din nou'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Get the base list of reports based on user role and filter state
    List<Report> filteredReports;
    final userRole = Provider.of<AuthViewModel>(context, listen: false).getRole;
    
    if (userRole == 'reporter') {
      // Reporter: sees ALL their own reports regardless of status filter
      // First get all reports, then filter by username, then apply status filter if needed
      List<Report> userReports = reportVM.reports.where((report) => report.username == username).toList();
      print('Reporter $username has ${userReports.length} total reports');
      
      // Apply status filtering to user's reports
      if (reportVM.isNewSelected) {
        filteredReports = userReports.where((r) => r.status == 'Nou').toList();
        print('Filtered to ${filteredReports.length} Nou reports');
      } else if (reportVM.isResolvedSelected) {
        filteredReports = userReports.where((r) => r.status == 'Rezolvat').toList();
        print('Filtered to ${filteredReports.length} Rezolvat reports');
      } else if (reportVM.isInProgress) {
        filteredReports = userReports.where((r) => r.status == 'În Progres').toList();
        print('Filtered to ${filteredReports.length} În Progres reports');
      } else {
        // Default case - show all user reports
        filteredReports = userReports;
        print('Showing all ${filteredReports.length} user reports');
      }
    } else if (userRole == 'admin') {
      // Admin: always sees all reports (with current status filter)
      filteredReports = reportVM.filteredReports;
    } else {
      // Other roles: filter based on toggle button
      if (_showAllReports) {
        // Show all reports when filter is activated (with current status filter)
        filteredReports = reportVM.filteredReports;
      } else {
        // Show only reports for their role when filter is not activated (with current status filter)
        filteredReports = reportVM.filteredReports.where((report) => 
          report.category == userRole || report.username == username
        ).toList();
      }
    }

    if (filteredReports.isEmpty) {
      String emptyMessage = isReporter
          ? 'Nu aveți rapoarte create'
          : reportVM.isNewSelected
              ? 'Nu există rapoarte noi disponibile'
              : reportVM.isResolvedSelected
                  ? 'Nu există rapoarte rezolvate'
                  : 'Nu există rapoarte în curs';

      IconData emptyIcon = isReporter
          ? Icons.assignment_outlined
          : reportVM.isNewSelected
              ? Icons.new_releases_outlined
              : reportVM.isResolvedSelected
                  ? Icons.check_circle_outline_rounded
                  : Icons.pending_actions_rounded;

      return Expanded(
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  emptyIcon,
                  size: 64,
                  color: AppTheme.steelGray,
                ),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.steelGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          final reportVM = Provider.of<ReportViewModel>(context, listen: false);
          await reportVM.fetchReports();
        },
        color: AppTheme.primaryBlue,
        backgroundColor: AppTheme.surfaceWhite,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: filteredReports.length,
          itemBuilder: (context, index) {
            final report = filteredReports[index];
            return ReportCardWidget(
              key: ValueKey(report.id + report.status),
              report: report,
            );
          },
        ),
      ),
    );
  }
}