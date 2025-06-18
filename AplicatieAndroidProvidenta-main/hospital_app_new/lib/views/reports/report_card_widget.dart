import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_app/models/report.dart';
import 'package:hospital_app/views/reports/report_details_view.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import '../../theme/app_theme.dart';

class ReportCardWidget extends StatelessWidget {
  final Report report;

  const ReportCardWidget({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsView(report: report),
          ),
        );
        // Refresh the reports list when returning from details
        if (context.mounted) {
          final reportVM = Provider.of<ReportViewModel>(context, listen: false);
          await reportVM.fetchReports();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppTheme.getStatusColor(report.status).withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.darkGray.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with status indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.charcoal,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.getStatusColor(report.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppTheme.getStatusIcon(report.status),
                        size: 14,
                        color: AppTheme.getStatusColor(report.status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        report.status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.getStatusColor(report.status),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Row 1: Location (left) & Date (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(Icons.location_on_outlined, report.location, false),
                _buildInfoRow(Icons.access_time, report.formattedDateTime, true),
              ],
            ),

            const SizedBox(height: 8.0),

            // Row 2: Category with icon
            _buildInfoRow(AppTheme.getCategoryIcon(report.category), report.category, false),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool rightAligned) {
    if (rightAligned) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text, 
            style: TextStyle(
              color: AppTheme.steelGray, 
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: AppTheme.steelGray, size: 16),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.steelGray, size: 16),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text, 
              style: TextStyle(
                color: AppTheme.steelGray, 
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }
  }
}