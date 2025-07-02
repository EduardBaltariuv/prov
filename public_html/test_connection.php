<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";

try {
    $conn = new mysqli($host, $username, $password, $database);
    if ($conn->connect_error) {
        echo json_encode(['success' => false, 'message' => 'DB connection failed']);
        exit;
    }
    
    echo json_encode(['success' => true, 'message' => 'API working', 'timestamp' => date('Y-m-d H:i:s')]);
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
