<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
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
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $action = $_POST['action'] ?? '';
        
        if ($action === 'createReport') {
            // Database connection
            $conn = new mysqli($host, $username, $password, $database);
            if ($conn->connect_error) {
                throw new Exception("Connection failed: " . $conn->connect_error);
            }
            
            // Get and validate parameters
            $username = $_POST['username'] ?? '';
            $title = $_POST['title'] ?? '';
            $description = $_POST['description'] ?? '';
            $category = $_POST['category'] ?? '';
            $location = $_POST['location'] ?? '';
            
            // Validate required fields
            if (empty($username) || empty($title) || empty($description) || empty($category) || empty($location)) {
                http_response_code(400);
                echo json_encode([
                    'success' => false,
                    'message' => 'Toate campurile sunt obligatorii',
                    'missing_fields' => [
                        'username' => empty($username),
                        'title' => empty($title),
                        'description' => empty($description),
                        'category' => empty($category),
                        'location' => empty($location)
                    ]
                ]);
                exit();
            }
            
            // Check if user exists (simplified check)
            $userStmt = $conn->prepare("SELECT username FROM login WHERE username = ? LIMIT 1");
            if ($userStmt) {
                $userStmt->bind_param("s", $username);
                $userStmt->execute();
                $userResult = $userStmt->get_result();
                
                if ($userResult->num_rows === 0) {
                    echo json_encode([
                        'success' => false,
                        'message' => 'Utilizator invalid',
                        'code' => 'INVALID_USER'
                    ]);
                    exit();
                }
                $userStmt->close();
            }
            
            // Insert new report
            $stmt = $conn->prepare("INSERT INTO reports (title, description, category, location, username, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
            if (!$stmt) {
                throw new Exception("Prepare failed: " . $conn->error);
            }
            
            $stmt->bind_param("sssss", $title, $description, $category, $location, $username);
            
            if ($stmt->execute()) {
                $reportId = $stmt->insert_id;
                echo json_encode([
                    'success' => true,
                    'message' => 'Raportul a fost creat cu succes!',
                    'id' => $reportId
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
                'message' => 'Invalid action: ' . $action,
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
        'message' => 'Internal server error: ' . $e->getMessage(),
        'code' => 'INTERNAL_ERROR'
    ]);
}
?>
