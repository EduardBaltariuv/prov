<?php
// Set headers to allow requests from any origin
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: text/plain');

// Get all request data
$request_method = $_SERVER['REQUEST_METHOD'] ?? 'UNKNOWN';
$request_time = date('Y-m-d H:i:s');
$headers = getallheaders();
$raw_input = file_get_contents('php://input');
$post_data = $_POST;
$get_data = $_GET;
$files_data = $_FILES;

// Format the data for logging
$log_content = "===== NEW REQUEST =====\n";
$log_content .= "Timestamp: $request_time\n";
$log_content .= "Method: $request_method\n\n";

$log_content .= "===== HEADERS =====\n";
foreach ($headers as $name => $value) {
    $log_content .= "$name: $value\n";
}

$log_content .= "\n===== RAW INPUT =====\n";
$log_content .= $raw_input . "\n";

$log_content .= "\n===== POST DATA =====\n";
$log_content .= print_r($post_data, true) . "\n";

$log_content .= "\n===== GET DATA =====\n";
$log_content .= print_r($get_data, true) . "\n";

$log_content .= "\n===== FILES DATA =====\n";
$log_content .= print_r($files_data, true) . "\n";

$log_content .= "\n===== SERVER INFO =====\n";
$log_content .= "Remote IP: " . ($_SERVER['REMOTE_ADDR'] ?? 'N/A') . "\n";
$log_content .= "User Agent: " . ($_SERVER['HTTP_USER_AGENT'] ?? 'N/A') . "\n";

// Save to file
file_put_contents('text.txt', $log_content, FILE_APPEND);

// Send simple response
echo "Request data has been logged to text.txt";
?>