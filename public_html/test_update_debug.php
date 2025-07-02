<?php
// Disable HTML error formatting
ini_set('html_errors', '0');
ini_set('display_errors', '1');
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');
date_default_timezone_set('Europe/Bucharest');

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = 3306;

try {
    echo json_encode(['step' => 'Starting test']);
    
    // Test database connection
    $conn = new mysqli($host, $username, $password, $database, $port);
    if ($conn->connect_error) {
        throw new Exception("Connection failed: " . $conn->connect_error);
    }
    
    echo json_encode(['step' => 'Database connected']);
    
    // Test if reports table exists
    $result = $conn->query("DESCRIBE reports");
    if (!$result) {
        throw new Exception("Table check failed: " . $conn->error);
    }
    
    $columns = [];
    while ($row = $result->fetch_assoc()) {
        $columns[] = $row['Field'];
    }
    
    echo json_encode(['step' => 'Table structure', 'columns' => $columns]);
    
    // Test a simple update (if any reports exist)
    $testResult = $conn->query("SELECT id FROM reports LIMIT 1");
    if ($testResult && $testResult->num_rows > 0) {
        $testRow = $testResult->fetch_assoc();
        $testId = $testRow['id'];
        
        // Try a simple update
        $updateStmt = $conn->prepare("UPDATE reports SET title = ? WHERE id = ?");
        if ($updateStmt) {
            $testTitle = "Test Update " . date('Y-m-d H:i:s');
            $updateStmt->bind_param("ss", $testTitle, $testId);
            
            if ($updateStmt->execute()) {
                echo json_encode(['step' => 'Update successful', 'test_id' => $testId]);
            } else {
                throw new Exception("Update failed: " . $updateStmt->error);
            }
            $updateStmt->close();
        } else {
            throw new Exception("Prepare failed: " . $conn->error);
        }
    } else {
        echo json_encode(['step' => 'No reports found for testing']);
    }
    
    $conn->close();
    echo json_encode(['step' => 'Test completed successfully']);
    
} catch (Exception $e) {
    echo json_encode(['error' => $e->getMessage(), 'step' => 'Exception caught']);
}
?>
