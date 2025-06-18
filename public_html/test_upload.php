<?php
// Simple test script to debug file uploads
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json; charset=utf-8');

$debugLog = '/home/vboxuser/Downloads/AplicatieAndroidProvidenta-main2/public_html/upload_test_debug.log';

// Log all incoming data
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - TEST UPLOAD DEBUG START\n", FILE_APPEND);
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - REQUEST_METHOD: " . $_SERVER['REQUEST_METHOD'] . "\n", FILE_APPEND);
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - POST Data: " . print_r($_POST, true) . "\n", FILE_APPEND);
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - FILES Data: " . print_r($_FILES, true) . "\n", FILE_APPEND);
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Content-Type: " . ($_SERVER['CONTENT_TYPE'] ?? 'Not set') . "\n", FILE_APPEND);

// Check PHP upload settings
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - upload_max_filesize: " . ini_get('upload_max_filesize') . "\n", FILE_APPEND);
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - post_max_size: " . ini_get('post_max_size') . "\n", FILE_APPEND);
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - file_uploads: " . (ini_get('file_uploads') ? 'ON' : 'OFF') . "\n", FILE_APPEND);

// Check if this is the live server or local
$uploadDir = '/home/u842828699/domains/darkcyan-clam-483701.hostingersite.com/public_html/uploads/';
$localUploadDir = '/home/vboxuser/Downloads/AplicatieAndroidProvidenta-main2/public_html/uploads/';

if (is_dir($uploadDir)) {
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Live server upload dir exists: " . $uploadDir . "\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Live server upload dir writable: " . (is_writable($uploadDir) ? 'YES' : 'NO') . "\n", FILE_APPEND);
} else if (is_dir($localUploadDir)) {
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Local upload dir exists: " . $localUploadDir . "\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Local upload dir writable: " . (is_writable($localUploadDir) ? 'YES' : 'NO') . "\n", FILE_APPEND);
    $uploadDir = $localUploadDir;
} else {
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - ERROR: No upload directory found\n", FILE_APPEND);
}

// Check current working directory
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Current working directory: " . getcwd() . "\n", FILE_APPEND);
file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Script file: " . __FILE__ . "\n", FILE_APPEND);

file_put_contents($debugLog, date('Y-m-d H:i:s') . " - TEST UPLOAD DEBUG END\n\n", FILE_APPEND);

echo json_encode([
    'success' => true,
    'message' => 'Test completed - check upload_test_debug.log',
    'post_data' => $_POST,
    'files_data' => $_FILES,
    'upload_dir' => $uploadDir ?? 'Not found'
]);
?>
