<?php
declare(strict_types=1);

// Headers must be first
header("Access-Control-Allow-Headers: Authorization, Content-Type");
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json; charset=utf-8');

// Disable HTML error output - this is crucial for clean JSON
ini_set('display_errors', '0');
ini_set('html_errors', '0');
error_reporting(E_ALL);

// Start output buffering to catch any unexpected output
ob_start();

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = 3306;

// Upload directory configuration
$uploadBaseDir = '/home/u842828699/domains/darkcyan-clam-483701.hostingersite.com/public_html/';
$uploadDir = $uploadBaseDir . 'uploads/';

try {
    // Database connection
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $conn = new mysqli($host, $username, $password, $database, $port);
    $conn->set_charset("utf8mb4");

    // Get action from POST
    $action = $_POST['action'] ?? '';
    error_log("Action received: $action");

    switch ($action) {
        case 'createReport':
            $response = handleCreateReport($conn, $uploadDir);
            // Clean any unexpected output before sending JSON
            ob_end_clean();
            echo json_encode($response);
            break;
        case 'updateReport':
            $response = handleUpdateReport($conn, $uploadDir);
            // Clean any unexpected output before sending JSON
            ob_end_clean();
            echo json_encode($response);
            break;
        default:
            ob_end_clean();
            http_response_code(400);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid action',
                'details' => ['received_action' => $action]
            ]);
    }

} catch (Throwable $e) {
    error_log("Caught exception: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
    // Clean any unexpected output before sending JSON
    ob_end_clean();
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'An unexpected error occurred',
        'error_details' => [
            'message' => $e->getMessage(),
            'type' => get_class($e),
            'file' => $e->getFile(),
            'line' => $e->getLine()
        ]
    ]);
} finally {
    if (isset($conn)) {
        $conn->close();
    }
}

function handleCreateReport(mysqli $conn, string $uploadDir): array {
    try {
        // ENHANCED AUTHENTICATION VALIDATION
        // Check if username is provided and not null/empty
        $username = $_POST['username'] ?? '';
        $username = trim($username);
        
        if (empty($username) || $username === 'null' || $username === 'undefined') {
            http_response_code(401);
            return [
                'success' => false,
                'message' => 'Eroare: utilizatorul nu este autentificat. Va rugam sa va reconectati.',
                'error_code' => 'USER_NOT_AUTHENTICATED',
                'details' => [
                    'received_username' => $_POST['username'] ?? 'not_provided',
                    'trimmed_username' => $username
                ]
            ];
        }

        // Validate username format (basic example)
        if (!preg_match('/^[a-zA-Z0-9_.]{3,50}$/', $username)) {
            http_response_code(400);
            return [
                'success' => false,
                'message' => 'Format utilizator invalid. Utilizati doar litere, cifre, underscore si punct (3-50 caractere).',
                'error_code' => 'INVALID_USERNAME_FORMAT',
                'requirements' => '3-50 chars, alphanumeric, underscore and dot allowed'
            ];
        }

        // VERIFY USER EXISTS IN DATABASE (Additional security)
        $userStmt = $conn->prepare("SELECT id, username FROM login WHERE username = ? LIMIT 1");
        if (!$userStmt) {
            throw new Exception("Failed to prepare user verification statement: " . $conn->error);
        }
        
        $userStmt->bind_param("s", $username);
        $userStmt->execute();
        $userResult = $userStmt->get_result();
        
        if ($userResult->num_rows === 0) {
            http_response_code(401);
            return [
                'success' => false,
                'message' => 'Utilizator invalid sau inexistent. Va rugam sa va reconectati.',
                'error_code' => 'INVALID_USER',
                'details' => ['username' => $username]
            ];
        }
        
        $userStmt->close();

        // Validate other required fields
        $requiredFields = ['title', 'description', 'category', 'location'];
        $missingFields = [];
        
        foreach ($requiredFields as $field) {
            $value = $_POST[$field] ?? '';
            $value = trim($value);
            if (empty($value)) {
                $missingFields[] = $field;
            }
        }
        
        if (!empty($missingFields)) {
            http_response_code(400);
            return [
                'success' => false,
                'message' => 'Completati toate campurile obligatorii.',
                'error_code' => 'MISSING_REQUIRED_FIELDS',
                'missing_fields' => $missingFields
            ];
        }

        // Process file uploads
        $imagePaths = [];
        if (isset($_FILES['images']) && is_array($_FILES['images']['tmp_name'])) {
            // Create directory if needed
            if (!is_dir($uploadDir) && !mkdir($uploadDir, 0755, true)) {
                throw new Exception("Failed to create upload directory: " . $uploadDir);
            }

            foreach ($_FILES['images']['tmp_name'] as $key => $tmpName) {
                // Skip if no file was uploaded
                if (empty($tmpName)) continue;

                // Error checking
                if ($_FILES['images']['error'][$key] !== UPLOAD_ERR_OK) {
                    throw new Exception(
                        "File upload error: " . 
                        getUploadErrorMsg($_FILES['images']['error'][$key])
                    );
                }

                // MIME type validation
                $finfo = new finfo(FILEINFO_MIME_TYPE);
                $mime = $finfo->file($tmpName);
                $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
                
                if (!in_array($mime, $allowedTypes, true)) {
                    http_response_code(415);
                    return [
                        'success' => false,
                        'message' => 'Tipul de fisier nu este permis. Folositi doar imagini (JPEG, PNG, GIF).',
                        'error_code' => 'INVALID_FILE_TYPE',
                        'details' => [
                            'file' => $_FILES['images']['name'][$key],
                            'type' => $mime,
                            'allowed_types' => $allowedTypes
                        ]
                    ];
                }

                // Generate unique filename with username prefix
                $extension = pathinfo($_FILES['images']['name'][$key], PATHINFO_EXTENSION);
                $filename = uniqid('img_', true) . '.' . $extension;
                $targetPath = $uploadDir . $filename;

                if (!move_uploaded_file($tmpName, $targetPath)) {
                    throw new Exception("Failed to save uploaded file: " . $targetPath);
                }

                $imagePaths[] = $filename;
            }
        }

        // Anti-duplicate protection: Check if a similar report was created recently
        $duplicateCheck = $conn->prepare(
            "SELECT id FROM reports 
             WHERE username = ? AND title = ? AND description = ? AND category = ? AND location = ?
             AND created_at > DATE_SUB(NOW(), INTERVAL 30 SECOND)
             LIMIT 1"
        );
        
        if ($duplicateCheck) {
            $duplicateCheck->bind_param("sssss", 
                $username, 
                $_POST['title'], 
                $_POST['description'], 
                $_POST['category'], 
                $_POST['location']
            );
            $duplicateCheck->execute();
            $duplicateResult = $duplicateCheck->get_result();
            
            if ($duplicateResult->num_rows > 0) {
                $duplicateCheck->close();
                return [
                    'success' => false,
                    'message' => 'Un raport identic a fost creat recent. Va rugam asteptati 30 de secunde inainte de a crea un alt raport similar.',
                    'error_code' => 'DUPLICATE_REPORT'
                ];
            }
            $duplicateCheck->close();
        }

        // Prepare and execute database insert
        $stmt = $conn->prepare("INSERT INTO reports 
                              (title, description, category, location, image_urls, username, created_at) 
                              VALUES (?, ?, ?, ?, ?, ?, NOW())");
        
        if (!$stmt) {
            throw new Exception("Database preparation failed: " . $conn->error);
        }

        $imagePathsJson = empty($imagePaths) ? null : json_encode($imagePaths);
        $stmt->bind_param("ssssss",
            $_POST['title'],
            $_POST['description'],
            $_POST['category'],
            $_POST['location'],
            $imagePathsJson,
            $username  // Use the validated username
        );

        if (!$stmt->execute()) {
            throw new Exception("Database execution failed: " . $stmt->error);
        }

        // Log successful report creation
        error_log("Report created successfully for user: $username, ID: " . $stmt->insert_id);

        return [
            'success' => true,
            'id' => $stmt->insert_id,
            'username' => $username,
            'image_paths' => $imagePaths,
            'message' => 'Raportul a fost creat cu succes!'
        ];

    } catch (Exception $e) {
        // Clean up any uploaded files if error occurred
        if (!empty($imagePaths)) {
            foreach ($imagePaths as $file) {
                @unlink($uploadDir . $file);
            }
        }
        
        error_log("Error in handleCreateReport: " . $e->getMessage());
        throw $e;
    }
}

function handleUpdateReport(mysqli $conn, string $uploadDir): array {
    try {
        // Get and validate username
        $username = $_POST['username'] ?? '';
        $username = trim($username);
        
        if (empty($username)) {
            return [
                'success' => false,
                'message' => 'User authentication required.',
                'error_code' => 'USER_NOT_AUTHENTICATED'
            ];
        }

        // Get report ID
        $reportId = $_POST['report_id'] ?? '';
        if (empty($reportId)) {
            return [
                'success' => false,
                'message' => 'Report ID is required.',
                'error_code' => 'MISSING_REPORT_ID'
            ];
        }

        // Check if user can edit this report
        $userStmt = $conn->prepare("SELECT role FROM login WHERE username = ? LIMIT 1");
        if (!$userStmt) {
            throw new Exception("Failed to prepare user statement: " . $conn->error);
        }
        
        $userStmt->bind_param("s", $username);
        $userStmt->execute();
        $userResult = $userStmt->get_result();
        
        if ($userResult->num_rows === 0) {
            return [
                'success' => false,
                'message' => 'Invalid user.',
                'error_code' => 'INVALID_USER'
            ];
        }
        
        $userData = $userResult->fetch_assoc();
        $userRole = $userData['role'];
        $userStmt->close();

        // Check if report exists and user has permission to edit it
        $reportStmt = $conn->prepare("SELECT username FROM reports WHERE id = ? LIMIT 1");
        if (!$reportStmt) {
            throw new Exception("Failed to prepare report statement: " . $conn->error);
        }
        
        $reportStmt->bind_param("i", $reportId);
        $reportStmt->execute();
        $reportResult = $reportStmt->get_result();
        
        if ($reportResult->num_rows === 0) {
            return [
                'success' => false,
                'message' => 'Report not found.',
                'error_code' => 'REPORT_NOT_FOUND'
            ];
        }
        
        $reportData = $reportResult->fetch_assoc();
        $reportOwner = $reportData['username'];
        $reportStmt->close();

        // Check permissions: admin can edit any report, others can only edit their own
        if ($userRole !== 'admin' && $reportOwner !== $username) {
            return [
                'success' => false,
                'message' => 'Permission denied to edit this report.',
                'error_code' => 'PERMISSION_DENIED'
            ];
        }

        // Validate required fields
        $title = $_POST['title'] ?? '';
        $description = $_POST['description'] ?? '';
        $category = $_POST['category'] ?? '';
        $location = $_POST['location'] ?? '';

        if (empty($title) || empty($description) || empty($category) || empty($location)) {
            return [
                'success' => false,
                'message' => 'All required fields must be completed.',
                'error_code' => 'MISSING_REQUIRED_FIELDS'
            ];
        }

        // Update the report (simplified - not handling new images for now)
        $updateStmt = $conn->prepare("UPDATE reports SET title = ?, description = ?, category = ?, location = ? WHERE id = ?");
        
        if (!$updateStmt) {
            throw new Exception("Failed to prepare update statement: " . $conn->error);
        }

        $updateStmt->bind_param("ssssi", $title, $description, $category, $location, $reportId);
        
        if (!$updateStmt->execute()) {
            throw new Exception("Failed to update report: " . $updateStmt->error);
        }
        
        $updateStmt->close();
        
        return [
            'success' => true,
            'message' => 'Report updated successfully.',
            'report_id' => $reportId
        ];

    } catch (Exception $e) {
        error_log("handleUpdateReport Exception: " . $e->getMessage());
        return [
            'success' => false,
            'message' => 'Error updating report: ' . $e->getMessage(),
            'error_code' => 'UPDATE_ERROR'
        ];
    }
}

function getUploadErrorMsg(int $errorCode): string {
    $uploadErrors = [
        UPLOAD_ERR_INI_SIZE => 'File exceeds upload_max_filesize directive in php.ini',
        UPLOAD_ERR_FORM_SIZE => 'File exceeds MAX_FILE_SIZE directive in HTML form',
        UPLOAD_ERR_PARTIAL => 'File was only partially uploaded',
        UPLOAD_ERR_NO_FILE => 'No file was uploaded',
        UPLOAD_ERR_NO_TMP_DIR => 'Missing temporary folder',
        UPLOAD_ERR_CANT_WRITE => 'Failed to write file to disk',
        UPLOAD_ERR_EXTENSION => 'File upload stopped by PHP extension',
    ];
    
    return $uploadErrors[$errorCode] ?? "Unknown upload error (code $errorCode)";
}
