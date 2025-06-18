import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/views/reports/report_details_view.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../viewmodels/navigation_viewmodel.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
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
      backgroundColor: AppTheme.backgroundLight,
      appBar: CustomAppBar(
        title: "Notificări",
        navigationIndex: PageKey.reports, // or appropriate page key
        useNavigator: false,
      ),
            body: Consumer<ReportViewModel>(
        builder: (context, reportViewModel, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return GestureDetector(
                onTap: () {
                  _handleNotificationTap(context, reportViewModel, notification);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: notification.isRead 
                        ? AppTheme.surfaceWhite 
                        : AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: notification.isRead 
                          ? AppTheme.dividerColor 
                          : AppTheme.primaryBlue.withOpacity(0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.darkGray.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getNotificationTypeColor(notification.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getNotificationTypeIcon(notification.type),
                                size: 20,
                                color: _getNotificationTypeColor(notification.type),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: notification.isRead ? AppTheme.steelGray : AppTheme.charcoal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.time,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.steelGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded, 
                              size: 16, 
                              color: AppTheme.steelGray,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                notification.location,
                                style: TextStyle(
                                  fontSize: 14, 
                                  color: AppTheme.steelGray,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getNotificationTypeColor(notification.type).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _getNotificationTypeColor(notification.type).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                notification.type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getNotificationTypeColor(notification.type),
                                ),
                              ),
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

  Color _getNotificationTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'defect':
        return AppTheme.errorRed;
      case 'mentenanță':
      case 'maintenance':
        return AppTheme.warningOrange;
      case 'siguranță':
      case 'safety':
        return AppTheme.successGreen;
      default:
        return AppTheme.infoBlue;
    }
  }

  IconData _getNotificationTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'defect':
        return Icons.error_rounded;
      case 'mentenanță':
      case 'maintenance':
        return Icons.build_rounded;
      case 'siguranță':
      case 'safety':
        return Icons.security_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _handleNotificationTap(BuildContext context, ReportViewModel reportViewModel, NotificationItem notification) {
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