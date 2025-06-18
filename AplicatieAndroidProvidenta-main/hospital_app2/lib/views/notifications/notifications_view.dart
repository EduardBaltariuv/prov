import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/views/reports/report_details_view.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChangeNotifierProvider(
        create: (context) => ReportViewModel(),
        child: NotificationsPage(),
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: "Defect raportat",
      time: "Acum 2 ore",
      location: "Etajul 2, Camera 205",
      type: "Defect",
      isRead: false,
      reportId: "1",
    ),
    NotificationItem(
      title: "Revizie necesară",
      time: "Acum 3 zile",
      location: "Laboratorul de Biochimie",
      type: "Mentenanță",
      isRead: true,
      reportId: "2",
    ),
    NotificationItem(
      title: "Problemă de siguranță rezolvată",
      time: "Acum 5 zile",
      location: "Intrarea Principală",
      type: "Siguranță",
      isRead: true,
      reportId: "3",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notificări"),
        centerTitle: true,
      ),
      body: Consumer<ReportViewModel>(
        builder: (context, reportViewModel, child) {
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return GestureDetector(
                onTap: () {
                  _handleNotificationTap(context, reportViewModel, notification);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 1,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: notification.isRead ? Colors.grey : Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          notification.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey),
                            SizedBox(width: 4),
                            Text(
                              notification.location,
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Spacer(),
                            Chip(
                              label: Text(
                                notification.type,
                                style: TextStyle(fontSize: 12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
  BuildContext context,
  ReportViewModel reportViewModel,
  NotificationItem notification,
) {
  try {
    // Folosim toate rapoartele (sau filteredReports/newReports/resolvedReports după nevoie)
    final report = reportViewModel.filteredReports.firstWhere(
      (r) => r.id == notification.reportId,
      orElse: () => throw Exception('Raportul nu a fost găsit'),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailsView(report: report),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Nu s-a putut deschide raportul: ${e.toString()}")),
    );
  }
}
}

class NotificationItem {
  final String title;
  final String time;
  final String location;
  final String type;
  final bool isRead;
  final String reportId;

  NotificationItem({
    required this.title,
    required this.time,
    required this.location,
    required this.type,
    required this.isRead,
    required this.reportId,
  });
}