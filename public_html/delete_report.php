<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Enable error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database credentials
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = "3306";

// Create connection
$conn = new mysqli($host, $username, $password, $database, $port);

// Check connection
if ($conn->connect_error) {
    die(json_encode([
        "success" => false,
        "message" => "Connection failed: " . $conn->connect_error
    ]));
}

try {
    // Get report ID from POST request
    $reportId = $_POST['id'] ?? null;

    if (!$reportId) {
        throw new Exception('Report ID is required');
    }

    // First get the report to check if it exists and get image paths
    $stmt = $conn->prepare("SELECT * FROM reports WHERE id = ?");
    $stmt->bind_param("s", $reportId);
    $stmt->execute();
    $result = $stmt->get_result();
    $report = $result->fetch_assoc();
    $stmt->close();

    if (!$report) {
        throw new Exception('Report not found');
    }

    // Start transaction
    $conn->begin_transaction();

    // Delete report from database
    $stmt = $conn->prepare("DELETE FROM reports WHERE id = ?");
    $stmt->bind_param("s", $reportId);
    $success = $stmt->execute();
    $stmt->close();

    if (!$success) {
        throw new Exception('Failed to delete report');
    }

    // Delete images if they exist
    if (isset($report['image_urls'])) {
        $imagePaths = json_decode($report['image_urls'], true);
        if (is_array($imagePaths)) {
            foreach ($imagePaths as $imagePath) {
                $fullPath = '../uploads/' . basename($imagePath);
                if (file_exists($fullPath)) {
                    unlink($fullPath);
                }
            }
        }
    }

    // Commit transaction
    $conn->commit();

    echo json_encode([
        'success' => true,
        'message' => 'Report deleted successfully'
    ]);

} catch (Exception $e) {
    // Rollback transaction if there was an error
    if ($conn && $conn->connect_error === false) {
        $conn->rollback();
    }

    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
} finally {
    if ($conn) {
        $conn->close();
    }
}
?>