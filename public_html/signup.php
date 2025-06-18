<?php
header("Access-Control-Allow-Origin: *"); // Allow any origin
header("Access-Control-Allow-Methods: POST, GET, OPTIONS"); // Allow POST, GET, and OPTIONS requests
header("Access-Control-Allow-Headers: Content-Type, Authorization"); // Allow headers for content-type and authorization

// Handle pre-flight request (OPTIONS method)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    exit(0); // Just return a successful response for OPTIONS requests
}

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

// Process the request
try {
    $input = json_decode(file_get_contents('php://input'), true);

    if ($_SERVER['REQUEST_METHOD'] == 'POST') {
        // Signup endpoint
        if (empty($input['username']) || empty($input['password']) || empty($input['role'])) {
            throw new Exception('Username, password, and role are required');
        }

        // Use password directly without hashing
        $passwordPlain = $input['password'];

        // Ensure role is stored in lowercase if it's 'Reporter'
        $role = ($input['role'] === 'Reporter') ? 'reporter' : $input['role'];

        // Check if username already exists
        $stmt = $conn->prepare("SELECT id FROM login WHERE username = ?");
        $stmt->bind_param("s", $input['username']);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            throw new Exception('Username already exists');
        }

        // Insert new user into the login table
        $stmt = $conn->prepare("INSERT INTO login (username, password_hash, role) VALUES (?, ?, ?)");
        $stmt->bind_param("sss", $input['username'], $passwordPlain, $role);
        if ($stmt->execute()) {
            echo json_encode([
                "success" => true,
                "message" => "Account created successfully"
            ]);
        } else {
            throw new Exception('Failed to create account');
        }
    } else {
        throw new Exception('Method not allowed', 405);
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
