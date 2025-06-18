import 'package:flutter/material.dart';
import 'package:hospital_app/models/report.dart';
import 'package:hospital_app/viewmodels/auth_viewmodel.dart';
import 'package:hospital_app/viewmodels/navigation_viewmodel.dart';
import 'package:hospital_app/viewmodels/report_viewmodel.dart';
import 'package:hospital_app/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ReportDetailsView extends StatelessWidget {
  final Report report;
  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  ReportDetailsView({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    var userName = authVM.getUsername;
    userName ??= "Utilizator Necunoscut";
    final canModifyStatus =
        authVM.getRole == "tehnician" || authVM.getRole == "admin";
    final canDelete = authVM.getRole == "admin";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: CustomAppBar(
        title: "Detalii raport",
        navigationIndex: PageKey.reports,
        useNavigator: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                  if (canDelete)
                    const SizedBox(width: 12),
                  if (canDelete)
                    _buildDeleteButton(context),
                ],
              ),
            ),
            const SizedBox(height: 8),
                const Divider(
                  thickness: 0.1,
                  color: Color.fromARGB(255, 0, 0, 0),
                  indent: 0,
                ),
                if (report.imagePaths.isNotEmpty) _buildImageGallery(context),
                _buildDescriptionSection(),
                _buildMetadataSection(userName),
                _buildStatusSection(context, canModifyStatus),
              ],
            ),
          ),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'Fotografii',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: report.imagePaths.length,
            itemBuilder: (context, index) {
              final imageUrl = report.imagePaths[index];
              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 20 : 8,
                  right: index == report.imagePaths.length - 1 ? 20 : 0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => _showFullScreenImage(context, imageUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildImageWidget(imageUrl),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 300,
                      child: Text(
                        _getShortImageName(imageUrl),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const Divider(
          thickness: 0.1,
          color: Color.fromARGB(255, 0, 0, 0),
          indent: 0,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Descriere',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              report.description,
              style: const TextStyle(fontSize: 16, fontFamily: 'Roboto'),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(
            thickness: 0.1,
            color: Color.fromARGB(255, 0, 0, 0),
            indent: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(String userName) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Column(
        children: [
          _buildDetailRow('Locatie', report.location, icon: Icons.location_on),
          const SizedBox(height: 12),
          _buildDetailRow(
            'Data',
            report.formattedDateTimeLong,
            icon: Icons.calendar_today,
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Autor', report.username, icon: Icons.person),
          const SizedBox(height: 16),
          const Divider(
            thickness: 0.1,
            color: Color.fromARGB(255, 0, 0, 0),
            indent: 0,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, bool canModifyStatus) {
    final reportVM = Provider.of<ReportViewModel>(context);
    final statusOptions = ['Nou', 'În Progres', 'Rezolvat'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 8),
          if (canModifyStatus)
            Consumer<ReportViewModel>(
              builder: (context, reportVM, child) {
                // Find the current report from the viewmodel to get updated status
                final currentReport = reportVM.reports.firstWhere(
                  (r) => r.id == report.id, 
                  orElse: () => report,
                );
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentReport.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(currentReport.status),
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: currentReport.status,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items:
                        statusOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  _getStatusIcon(value),
                                  color: _getStatusColor(value),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  value,
                                  style: TextStyle(
                                    color: _getStatusColor(value),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) async {
                      if (newValue != null) {
                        await reportVM.updateReportStatus(report.id, newValue);
                      }
                    },
                  ),
                );
              },
            )
          else
            Consumer<ReportViewModel>(
              builder: (context, reportVM, child) {
                // Find the current report from the viewmodel to get updated status
                final currentReport = reportVM.reports.firstWhere(
                  (r) => r.id == report.id, 
                  orElse: () => report,
                );
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentReport.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getStatusColor(currentReport.status),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getStatusIcon(currentReport.status),
                        color: _getStatusColor(currentReport.status),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        currentReport.status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _getStatusColor(currentReport.status),
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return FutureBuilder<FileInfo?>(
      future: _cacheManager.getFileFromCache(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final fileInfo = snapshot.data!;
          if (fileInfo.file.existsSync()) {
            return Image.file(
              fileInfo.file,
              width: 300,
              height: 180,
              fit: BoxFit.cover,
            );
          }
        }

        return CachedNetworkImage(
          imageUrl: imageUrl,
          cacheManager: _cacheManager,
          width: 300,
          height: 180,
          fit: BoxFit.cover,
          placeholder:
              (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
          errorWidget: (context, url, error) => _buildFallbackImage(url),
        );
      },
    );
  }

  Widget _buildFallbackImage(String url) {
    return Container(
      width: 300,
      height: 180,
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 40, color: Colors.red),
          const SizedBox(height: 8),
          const Text('Imagine indisponibilă'),
          Text(
            _getShortImageName(url),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getShortImageName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.pathSegments.last;
    } catch (e) {
      return url;
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(child: _buildImageWidget(imageUrl)),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'nou':
        return Colors.blue;
      case 'în progres':
        return Colors.orange;
      case 'rezolvat':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'nou':
        return Icons.fiber_new;
      case 'în progres':
        return Icons.autorenew;
      case 'rezolvat':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.red.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: IconButton(
        icon: const Icon(Icons.delete_outline, 
          color: Colors.red, 
          size: 20,
        ),
        tooltip: 'Șterge raport',
        onPressed: () => _showDeleteConfirmationDialog(context),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final reportVM = Provider.of<ReportViewModel>(context, listen: false);
    final navVM = Provider.of<NavigationViewModel>(context, listen: false);

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {  // Changed context to dialogContext
        return AlertDialog(
          title: const Text('Ștergere raport'),
          content: const Text('Sigur doriți să ștergeți acest raport? Această acțiune nu poate fi anulată.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Anulează'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Șterge', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                // Close the dialog first
                Navigator.of(dialogContext).pop();
                try {
                  await reportVM.deleteReport(report.id);
                  
                  if (context.mounted) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Raportul a fost șters cu succes!')),
                    );
                    
                    // Navigate back to reports page
                    navVM.navigateTo(PageKey.reports);
                    Navigator.of(context).pop(); // Pop the details page
                  }
                } catch (e) {
                  if (context.mounted) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Eroare la ștergere: ${e.toString()}')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

}
