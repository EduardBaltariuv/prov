<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Database configuration
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

// Get the request method and path
$requestMethod = $_SERVER['REQUEST_METHOD'];
$path = trim(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH), '/');
$endpoint = basename($path);

// Process the request
try {
    $input = json_decode(file_get_contents('php://input'), true);
    
    switch ($endpoint) {
        case 'login':
            if ($requestMethod == 'POST') {
                // Login endpoint
                if (empty($input['username']) || empty($input['password'])) {
                    throw new Exception('Username and password are required');
                }
                
                $stmt = $conn->prepare("SELECT id, username, role FROM login WHERE username = ? AND _password_hash = ?");
                $stmt->bind_param("ss", $input['username'], $input['password']);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows == 0) {
                    throw new Exception('Invalid username or password');
                }
                
                $user = $result->fetch_assoc();
                $token = bin2hex(random_bytes(32));
                
                // Store token in database
                $stmt = $conn->prepare("UPDATE login SET auth_token = ? WHERE id = ?");
                $stmt->bind_param("si", $token, $user['id']);
                $stmt->execute();
                
                echo json_encode([
                    "success" => true,
                    "token" => $token,
                    "username" => $user['username'],
                    "role" => $user['role'],
                    "id" => $user['id']
                ]);
            } else {
                throw new Exception('Method not allowed', 405);
            }
            break;
            
        case 'validate':
            if ($requestMethod == 'GET') {
                // Token validation
                $headers = getallheaders();
                $authHeader = $headers['Authorization'] ?? '';
                $token = str_replace('Bearer ', '', $authHeader);
                
                if (empty($token)) {
                    throw new Exception('Token is required', 401);
                }
                
                $stmt = $conn->prepare("SELECT username, role FROM login WHERE auth_token = ?");
                $stmt->bind_param("s", $token);
                $stmt->execute();
                $result = $stmt->get_result();
                
                if ($result->num_rows == 0) {
                    throw new Exception('Invalid token', 401);
                }
                
                echo json_encode(["success" => true]);
            } else {
                throw new Exception('Method not allowed', 405);
            }
            break;
            
        case 'logout':
            if ($requestMethod == 'POST') {
                // Logout endpoint
                $headers = getallheaders();
                $authHeader = $headers['Authorization'] ?? '';
                $token = str_replace('Bearer ', '', $authHeader);
                
                if (empty($token)) {
                    throw new Exception('Token is required', 401);
                }
                
                $stmt = $conn->prepare("UPDATE login SET auth_token = NULL WHERE auth_token = ?");
                $stmt->bind_param("s", $token);
                $stmt->execute();
                
                echo json_encode(["success" => true]);
            } else {
                throw new Exception('Method not allowed', 405);
            }
            break;
            
        default:
            throw new Exception('Endpoint not found', 404);
    }
} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}

$conn->close();
?>