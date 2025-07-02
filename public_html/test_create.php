<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && $_POST['action'] === 'createReport') {
        $conn = new mysqli($host, $username, $password, $database);
        if ($conn->connect_error) {
            throw new Exception("Connection failed");
        }
        
        // Simple test insert without validation
        $title = $_POST['title'] ?? 'Test Title';
        $description = $_POST['description'] ?? 'Test Description';
        $category = $_POST['category'] ?? 'Test Category';
        $location = $_POST['location'] ?? 'Test Location';
        $user = $_POST['username'] ?? 'admin';
        
        $stmt = $conn->prepare("INSERT INTO reports (title, description, category, location, username, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
        $stmt->bind_param("sssss", $title, $description, $category, $location, $user);
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Report created', 'id' => $stmt->insert_id]);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to insert: ' . $stmt->error]);
        }
        
        $conn->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid request']);
    }
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
