<?php
declare(strict_types=1);
// Headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, HEAD");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Expose-Headers: *");

// Set timezone for consistent time handling
date_default_timezone_set('Europe/Bucharest'); // Romania timezone

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = 3306;

// Upload directory configuration
$baseUrl = "https://darkcyan-clam-483701.hostingersite.com";
$uploadBaseDir = '/home/u842828699/domains/darkcyan-clam-483701.hostingersite.com/public_html/';
$uploadDir = $uploadBaseDir . 'uploads/';
$uploadPublicPath = '/uploads/';

try {
    // Connect to DB
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $conn = new mysqli($host, $username, $password, $database, $port);
    $conn->set_charset("utf8mb4");

    $action = $_POST['action'] ?? '';

    switch ($action) {
        case 'getReport':
            handleGetReports($conn, $baseUrl, $uploadPublicPath);
            break;

        case 'updateReportStatus':
            handleUpdateReportStatus($conn);
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
}

// Get reports from DB
function handleGetReports(mysqli $conn, string $baseUrl, string $uploadPublicPath): void {
    $stmt = $conn->prepare("
        SELECT 
            id,
            title,
            description,
            category,
            location,
            image_paths,
            created_at,
            username,
            status
        FROM reports
        ORDER BY created_at DESC
    ");

    $stmt->execute();
    $result = $stmt->get_result();

    $reports = [];
    while ($row = $result->fetch_assoc()) {
        $imagePaths = !empty($row['image_paths']) ? json_decode($row['image_paths'], true) : [];

        if (json_last_error() !== JSON_ERROR_NONE) {
            $imagePaths = [];
        }

        $row['image_urls'] = array_map(function($path) use ($baseUrl, $uploadPublicPath) {
            return $baseUrl . $uploadPublicPath . basename($path);
        }, $imagePaths);

        unset($row['image_paths']);
        
        // Enhanced time formatting with timezone info
        $dateTime = new DateTime($row['created_at']);
        $dateTime->setTimezone(new DateTimeZone('Europe/Bucharest'));
        $row['created_at'] = $dateTime->format(DateTime::ATOM);
        $row['created_at_readable'] = $dateTime->format('d/m/Y H:i');
        $row['timezone'] = $dateTime->getTimezone()->getName();

        $reports[] = $row;
    }

    echo json_encode([
        'success' => true,
        'reports' => $reports
    ]);
}

// Update report status
function handleUpdateReportStatus(mysqli $conn): void {
    $reportId = $_POST['reportId'] ?? '';
    $newStatus = $_POST['status'] ?? '';

    if (!$reportId || !$newStatus) {
        http_response_code(400);
        echo json_encode([
            'success' => false,
            'message' => 'Missing reportId or status'
        ]);
        return;
    }

    $stmt = $conn->prepare("UPDATE reports SET status = ? WHERE id = ?");
    $stmt->bind_param("ss", $newStatus, $reportId);
    $stmt->execute();

    if ($stmt->affected_rows === 0) {
        http_response_code(404);
        echo json_encode([
            'success' => false,
            'message' => 'Report not found or status unchanged'
        ]);
    } else {
        echo json_encode([
            'success' => true,
            'message' => 'Status updated',
            'reportId' => $reportId,
            'newStatus' => $newStatus
        ]);
    }
}