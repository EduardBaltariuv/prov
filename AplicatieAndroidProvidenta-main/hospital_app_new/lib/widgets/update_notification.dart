import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ota_update_service.dart';
import 'update_dialog.dart';

class UpdateNotificationButton extends StatelessWidget {
  const UpdateNotificationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OTAUpdateService>(
      builder: (context, otaService, child) {
        if (!otaService.hasUpdate) {
          return const SizedBox.shrink();
        }

        return Stack(
          children: [
            IconButton(
              onPressed: () => _showUpdateDialog(context, otaService),
              icon: const Icon(Icons.system_update),
              tooltip: 'Update Available',
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: otaService.isCriticalUpdate 
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, OTAUpdateService otaService) {
    showDialog(
      context: context,
      barrierDismissible: !otaService.isCriticalUpdate,
      builder: (context) => UpdateDialog(
        newVersion: otaService.availableVersion ?? '',
        currentVersion: otaService.currentVersion ?? '',
        updateNotes: otaService.updateNotes ?? '',
        isCritical: otaService.isCriticalUpdate,
      ),
    );
  }
}

class UpdateBanner extends StatelessWidget {
  const UpdateBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<OTAUpdateService>(
      builder: (context, otaService, child) {
        if (!otaService.hasUpdate || otaService.isDownloading) {
          return const SizedBox.shrink();
        }

        return Material(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: otaService.isCriticalUpdate 
                  ? theme.colorScheme.errorContainer
                  : theme.colorScheme.primaryContainer,
            ),
            child: Row(
              children: [
                Icon(
                  otaService.isCriticalUpdate ? Icons.warning : Icons.system_update,
                  color: otaService.isCriticalUpdate 
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otaService.isCriticalUpdate 
                            ? 'Critical Update Required'
                            : 'Update Available',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: otaService.isCriticalUpdate 
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Version ${otaService.availableVersion}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: otaService.isCriticalUpdate 
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showUpdateDialog(context, otaService),
                  style: TextButton.styleFrom(
                    foregroundColor: otaService.isCriticalUpdate 
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                  child: const Text('Update'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showUpdateDialog(BuildContext context, OTAUpdateService otaService) {
    showDialog(
      context: context,
      barrierDismissible: !otaService.isCriticalUpdate,
      builder: (context) => UpdateDialog(
        newVersion: otaService.availableVersion ?? '',
        currentVersion: otaService.currentVersion ?? '',
        updateNotes: otaService.updateNotes ?? '',
        isCritical: otaService.isCriticalUpdate,
      ),
    );
  }
}
