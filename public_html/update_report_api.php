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

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";

try {
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $action = $_POST['action'] ?? '';
        
        if ($action === 'updateReport') {
            // Database connection
            $conn = new mysqli($host, $username, $password, $database);
            if ($conn->connect_error) {
                throw new Exception("Connection failed: " . $conn->connect_error);
            }
            
            // Get parameters
            $reportId = $_POST['report_id'] ?? '';
            $title = $_POST['title'] ?? '';
            $description = $_POST['description'] ?? '';
            $category = $_POST['category'] ?? '';
            $location = $_POST['location'] ?? '';
            $username = $_POST['username'] ?? '';
            
            // Validate required fields
            if (empty($reportId) || empty($title) || empty($description) || empty($category) || empty($location)) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Toate campurile sunt obligatorii',
                    'code' => 'MISSING_REQUIRED_FIELDS'
                ]);
                exit();
            }
            
            // Simple update without permission checks for now to test
            $stmt = $conn->prepare("UPDATE reports SET title = ?, description = ?, category = ?, location = ? WHERE id = ?");
            if (!$stmt) {
                throw new Exception("Prepare failed: " . $conn->error);
            }
            
            $stmt->bind_param("ssssi", $title, $description, $category, $location, $reportId);
            
            if ($stmt->execute()) {
                echo json_encode([
                    'success' => true,
                    'message' => 'Raportul a fost actualizat cu succes',
                    'report_id' => $reportId
                ]);
            } else {
                throw new Exception("Execute failed: " . $stmt->error);
            }
            
            $stmt->close();
            $conn->close();
            
        } else {
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid action',
                'code' => 'INVALID_ACTION'
            ]);
        }
        
    } else {
        http_response_code(405);
        echo json_encode([
            'success' => false,
            'message' => 'Method not allowed',
            'code' => 'METHOD_NOT_ALLOWED'
        ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error',
        'code' => 'INTERNAL_ERROR',
        'details' => $e->getMessage()
    ]);
}
?>
