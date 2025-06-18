import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';

class ResultsBar extends StatelessWidget {
  const ResultsBar({super.key});

  @override
  Widget build(BuildContext context) {
    final reportVM = Provider.of<ReportViewModel>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Wrap the ChoiceChips in a SingleChildScrollView to allow horizontal scrolling
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // "Noi" Button
                  ChoiceChip(
                    backgroundColor: AppTheme.lightGray,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: reportVM.isNewSelected ? AppTheme.infoBlue : Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    showCheckmark: false,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fiber_new_rounded,
                          size: 16,
                          color: reportVM.isNewSelected ? Colors.white : AppTheme.infoBlue,
                        ),
                        const SizedBox(width: 4),
                        const Text("Noi"),
                      ],
                    ),
                    selected: reportVM.isNewSelected,
                    onSelected: (selected) {
                      reportVM.toggleFilter(ReportFilter.newReports);
                    },
                    selectedColor: AppTheme.infoBlue,
                    labelStyle: TextStyle(
                      color: reportVM.isNewSelected ? Colors.white : AppTheme.darkGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "In Progres" Button
                  ChoiceChip(
                    backgroundColor: AppTheme.lightGray,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: reportVM.isInProgress ? AppTheme.warningOrange : Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    showCheckmark: false,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.autorenew_rounded,
                          size: 16,
                          color: reportVM.isInProgress ? Colors.white : AppTheme.warningOrange,
                        ),
                        const SizedBox(width: 4),
                        const Text("În Progres"),
                      ],
                    ),
                    selected: reportVM.isInProgress,
                    onSelected: (selected) {
                      reportVM.toggleFilter(ReportFilter.InProgress);
                    },
                    selectedColor: AppTheme.warningOrange,
                    labelStyle: TextStyle(
                      color: reportVM.isInProgress ? Colors.white : AppTheme.darkGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "Rezolvate" Button
                  ChoiceChip(
                    backgroundColor: AppTheme.lightGray,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: reportVM.isResolvedSelected ? AppTheme.successGreen : Colors.transparent,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    showCheckmark: false,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 16,
                          color: reportVM.isResolvedSelected ? Colors.white : AppTheme.successGreen,
                        ),
                        const SizedBox(width: 4),
                        const Text("Rezolvate"),
                      ],
                    ),
                    selected: reportVM.isResolvedSelected,
                    onSelected: (selected) {
                      reportVM.toggleFilter(ReportFilter.resolvedReports);
                    },
                    selectedColor: AppTheme.successGreen,
                    labelStyle: TextStyle(
                      color: reportVM.isResolvedSelected ? Colors.white : AppTheme.darkGray,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
