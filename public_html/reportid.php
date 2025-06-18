<?php
declare(strict_types=1);
// Add these at the top of your PHP file
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, HEAD");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Expose-Headers: *");  // Important for images
// Database connection
// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = 3306;

try {
    // Database connection
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $conn = new mysqli($host, $username, $password, $database, $port);
    $conn->set_charset("utf8mb4");

    // Get action from POST
    $action = $_POST['action'] ?? '';

    switch ($action) {
        case 'getReport':
            handleGetReports($conn, $baseUrl, $uploadPublicPath);
            break;
        default:
            throw new Exception("Invalid action. Received: " . ($action ?: 'No action specified'));
    }

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Server error: ' . $e->getMessage()
    ]);
    exit;
} finally {
    if (isset($conn)) {
        $conn->close();
    }

// Check HTTP method
if ($_SERVER['REQUEST_METHOD'] !== 'PATCH') {
    http_response_code(405);
    echo json_encode(['error' => 'Only PATCH allowed']);
    exit;
}

// Parse report ID from the URL (example: update_status.php?id=abc123)
$reportId = $_GET['id'] ?? null;
if (!$reportId) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing report ID']);
    exit;
}

// Read input JSON
$input = json_decode(file_get_contents('php://input'), true);
$newStatus = $input['status'] ?? null;

if (!$newStatus) {
    http_response_code(400);
    echo json_encode(['error' => 'Missing status in body']);
    exit;
}

// Update the status in database
try {
    $stmt = $pdo->prepare("UPDATE reports SET status = :status WHERE id = :id");
    $stmt->execute([
        ':status' => $newStatus,
        ':id' => $reportId,
    ]);

    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['error' => 'Report not found']);
    } else {
        echo json_encode(['success' => true, 'reportId' => $reportId, 'status' => $newStatus]);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to update status']);
}
