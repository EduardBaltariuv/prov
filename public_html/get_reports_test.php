<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");

date_default_timezone_set('Europe/Bucharest');

$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";

try {
    $conn = new mysqli($host, $username, $password, $database);
    if ($conn->connect_error) {
        throw new Exception("Connection failed");
    }
    
    // Set MySQL timezone to Romanian time
    $conn->query("SET time_zone = '+03:00'");
    
    $action = $_POST['action'] ?? '';
    
    if ($action === 'getReport') {
        $stmt = $conn->prepare("SELECT *, DATE_FORMAT(created_at, '%Y-%m-%d %H:%i:%s') as formatted_date FROM reports ORDER BY created_at DESC");
        $stmt->execute();
        $result = $stmt->get_result();
        
        $reports = [];
        while ($row = $result->fetch_assoc()) {
            $reports[] = $row;
        }
        
        echo json_encode([
            'success' => true,
            'reports' => $reports,
            'timezone' => date('Y-m-d H:i:s T'),
            'server_timezone' => date_default_timezone_get()
        ]);
        
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
    }
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Error: ' . $e->getMessage()]);
}
?>
