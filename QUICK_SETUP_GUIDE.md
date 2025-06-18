# Quick OTA Configuration Guide

## 🔧 IMMEDIATE NEXT STEPS

### 1. Update Server URLs (CRITICAL)

Edit `lib/services/ota_update_service.dart`:

```dart
// Line 12-13: Replace placeholder URLs
static const String _versionCheckUrl = 'https://YOUR_DOMAIN.com/ota_version_check.php';
static const String _downloadBaseUrl = 'https://YOUR_DOMAIN.com/ota_download.php';
```

**Example:**
```dart
static const String _versionCheckUrl = 'https://providenta-hospital.com/ota_version_check.php';
static const String _downloadBaseUrl = 'https://providenta-hospital.com/ota_download.php';
```

### 2. Server Setup Commands

```bash
# 1. Upload PHP files to your web server
scp public_html/ota_version_check.php user@yourserver:/path/to/public_html/
scp public_html/ota_download.php user@yourserver:/path/to/public_html/

# 2. Create APK storage directory
mkdir -p /path/to/public_html/apk_files/
chmod 755 /path/to/public_html/apk_files/

# 3. Set proper permissions
chmod 644 /path/to/public_html/ota_*.php
```

### 3. Test Server Endpoints

```bash
# Test version check endpoint
curl -X POST "https://YOUR_DOMAIN.com/ota_version_check.php" \
  -H "Content-Type: application/json" \
  -d '{
    "current_version": "1.0.0",
    "build_number": "1", 
    "platform": "android",
    "package_name": "com.example.hospital_app"
  }'

# Expected response:
# {
#   "update_available": false,
#   "latest_version": "1.0.0",
#   "message": "You have the latest version"
# }
```

### 4. APK Deployment Workflow

```bash
# 1. Build release APK
flutter build apk --release

# 2. Sign APK (if not auto-signed)
# Follow Android signing guide

# 3. Upload to server
scp build/app/outputs/flutter-apk/app-release.apk \
  user@yourserver:/path/to/public_html/apk_files/hospital_app_v1.0.1.apk

# 4. Update version info in server database/config
```

### 5. Version Management

**Current app version:** Check `pubspec.yaml`
```yaml
version: 1.0.0+1
#        ^     ^
#        |     build number
#        version number
```

**For updates:**
1. Increment version in `pubspec.yaml`: `1.0.0+1` → `1.0.1+2`
2. Build new APK
3. Upload with version-specific filename: `hospital_app_v1.0.1.apk`
4. Update server endpoint to return new version info

## 🧪 TESTING CHECKLIST

- [ ] Server URLs updated in app code
- [ ] PHP endpoints uploaded and accessible
- [ ] APK storage directory created with proper permissions
- [ ] Version check returns correct JSON format
- [ ] Download endpoint serves APK files
- [ ] App can detect available updates
- [ ] Download progress works correctly
- [ ] APK installation succeeds
- [ ] App restarts with new version

## 📱 APP USAGE

### For Users:
1. **Automatic Updates**: Enabled by default, checks daily
2. **Manual Check**: Profile → "Check for Updates" button
3. **Update Settings**: Profile → Toggle auto-updates on/off

### For Developers:
1. **Force Update Check**: Call `otaService.checkForUpdates()`
2. **Critical Updates**: Set `is_critical: true` in server response
3. **Progress Monitoring**: Listen to `downloadProgress` getter

## 🔒 SECURITY CONSIDERATIONS

```dart
// TODO: Add to OTA service for production
- APK signature verification
- Checksum validation  
- SSL certificate pinning
- Update authentication tokens
```

---

**Status**: Ready for server configuration and testing
**Next Action**: Update server URLs and deploy PHP endpoints
