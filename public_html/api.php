<?php
header("Access-Control-Allow-Headers: Authorization, Content-Type");
header("Access-Control-Allow-Origin: *");
header('content-type: application/json; charset=utf-8');

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

// Get the input data
$input = json_decode(file_get_contents('php://input'), true);

// Handle different actions
try {
    switch ($input['action'] ?? '') {
        case 'login':
            handleLogin($conn, $input);
            break;
        default:
            throw new Exception('Invalid action');
    }
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => $e->getMessage()
    ]);
}

function handleLogin($conn, $input) {
    // Validate input
    if (empty($input['username']) || empty($input['password'])) {
        throw new Exception('Username and password are required');
    }

    // Prepare and execute query
    $stmt = $conn->prepare("SELECT id, username, role FROM login WHERE username = ? AND password_hash = ?");
    $stmt->bind_param("ss", $input['username'], $input['password']);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        throw new Exception('Invalid username or password');
    }

    $user = $result->fetch_assoc();
    
    // Successful login
    echo json_encode([
        "success" => true,
        "token" => bin2hex(random_bytes(32)),
        "id" => $user['id'],
        "username" => $user['username'],
        "role" => $user['role']
    ]);
}

$conn->close();
?>