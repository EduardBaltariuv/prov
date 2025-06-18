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

// Upload directory configuration - Support both live and local environments
$uploadBaseDir = '/home/u842828699/domains/darkcyan-clam-483701.hostingersite.com/public_html/';
$localUploadBaseDir = '/home/vboxuser/Downloads/AplicatieAndroidProvidenta-main2/public_html/';

// Use local directory for testing, live directory for production
if (is_dir($uploadBaseDir)) {
    $uploadDir = $uploadBaseDir . 'uploads/';
} else {
    $uploadDir = $localUploadBaseDir . 'uploads/';
}

try {
    // Enhanced debug logging
    $debugLog = '/home/vboxuser/Downloads/AplicatieAndroidProvidenta-main2/public_html/api_debug.log';
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - REQUEST_METHOD: " . $_SERVER['REQUEST_METHOD'] . "\n", FILE_APPEND);
    
    // Check for POST size issues (common cause of 400 errors)
    $contentLength = $_SERVER['CONTENT_LENGTH'] ?? 0;
    $postMaxSize = ini_get('post_max_size');
    $uploadMaxFilesize = ini_get('upload_max_filesize');
    
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - Content-Length: $contentLength bytes\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - post_max_size: $postMaxSize\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - upload_max_filesize: $uploadMaxFilesize\n", FILE_APPEND);
    
    // Convert sizes to bytes for comparison
    function convertToBytes($size) {
        $unit = strtoupper(substr($size, -1));
        $value = (int)$size;
        switch ($unit) {
            case 'G': return $value * 1024 * 1024 * 1024;
            case 'M': return $value * 1024 * 1024;
            case 'K': return $value * 1024;
            default: return $value;
        }
    }
    
    $postMaxBytes = convertToBytes($postMaxSize);
    if ($contentLength > $postMaxBytes) {
        file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - ERROR: Content too large ($contentLength > $postMaxBytes)\n", FILE_APPEND);
        http_response_code(413);
        echo json_encode([
            'success' => false,
            'message' => 'Request too large. Reduce image sizes.',
            'error_code' => 'REQUEST_TOO_LARGE',
            'details' => [
                'content_length' => $contentLength,
                'max_allowed' => $postMaxBytes
            ]
        ]);
        exit;
    }
    
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - POST Data: " . print_r($_POST, true) . "\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - FILES Data: " . print_r($_FILES, true) . "\n", FILE_APPEND);
    file_put_contents($debugLog, date('Y-m-d H:i:s') . " - Enhanced Debug - Upload Dir: " . $uploadDir . "\n", FILE_APPEND);
    
    // Database connection
    try {
        mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
        $conn = new mysqli($host, $username, $password, $database, $port);
        $conn->set_charset("utf8mb4");
    } catch (Exception $dbError) {
        // For local testing, continue without database
        error_log("Database connection failed (continuing in test mode): " . $dbError->getMessage());
        $conn = null;
    }

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
    if (isset($conn) && $conn) {
        $conn->close();
    }
}

function handleCreateReport($conn, string $uploadDir): array {
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

        // For local testing, skip database user verification
        if ($conn && strpos($uploadDir, '/home/vboxuser/') === false) {
            // VERIFY USER EXISTS IN DATABASE (Only for live server)
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
        } else {
            error_log("Local testing mode - skipping database user verification");
        }

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
        error_log("Available _FILES keys: " . print_r(array_keys($_FILES), true));
        
        // Check for images sent with different field names (Flutter sometimes sends as separate fields)
        $imageFields = [];
        foreach ($_FILES as $key => $value) {
            if (strpos($key, 'image') !== false) {
                $imageFields[$key] = $value;
            }
        }
        error_log("Image-related fields found: " . print_r(array_keys($imageFields), true));
        
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
        } 
        
        // ENHANCED: Also check for files sent as separate fields (Flutter multipart issue workaround)
        foreach ($imageFields as $fieldName => $fileData) {
            if ($fieldName !== 'images' && !empty($fileData['tmp_name'])) {
                error_log("Found additional image field: $fieldName");
                error_log("Field data: " . print_r($fileData, true));
                
                // Create directory if needed
                if (!is_dir($uploadDir)) {
                    if (!mkdir($uploadDir, 0755, true)) {
                        throw new Exception("Failed to create upload directory: " . $uploadDir);
                    }
                }
                
                if (is_array($fileData['tmp_name'])) {
                    foreach ($fileData['tmp_name'] as $key => $tmpName) {
                        if (!empty($tmpName)) {
                            $imagePaths[] = processUploadedFile(
                                $tmpName, 
                                $fileData['name'][$key], 
                                $fileData['error'][$key], 
                                $uploadDir
                            );
                        }
                    }
                } else {
                    $imagePaths[] = processUploadedFile(
                        $fileData['tmp_name'], 
                        $fileData['name'], 
                        $fileData['error'], 
                        $uploadDir
                    );
                }
            }
        }
        
        if (empty($_FILES['images']) && empty($imageFields)) {
            error_log("No images uploaded - no 'images' or image-related fields found");
        }
        
        error_log("Total images processed successfully: " . count($imagePaths));
        error_log("Image paths: " . print_r($imagePaths, true));
        error_log("=== FILE UPLOAD PROCESSING END ===");

        // For local testing, skip database operations
        if (!$conn || strpos($uploadDir, '/home/vboxuser/') !== false) {
            error_log("Local testing mode - skipping database operations");
            return [
                'success' => true,
                'id' => 'test_' . time(),
                'username' => $username,
                'image_paths' => $imagePaths,
                'message' => 'Raportul a fost creat cu succes! (Test mode)'
            ];
        }

        // Prepare and execute database insert (live server only)
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
    error_log("  file size: " . (file_exists($tmpName) ? filesize($tmpName) : 'file not found') . " bytes");
    
    // Enhanced error checking with specific messages
    if ($error !== UPLOAD_ERR_OK) {
        $errorMsg = getUploadErrorMsg($error);
        error_log("  Upload error: " . $errorMsg);
        
        // For client-side errors, throw more specific exceptions
        if ($error === UPLOAD_ERR_INI_SIZE || $error === UPLOAD_ERR_FORM_SIZE) {
            throw new Exception("File too large: $fileName. Maximum size allowed is " . ini_get('upload_max_filesize'));
        } elseif ($error === UPLOAD_ERR_PARTIAL) {
            throw new Exception("File upload was interrupted: $fileName. Please try again.");
        } elseif ($error === UPLOAD_ERR_NO_FILE) {
            throw new Exception("No file was uploaded: $fileName");
        } else {
            throw new Exception("File upload error: " . $errorMsg);
        }
    }

    // Check if temp file exists
    if (!file_exists($tmpName)) {
        error_log("  ERROR: Temp file does not exist: " . $tmpName);
        throw new Exception("Temp file does not exist: " . $tmpName);
    }
    
    // Check if file is empty
    $fileSize = filesize($tmpName);
    if ($fileSize === 0) {
        error_log("  ERROR: File is empty: " . $tmpName);
        throw new Exception("Uploaded file is empty: $fileName");
    }
    
    error_log("  Temp file exists and is readable: " . (is_readable($tmpName) ? 'YES' : 'NO'));
    error_log("  File size: $fileSize bytes");

    // MIME type validation with fallback
    $mime = null;
    if (function_exists('finfo_open')) {
        $finfo = new finfo(FILEINFO_MIME_TYPE);
        $mime = $finfo->file($tmpName);
    } else {
        // Fallback to extension-based detection
        $extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
        $mimeMap = [
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg', 
            'png' => 'image/png',
            'gif' => 'image/gif'
        ];
        $mime = $mimeMap[$extension] ?? 'unknown';
    }
    
    error_log("  MIME type detected: " . $mime);
    
    $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
    
    if (!in_array($mime, $allowedTypes, true)) {
        error_log("  ERROR: Invalid MIME type: " . $mime);
        throw new Exception("Invalid file type: $fileName. Only JPEG, PNG, GIF allowed. Detected: $mime");
    }

    // Generate unique filename with proper extension
    $extension = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
    if (!in_array($extension, ['jpg', 'jpeg', 'png', 'gif'])) {
        $extension = 'jpg'; // Default to jpg if extension is invalid
    }
    $filename = uniqid('img_', true) . '.' . $extension;
    $targetPath = $uploadDir . $filename;
    
    error_log("  Generated filename: " . $filename);
    error_log("  Target path: " . $targetPath);
    error_log("  Target directory writable: " . (is_writable(dirname($targetPath)) ? 'YES' : 'NO'));

    if (!move_uploaded_file($tmpName, $targetPath)) {
        error_log("  ERROR: Failed to move uploaded file from " . $tmpName . " to " . $targetPath);
        error_log("  Source file exists: " . (file_exists($tmpName) ? 'YES' : 'NO'));
        error_log("  Target directory exists: " . (is_dir(dirname($targetPath)) ? 'YES' : 'NO'));
        error_log("  Target directory permissions: " . (is_dir(dirname($targetPath)) ? substr(sprintf('%o', fileperms(dirname($targetPath))), -4) : 'N/A'));
        throw new Exception("Failed to save uploaded file: $fileName");
    }
    
    // Verify the file was actually moved and has content
    if (!file_exists($targetPath) || filesize($targetPath) === 0) {
        error_log("  ERROR: File was not properly saved or is empty after move");
        throw new Exception("File upload verification failed: $fileName");
    }
    
    error_log("  SUCCESS: File moved to " . $targetPath);
    error_log("  Final file size: " . filesize($targetPath) . " bytes");
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
