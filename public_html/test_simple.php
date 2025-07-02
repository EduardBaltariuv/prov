<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

// Database connection
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = 3306;

try {
    $conn = new mysqli($host, $username, $password, $database, $port);
    
    if ($conn->connect_error) {
        echo json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]);
        exit;
    }
    
    $action = $_POST['action'] ?? 'test';
    
    if ($action === 'test') {
        echo json_encode([
            'success' => true,
            'message' => 'API is working',
            'db_connected' => $conn->ping(),
            'timestamp' => date('Y-m-d H:i:s')
        ]);
    } elseif ($action === 'updateReport') {
        $report_id = $_POST['report_id'] ?? null;
        $title = $_POST['title'] ?? null;
        $description = $_POST['description'] ?? null;
        
        if (!$report_id || !$title || !$description) {
            echo json_encode(['success' => false, 'message' => 'Missing required fields']);
            exit;
        }
        
        $stmt = $conn->prepare("UPDATE reports SET title = ?, description = ? WHERE id = ?");
        $stmt->bind_param("ssi", $title, $description, $report_id);
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Report updated successfully']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Failed to update report: ' . $stmt->error]);
        }
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
    }
    
} catch (Exception $e) {
    echo json_encode(['error' => 'Exception: ' . $e->getMessage()]);
}
?>
