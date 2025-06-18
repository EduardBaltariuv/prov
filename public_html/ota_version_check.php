<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Version information configuration
$currentVersion = "1.0.0";
$availableVersion = "1.0.1";
$isCritical = false;
$updateNotes = "• Improved performance and stability\n• Fixed minor bugs\n• Enhanced user interface\n• Added new features for better user experience";
$downloadUrl = "https://darkcyan-clam-483701.hostingersite.com/apk_files/hospital_app_v1.0.1.apk";
$minSupportedVersion = "1.0.0";

try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        // Get version check
        $clientVersion = $_GET['version'] ?? null;
        
        if (!$clientVersion) {
            http_response_code(400);
            echo json_encode([
                'error' => 'Version parameter is required',
                'code' => 'MISSING_VERSION'
            ]);
            exit();
        }
        
        // Compare versions
        $hasUpdate = version_compare($clientVersion, $availableVersion, '<');
        $isSupported = version_compare($clientVersion, $minSupportedVersion, '>=');
        
        $response = [
            'hasUpdate' => $hasUpdate,
            'currentVersion' => $clientVersion,
            'availableVersion' => $availableVersion,
            'isCritical' => $isCritical,
            'isSupported' => $isSupported,
            'updateNotes' => $updateNotes,
            'downloadUrl' => $downloadUrl,
            'timestamp' => time()
        ];
        
        // Add critical update info if version is not supported
        if (!$isSupported) {
            $response['isCritical'] = true;
            $response['updateNotes'] = "CRITICAL UPDATE REQUIRED\n\nYour version is no longer supported and must be updated immediately for security and compatibility reasons.\n\n" . $updateNotes;
        }
        
        echo json_encode($response);
        
    } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Update version configuration (admin only)
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!$input) {
            http_response_code(400);
            echo json_encode([
                'error' => 'Invalid JSON input',
                'code' => 'INVALID_JSON'
            ]);
            exit();
        }
        
        // In a real implementation, you would:
        // 1. Verify admin authentication
        // 2. Validate input data
        // 3. Update version information in database or config file
        // 4. Log the update for audit purposes
        
        // For now, just return success
        echo json_encode([
            'success' => true,
            'message' => 'Version configuration updated',
            'timestamp' => time()
        ]);
        
    } else {
        http_response_code(405);
        echo json_encode([
            'error' => 'Method not allowed',
            'code' => 'METHOD_NOT_ALLOWED'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Internal server error',
        'code' => 'INTERNAL_ERROR',
        'message' => $e->getMessage()
    ]);
}
?>
