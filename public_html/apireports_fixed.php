<?php
declare(strict_types=1);

// Headers must be first
header("Access-Control-Allow-Headers: Authorization, Content-Type");
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json; charset=utf-8');

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
$uploadBaseDir = '/home/u842828699/domains/darkcyan-clam-483701.hostingersite.com/public_html/';
$uploadDir = $uploadBaseDir . 'uploads/';

try {
    // Enhanced debug logging
    $debugLog = '/home/vboxuser/Downloads/AplicatieAndroidProvidenta-main2/public_html/api_debug.log';
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - REQUEST_METHOD: " . $_SERVER['REQUEST_METHOD'] . "\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - POST Data: " . print_r($_POST, true) . "\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - FILES Data: " . print_r($_FILES, true) . "\n", FILE_APPEND);
    
    // Database connection
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    $conn = new mysqli($host, $username, $password, $database, $port);
    $conn->set_charset("utf8mb4");

    // Get action from POST
    $action = $_POST['action'] ?? '';
    error_log("Action received: $action");
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - Action received: $action\n", FILE_APPEND);

    switch ($action) {
        case 'createReport':
        case 'create_report':
            file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - Entering handleCreateReport function\n", FILE_APPEND);
            $response = handleCreateReport($conn, $uploadDir);
            echo json_encode($response);
            break;
        default:
            http_response_code(400);
            file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - Invalid action: $action\n", FILE_APPEND);
            echo json_encode([
                'success' => false,
                'message' => 'Invalid action',
                'details' => ['received_action' => $action]
            ]);
    }

} catch (Throwable $e) {
    error_log("Caught exception: " . $e->getMessage());
    error_log("Stack trace: " . $e->getTraceAsString());
    
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
        // ==== DEBUG LOGGING START ====
        error_log("=== handleCreateReport DEBUG START ===");
        error_log("POST Data: " . print_r($_POST, true));
        error_log("FILES Data: " . print_r($_FILES, true));
        error_log("Upload Directory: " . $uploadDir);
        error_log("Upload Directory exists: " . (is_dir($uploadDir) ? 'YES' : 'NO'));
        error_log("Upload Directory writable: " . (is_writable($uploadDir) ? 'YES' : 'NO'));
        
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

        // Validate username format - allow letters, numbers, underscore, and dots
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

        // Process file uploads - Enhanced to handle both array and single file formats
        $imagePaths = [];
        error_log("=== FILE UPLOAD PROCESSING START ===");
        
        if (isset($_FILES['images'])) {
            error_log("_FILES['images'] is set");
            error_log("_FILES['images'] structure: " . print_r($_FILES['images'], true));
            
            // Create directory if needed
            if (!is_dir($uploadDir)) {
                error_log("Upload directory does not exist, creating: " . $uploadDir);
                if (!mkdir($uploadDir, 0755, true)) {
                    error_log("FAILED to create upload directory: " . $uploadDir);
                    throw new Exception("Failed to create upload directory: " . $uploadDir);
                } else {
                    error_log("Successfully created upload directory: " . $uploadDir);
                }
            } else {
                error_log("Upload directory already exists: " . $uploadDir);
            }
            
            if (is_array($_FILES['images']['tmp_name'])) {
                // Handle multiple files with array notation (images[])
                error_log("_FILES['images']['tmp_name'] is an array with " . count($_FILES['images']['tmp_name']) . " elements");
                
                foreach ($_FILES['images']['tmp_name'] as $key => $tmpName) {
                    error_log("Processing file index $key:");
                    
                    // Skip if no file was uploaded
                    if (empty($tmpName)) {
                        error_log("  Skipping - empty tmp_name");
                        continue;
                    }

                    $imagePaths[] = processUploadedFile(
                        $tmpName, 
                        $_FILES['images']['name'][$key], 
                        $_FILES['images']['error'][$key], 
                        $uploadDir
                    );
                }
            } else {
                // Handle single file upload (backward compatibility)
                error_log("_FILES['images']['tmp_name'] is a single file");
                
                if (!empty($_FILES['images']['tmp_name'])) {
                    $imagePaths[] = processUploadedFile(
                        $_FILES['images']['tmp_name'], 
                        $_FILES['images']['name'], 
                        $_FILES['images']['error'], 
                        $uploadDir
                    );
                }
            }
        } else {
            error_log("No images uploaded - _FILES['images'] is not set");
        }
        
        error_log("Total images processed successfully: " . count($imagePaths));
        error_log("Image paths: " . print_r($imagePaths, true));
        error_log("=== FILE UPLOAD PROCESSING END ===");

        // Prepare and execute database insert
        $stmt = $conn->prepare("INSERT INTO reports 
                              (title, description, category, location, image_paths, username, created_at) 
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
        error_log("=== handleCreateReport DEBUG END ===");

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

function processUploadedFile(string $tmpName, string $fileName, int $error, string $uploadDir): string {
    error_log("Processing single file: $fileName");
    error_log("  tmp_name: $tmpName");
    error_log("  error: $error");
    
    // Error checking
    if ($error !== UPLOAD_ERR_OK) {
        $errorMsg = getUploadErrorMsg($error);
        error_log("  Upload error: " . $errorMsg);
        throw new Exception("File upload error: " . $errorMsg);
    }

    // Check if temp file exists
    if (!file_exists($tmpName)) {
        error_log("  ERROR: Temp file does not exist: " . $tmpName);
        throw new Exception("Temp file does not exist: " . $tmpName);
    }
    
    error_log("  Temp file exists and is readable: " . (is_readable($tmpName) ? 'YES' : 'NO'));

    // MIME type validation
    $finfo = new finfo(FILEINFO_MIME_TYPE);
    $mime = $finfo->file($tmpName);
    error_log("  MIME type detected: " . $mime);
    
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    
    if (!in_array($mime, $allowedTypes, true)) {
        error_log("  ERROR: Invalid MIME type: " . $mime);
        throw new Exception("Invalid file type: $mime. Only JPEG, PNG, GIF allowed.");
    }

    // Generate unique filename
    $extension = pathinfo($fileName, PATHINFO_EXTENSION);
    $filename = uniqid('img_', true) . '.' . $extension;
    $targetPath = $uploadDir . $filename;
    
    error_log("  Generated filename: " . $filename);
    error_log("  Target path: " . $targetPath);
    error_log("  Target directory writable: " . (is_writable(dirname($targetPath)) ? 'YES' : 'NO'));

    if (!move_uploaded_file($tmpName, $targetPath)) {
        error_log("  ERROR: Failed to move uploaded file from " . $tmpName . " to " . $targetPath);
        error_log("  Source file exists: " . (file_exists($tmpName) ? 'YES' : 'NO'));
        error_log("  Target directory exists: " . (is_dir(dirname($targetPath)) ? 'YES' : 'NO'));
        throw new Exception("Failed to move uploaded file");
    }
    
    error_log("  SUCCESS: File moved to " . $targetPath);
    return $filename;
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
?>
