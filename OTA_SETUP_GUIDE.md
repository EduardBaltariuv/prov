# OTA Update System Setup Guide

## Overview
This Over-The-Air (OTA) update system allows you to push app updates directly to users without requiring them to download from app stores.

## Components

### 1. Flutter App Components
- **OTAUpdateService** (`lib/services/ota_update_service.dart`): Core service handling version checks and updates
- **UpdateDialog** (`lib/widgets/update_dialog.dart`): UI for update notifications
- **UpdateNotification** (`lib/widgets/update_notification.dart`): Update banners and buttons
- **Profile Settings**: OTA settings integrated into the profile page

### 2. Server Components
- **Version Check API** (`public_html/ota_version_check.php`): Returns version information
- **Download API** (`public_html/ota_download.php`): Serves APK files for download
- **APK Storage** (`public_html/apk_files/`): Directory containing APK files

### 3. Android Native Components
- **MainActivity.kt**: Platform channel for APK installation
- **AndroidManifest.xml**: Permissions and FileProvider configuration
- **file_paths.xml**: FileProvider paths configuration

## Setup Instructions

### 1. Server Setup

1. **Upload PHP Files**:
   - Copy `ota_version_check.php` and `ota_download.php` to your web server
   - Ensure PHP has read/write permissions

2. **Configure APK Storage**:
   - Create `/apk_files/` directory on your server
   - Set proper permissions (755 recommended)
   - Upload APK files with naming convention: `hospital_app_v{version}.apk`

3. **Update Configuration**:
   ```php
   // In ota_version_check.php
   $availableVersion = "1.0.1";  // Update this when new version is available
   $isCritical = false;          // Set to true for critical updates
   $downloadUrl = "https://your-server.com/ota_download.php?version=1.0.1";
   ```

### 2. Flutter App Configuration

1. **Update Server URLs**:
   ```dart
   // In lib/services/ota_update_service.dart
   static const String _versionCheckUrl = 'https://your-server.com/ota_version_check.php';
   static const String _downloadBaseUrl = 'https://your-server.com/ota_download.php';
   ```

2. **Install Dependencies**:
   ```bash
   cd hospital_app_new
   flutter pub get
   ```

3. **Build and Test**:
   ```bash
   flutter build apk --release
   ```

### 3. Android Configuration

1. **Permissions**: Already configured in AndroidManifest.xml
   - `INTERNET`: For downloading updates
   - `WRITE_EXTERNAL_STORAGE`: For saving APK files
   - `REQUEST_INSTALL_PACKAGES`: For installing APKs

2. **FileProvider**: Configured for APK installation

### 4. Usage

#### For Users:
1. **Automatic Updates**: Enable in Profile → Update Settings
2. **Manual Check**: Tap "Check for Updates" in profile
3. **Update Notifications**: Appear as banners or in app bar
4. **Installation**: Guided through APK installation process

#### For Administrators:
1. **Upload New APK**: Place in `/apk_files/` directory
2. **Update Version Info**: Modify `ota_version_check.php`
3. **Set Critical Flag**: Force immediate updates if needed
4. **Monitor Logs**: Check server logs for update analytics

## Security Considerations

1. **APK Signing**: Ensure APKs are properly signed with your release key
2. **HTTPS**: Use HTTPS for all update communications
3. **Version Validation**: Server validates version requests
4. **Permission Checks**: App checks installation permissions
5. **File Integrity**: Consider adding checksum validation

## Troubleshooting

### Common Issues:

1. **"Unknown Sources" Warning**:
   - App guides users to enable installation from unknown sources
   - Uses platform channels to open settings

2. **Download Failures**:
   - Check server connectivity
   - Verify APK file exists and permissions
   - Check available storage space

3. **Installation Failures**:
   - Ensure APK is signed with same key
   - Check Android version compatibility
   - Verify file integrity

### Debug Steps:

1. **Check Server Response**:
   ```bash
   curl "https://your-server.com/ota_version_check.php?version=1.0.0"
   ```

2. **Verify APK Download**:
   ```bash
   curl -o test.apk "https://your-server.com/ota_download.php?version=1.0.1"
   ```

3. **Monitor App Logs**:
   - Use `flutter logs` or Android Studio logcat
   - Check for OTA service debug messages

## Version Management

### Version Number Format:
- Use semantic versioning: `MAJOR.MINOR.PATCH`
- Example: `1.0.0`, `1.0.1`, `1.1.0`, `2.0.0`

### Update Types:
- **Patch Updates**: Bug fixes, minor improvements
- **Minor Updates**: New features, enhancements
- **Major Updates**: Breaking changes, major overhauls
- **Critical Updates**: Security fixes, urgent patches

### Deployment Workflow:
1. Build and test new version
2. Upload APK to server
3. Update version configuration
4. Test update process
5. Monitor user adoption

## Advanced Features

### Future Enhancements:
- **Delta Updates**: Download only changed files
- **Staged Rollouts**: Gradual deployment to user segments
- **Rollback Capability**: Revert to previous version
- **Analytics**: Track update success rates
- **A/B Testing**: Test different versions simultaneously

This OTA system provides a complete solution for managing app updates outside of traditional app stores while maintaining security and user experience standards.
