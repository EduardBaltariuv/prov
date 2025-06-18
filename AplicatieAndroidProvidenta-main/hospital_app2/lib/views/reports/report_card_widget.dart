import 'package:flutter/material.dart';
import 'package:hospital_app/models/report.dart';
import 'package:hospital_app/views/reports/report_details_view.dart';

class ReportCardWidget extends StatelessWidget {
  final Report report;

  const ReportCardWidget({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailsView(report: report),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(25, 0, 0, 0),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              report.title,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10.0),

            // Row 1: Location (left) & Date (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(Icons.location_on_outlined, report.location, false),
                _buildInfoRow(Icons.access_time, report.formattedDateTime, true),
              ],
            ),

            const SizedBox(height: 8.0),

            // Row 2: Category (left) & Status (right)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(Icons.category_outlined, report.category, false),
                _buildInfoRow(Icons.check_circle_outline, report.status, true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool rightAligned) {
    if (rightAligned) {
      return Row(
        children: [
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 4),
          Icon(icon, color: Colors.grey, size: 18),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      );
    }
  }
}