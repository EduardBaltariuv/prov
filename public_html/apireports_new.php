<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";

try {
    $action = $_POST['action'] ?? '';
    
    if ($action === 'updateReport') {
        $conn = new mysqli($host, $username, $password, $database);
        
        if ($conn->connect_error) {
            throw new Exception("Connection failed");
        }
        
        $reportId = $_POST['report_id'] ?? '';
        $title = $_POST['title'] ?? '';
        $description = $_POST['description'] ?? '';
        $category = $_POST['category'] ?? '';
        $location = $_POST['location'] ?? '';
        
        if (empty($reportId) || empty($title) || empty($description) || empty($category) || empty($location)) {
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit;
        }
        
        $stmt = $conn->prepare("UPDATE reports SET title=?, description=?, category=?, location=? WHERE id=?");
        $stmt->bind_param("ssssi", $title, $description, $category, $location, $reportId);
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Report updated successfully']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Update failed']);
        }
        
        $conn->close();
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
    }
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
