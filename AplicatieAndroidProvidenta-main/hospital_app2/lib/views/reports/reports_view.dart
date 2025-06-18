import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/views/reports/report_card_widget.dart';
import 'package:hospital_app/views/reports/results_bar_widget.dart';
import 'package:provider/provider.dart';


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
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text('Rapoarte',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh,
            color: Colors.white,
            ),
            onPressed: _fetchReports,
          ),
          if (!isReporter) // Only show filter button for non-reporter roles
            IconButton(
              icon: Icon(
                _showAllReports ? Icons.filter_list_off : Icons.filter_list,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _showAllReports = !_showAllReports;
                });
              },
              tooltip: _showAllReports ? 'Filtrează rapoarte' : 'Arată toate rapoartele',
            ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.0)),
        )
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            if (!isReporter) const ResultsBar(), // Only show ResultsBar for non-reporter roles
            _buildContent(reportVM, isReporter, authVM.getUsername ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ReportViewModel reportVM, bool isReporter, String username) {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchReports,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Get the base list of reports based on filters (for non-reporters) or all reports (for reporters)
    final baseReports = isReporter 
        ? reportVM.reports // Use all reports for reporters, will filter by username below
        : reportVM.filteredReports;

    // Apply additional filtering
    final filteredReports = isReporter
        ? baseReports.where((report) => report.username == username).toList() // Reporter sees only their reports
        : _showAllReports 
            ? baseReports 
            : baseReports.where((report) => 
                report.category == Provider.of<AuthViewModel>(context, listen: false).getRole || 
                report.username == username || 
                Provider.of<AuthViewModel>(context, listen: false).getRole == 'admin'
              ).toList();

    if (filteredReports.isEmpty) {
      String emptyMessage = isReporter
          ? 'Nu aveți rapoarte create'
          : reportVM.isNewSelected
              ? 'Nu există rapoarte noi disponibile'
              : reportVM.isResolvedSelected
                  ? 'Nu există rapoarte rezolvate'
                  : 'Nu există rapoarte în curs';

      return Expanded(
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        onRefresh: _fetchReports,
        child: ListView.builder(
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