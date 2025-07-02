<?php
ini_set('display_errors', '0');
ini_set('html_errors', '0');
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

$host = "localhost";
$username = "u842828699_common"; 
$password = "Karlmarx12!";
$database = "u842828699_common";

try {
    $conn = new mysqli($host, $username, $password, $database);
    if ($conn->connect_error) {
        throw new Exception("Database connection failed");
    }
    
    $action = $_POST['action'] ?? $_GET['action'] ?? '';
    
    if ($action === 'updateReport') {
        $reportId = $_POST['report_id'] ?? '';
        $title = $_POST['title'] ?? '';
        $description = $_POST['description'] ?? '';
        $category = $_POST['category'] ?? '';
        $location = $_POST['location'] ?? '';
        $username = $_POST['username'] ?? '';
        
        if (empty($reportId) || empty($title) || empty($description) || empty($category) || empty($location)) {
            echo json_encode(['success' => false, 'message' => 'Toate campurile sunt obligatorii']);
            exit;
        }
        
        $stmt = $conn->prepare("UPDATE reports SET title=?, description=?, category=?, location=? WHERE id=?");
        $stmt->bind_param("ssssi", $title, $description, $category, $location, $reportId);
        
        if ($stmt->execute()) {
            echo json_encode(['success' => true, 'message' => 'Raportul a fost actualizat cu succes']);
        } else {
            echo json_encode(['success' => false, 'message' => 'Eroare la actualizare']);
        }
        
    } else if ($action === 'getReport') {
        $username = $_POST['username'] ?? '';
        $stmt = $conn->prepare("SELECT * FROM reports ORDER BY created_at DESC");
        $stmt->execute();
        $result = $stmt->get_result();
        
        $reports = [];
        while ($row = $result->fetch_assoc()) {
            $reports[] = $row;
        }
        
        echo json_encode(['success' => true, 'reports' => $reports]);
        
    } else {
        echo json_encode(['success' => false, 'message' => 'Invalid action']);
    }
    
} catch (Exception $e) {
    echo json_encode(['success' => false, 'message' => 'Server error']);
}
?>
