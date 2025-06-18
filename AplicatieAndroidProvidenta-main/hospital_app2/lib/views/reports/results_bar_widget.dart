import 'package:flutter/material.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:provider/provider.dart';

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
                    backgroundColor: const Color.fromARGB(255, 245, 245, 245),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    showCheckmark: false,
                    label: const Text("Noi"),
                    selected: reportVM.isNewSelected,
                    onSelected: (selected) {
                      reportVM.toggleFilter(ReportFilter.newReports);
                    },
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: reportVM.isNewSelected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "In Progres" Button
                  ChoiceChip(
                    backgroundColor: const Color.fromARGB(255, 245, 245, 245),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    showCheckmark: false,
                    label: const Text("În Progres"),
                    selected: reportVM.isInProgress,
                    onSelected: (selected) {
                      reportVM.toggleFilter(ReportFilter.InProgress);
                    },
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: reportVM.isInProgress ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // "Rezolvate" Button
                  ChoiceChip(
                    backgroundColor: const Color.fromARGB(255, 245, 245, 245),
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    showCheckmark: false,
                    label: const Text("Rezolvate"),
                    selected: reportVM.isResolvedSelected,
                    onSelected: (selected) {
                      reportVM.toggleFilter(ReportFilter.resolvedReports);
                    },
                    selectedColor: Colors.black,
                    labelStyle: TextStyle(
                      color: reportVM.isResolvedSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Result Count
          Text(
            "${reportVM.filteredReports.length} rezultate",
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
