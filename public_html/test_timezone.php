<?php
// Set timezone for consistent time handling
date_default_timezone_set('Europe/Bucharest'); // Romania timezone

// Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header('Content-Type: application/json; charset=utf-8');

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = 3306;

try {
    // Connect to DB
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $conn = new mysqli($host, $username, $password, $database, $port);
    $conn->set_charset("utf8mb4");
    
    // Set MySQL timezone to Romanian time (handles DST automatically)
    $conn->query("SET time_zone = 'Europe/Bucharest'");
    
    // Get current PHP time
    $phpTime = date('Y-m-d H:i:s');
    $phpTimezone = date_default_timezone_get();
    
    // Get current MySQL time
    $result = $conn->query("SELECT NOW() as mysql_time, @@session.time_zone as mysql_timezone");
    $row = $result->fetch_assoc();
    
    echo json_encode([
        'success' => true,
        'php_time' => $phpTime,
        'php_timezone' => $phpTimezone,
        'mysql_time' => $row['mysql_time'],
        'mysql_timezone' => $row['mysql_timezone'],
        'timestamp' => time(),
        'message' => 'Timezone test - Romanian time'
    ]);
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}
?>
