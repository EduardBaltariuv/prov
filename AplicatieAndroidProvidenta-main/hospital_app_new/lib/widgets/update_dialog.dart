import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ota_update_service.dart';

class UpdateDialog extends StatelessWidget {
  final String newVersion;
  final String currentVersion;
  final String updateNotes;
  final bool isCritical;

  const UpdateDialog({
    Key? key,
    required this.newVersion,
    required this.currentVersion,
    required this.updateNotes,
    this.isCritical = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<OTAUpdateService>(
      builder: (context, otaService, child) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isCritical ? theme.colorScheme.error : theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCritical ? Icons.warning : Icons.system_update,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCritical ? 'Critical Update' : 'Update Available',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Version $newVersion',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current version: $currentVersion',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 16),
              if (updateNotes.isNotEmpty) ...[
                Text(
                  'What\'s New:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    updateNotes,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (otaService.isDownloading) ...[
                const SizedBox(height: 8),
                Text(
                  'Downloading update...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: otaService.downloadProgress, // downloadProgress is already 0-1
                  backgroundColor: theme.colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(otaService.downloadProgress * 100).toInt()}%', // Convert to percentage for display
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
              // Show error messages if any
              if (otaService.updateMessage != null && 
                  (otaService.updateMessage!.contains('failed') ||
                   otaService.updateMessage!.contains('error'))) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          otaService.updateMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Show success/info messages
              if (otaService.updateMessage != null && 
                  !otaService.updateMessage!.contains('failed') &&
                  !otaService.updateMessage!.contains('error') &&
                  !otaService.isDownloading) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          otaService.updateMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (otaService.updateMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          otaService.updateMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            if (!isCritical && !otaService.isDownloading)
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Later',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            if (!otaService.isDownloading)
              ElevatedButton(
                onPressed: () async {
                  // If there's an error, reset state before retrying
                  if (otaService.updateMessage != null && 
                      (otaService.updateMessage!.contains('failed') ||
                       otaService.updateMessage!.contains('error'))) {
                    await otaService.resetDownloadState();
                  }
                  await otaService.downloadAndInstallUpdate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCritical ? theme.colorScheme.error : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  (otaService.updateMessage != null && 
                   (otaService.updateMessage!.contains('failed') ||
                    otaService.updateMessage!.contains('error'))) ? 'Retry' : 'Update Now',
                ),
              ),
          ],
        );
      },
    );
  }
}
