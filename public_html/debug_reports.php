<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

echo "Starting debug...\n";

try {
    // Test database connection
    $host = "localhost";
    $username = "u574849695_edi";
    $password = "ediPassword123@";
    $database = "u574849695_edi";
    
    echo "Connecting to database...\n";
    $conn = new mysqli($host, $username, $password, $database);
    
    if ($conn->connect_error) {
        echo "Connection failed: " . $conn->connect_error . "\n";
        exit();
    }
    
    echo "Database connected successfully\n";
    
    // Set charset
    $conn->set_charset("utf8");
    echo "Charset set to utf8\n";
    
    // Simple query to count reports
    $sql = "SELECT COUNT(*) as count FROM reports";
    echo "Executing query: $sql\n";
    
    $result = $conn->query($sql);
    
    if ($result) {
        $row = $result->fetch_assoc();
        echo "Total reports in database: " . $row['count'] . "\n";
    } else {
        echo "Query failed: " . $conn->error . "\n";
    }
    
    // Try to get first few reports
    $sql = "SELECT id, title, created_at FROM reports LIMIT 3";
    echo "Executing query: $sql\n";
    
    $result = $conn->query($sql);
    
    if ($result) {
        echo "First 3 reports:\n";
        while ($row = $result->fetch_assoc()) {
            echo "ID: " . $row['id'] . ", Title: " . $row['title'] . ", Created: " . $row['created_at'] . "\n";
        }
    } else {
        echo "Query failed: " . $conn->error . "\n";
    }
    
    $conn->close();
    echo "Debug completed successfully\n";
    
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
