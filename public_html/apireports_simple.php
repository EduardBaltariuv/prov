<?php
// Disable all error output to prevent HTML in JSON response
ini_set('display_errors', 0);
ini_set('log_errors', 1);
error_reporting(0);

header("Access-Control-Allow-Headers: Authorization, Content-Type");
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json; charset=utf-8');

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = 3306;

try {
    $conn = new mysqli($host, $username, $password, $database, $port);
    
    if ($conn->connect_error) {
        echo json_encode(['success' => false, 'message' => 'Database connection failed']);
        exit;
    }
    
    $conn->set_charset("utf8mb4");
    
    $action = $_POST['action'] ?? '';
    
    switch ($action) {
        case 'test':
            echo json_encode([
                'success' => true,
                'message' => 'API is working',
                'timestamp' => date('Y-m-d H:i:s')
            ]);
            break;
            
        case 'updateReport':
            $result = handleUpdateReport($conn);
            echo json_encode($result);
            break;
            
        case 'createReport':
            $result = handleCreateReport($conn);
            echo json_encode($result);
            break;
            
        default:
            echo json_encode(['success' => false, 'message' => 'Invalid action']);
            break;
    }
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Server error']);
}

function handleUpdateReport($conn) {
    try {
        $report_id = $_POST['report_id'] ?? null;
        $title = $_POST['title'] ?? null;
        $description = $_POST['description'] ?? null;
        $category = $_POST['category'] ?? null;
        $location = $_POST['location'] ?? null;
        
        if (!$report_id || !$title || !$description) {
            return ['success' => false, 'message' => 'Missing required fields'];
        }
        
        $sql = "UPDATE reports SET title = ?, description = ?, category = ?, location = ?, updated_at = NOW() WHERE id = ?";
        $stmt = $conn->prepare($sql);
        
        if (!$stmt) {
            return ['success' => false, 'message' => 'Database prepare failed'];
        }
        
        $stmt->bind_param("ssssi", $title, $description, $category, $location, $report_id);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                return ['success' => true, 'message' => 'Report updated successfully'];
            } else {
                return ['success' => false, 'message' => 'No report found or no changes made'];
            }
        } else {
            return ['success' => false, 'message' => 'Failed to update report'];
        }
        
    } catch (Exception $e) {
        return ['success' => false, 'message' => 'Update error'];
    }
}

function handleCreateReport($conn) {
    // Simple create function - to be implemented if needed
    return ['success' => false, 'message' => 'Create not implemented in simplified version'];
}
?>
