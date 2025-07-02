<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Configuration
$apkDirectory = __DIR__ . '/apk_files/';
$allowedVersions = ['1.0.1', '1.0.2', '1.0.3', '1.0.4']; // Add allowed versions here

try {
    if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
        http_response_code(405);
        echo json_encode([
            'error' => 'Method not allowed',
            'code' => 'METHOD_NOT_ALLOWED'
        ]);
        exit();
    }
    
    $version = $_GET['version'] ?? null;
    
    if (!$version) {
        http_response_code(400);
        echo json_encode([
            'error' => 'Version parameter is required',
            'code' => 'MISSING_VERSION'
        ]);
        exit();
    }
    
    // Validate version
    if (!in_array($version, $allowedVersions)) {
        http_response_code(404);
        echo json_encode([
            'error' => 'Version not found or not available for download',
            'code' => 'VERSION_NOT_FOUND'
        ]);
        exit();
    }
    
    // Construct file path
    $filename = "hospital_app_v{$version}.apk";
    $filepath = $apkDirectory . $filename;
    
    // Check if file exists
    if (!file_exists($filepath)) {
        http_response_code(404);
        echo json_encode([
            'error' => 'APK file not found on server',
            'code' => 'FILE_NOT_FOUND'
        ]);
        exit();
    }
    
    // Get file size
    $filesize = filesize($filepath);
    
    // Set headers for APK download
    header('Content-Type: application/vnd.android.package-archive');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    header('Content-Length: ' . $filesize);
    header('Accept-Ranges: bytes');
    
    // Handle range requests for resumable downloads
    if (isset($_SERVER['HTTP_RANGE'])) {
        $range = $_SERVER['HTTP_RANGE'];
        list($param, $range) = explode('=', $range);
        
        if (strtolower(trim($param)) !== 'bytes') {
            http_response_code(400);
            exit();
        }
        
        $range = explode(',', $range);
        $range = explode('-', $range[0]);
        
        $start = intval($range[0]);
        $end = ($range[1] !== '') ? intval($range[1]) : $filesize - 1;
        
        if ($start > $end || $start < 0 || $end >= $filesize) {
            http_response_code(416);
            header('Content-Range: bytes */' . $filesize);
            exit();
        }
        
        $length = $end - $start + 1;
        
        http_response_code(206);
        header('Content-Range: bytes ' . $start . '-' . $end . '/' . $filesize);
        header('Content-Length: ' . $length);
        
        $file = fopen($filepath, 'rb');
        fseek($file, $start);
        
        $buffer = 8192;
        $read = 0;
        
        while (!feof($file) && $read < $length) {
            $chunk = min($buffer, $length - $read);
            echo fread($file, $chunk);
            $read += $chunk;
            flush();
        }
        
        fclose($file);
    } else {
        // Normal download
        http_response_code(200);
        
        // Stream the file in chunks
        $file = fopen($filepath, 'rb');
        
        while (!feof($file)) {
            echo fread($file, 8192);
            flush();
        }
        
        fclose($file);
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
