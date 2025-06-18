<?php

// Set content type to JSON for the responses
header('Content-Type: application/json');

// Database configuration
$host = "localhost";
$username = "u842828699_common";
$password = "Karlmarx12!";
$database = "u842828699_common";
$port = "3306";

// Create a new database connection
$conn = new mysqli($host, $username, $password, $database, $port);

// Check the connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Define the base directory where the website is hosted
$uploadBaseDir = '/home/u842828699/domains/darkcyan-clam-483701.hostingersite.com/public_html/';

// Define the directory for storing profile images
$uploadDir = $uploadBaseDir . 'uploads/';

// Ensure the uploads directory exists
if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true); // Create the directory with appropriate permissions
}

// Enable CORS to allow requests from different origins
header('Access-Control-Allow-Origin: *'); // Allow any origin (You can restrict this to a specific domain)
header('Access-Control-Allow-Methods: GET, POST, DELETE'); // Allow only GET, POST, and DELETE methods
header('Access-Control-Allow-Headers: Content-Type, Authorization'); // Allow content-type and authorization headers

// Handle preflight requests for CORS
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200); // Respond with a 200 OK for OPTIONS requests
    exit;
}

// Get the method of the HTTP request (GET, POST, DELETE)
$method = $_SERVER['REQUEST_METHOD'];

// Parse the request path to determine the action
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);
$segments = explode('/', $path);

// Assume the username is the last segment
$username = end($segments);

// Handle requests based on the HTTP method
switch ($method) {
    case 'GET':
        // Fetch the profile image for the given username
        if ($username) {
            getProfileImage($username);
        } else {
            echo json_encode(['error' => 'Username is required.']);
        }
        break;

    case 'POST':
        // Upload a new profile image
        if (isset($_FILES['file']) && $username) {
            uploadProfileImage($username, $_FILES['file']);
        } else {
            echo json_encode(['error' => 'File is required.']);
        }
        break;

    case 'DELETE':
        // Delete the profile image for the given username
        if ($username) {
            deleteProfileImage($username);
        } else {
            echo json_encode(['error' => 'Username is required.']);
        }
        break;

    default:
        echo json_encode(['error' => 'Invalid request method.']);
}

// Function to get the profile image
function getProfileImage($username)
{
    global $uploadDir, $conn;
    $imagePath = $uploadDir . $username; // The file extension will be determined dynamically

    if (file_exists($imagePath . '.jpg')) {
        header('Content-Type: image/jpeg');
        readfile($imagePath . '.jpg');
    } elseif (file_exists($imagePath . '.jpeg')) {
        header('Content-Type: image/jpeg');
        readfile($imagePath . '.jpeg');
    } elseif (file_exists($imagePath . '.png')) {
        header('Content-Type: image/png');
        readfile($imagePath . '.png');
    } else {
        echo json_encode(['error' => 'Profile image not found.']);
    }
}

// Function to upload a new profile image
function uploadProfileImage($username, $file)
{
    global $uploadDir, $conn;

    // Check if the uploaded file is valid
    if ($file['error'] !== UPLOAD_ERR_OK) {
        echo json_encode(['error' => 'File upload error.']);
        return;
    }

    // Validate the file type (only allow jpg, jpeg, and png)
    $fileExtension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($fileExtension, ['jpg', 'jpeg', 'png'])) {
        echo json_encode(['error' => 'Invalid file type. Only jpg, jpeg, and png are allowed.']);
        return;
    }

    // Delete the old image if it exists
    deleteProfileImage($username);

    // Determine the new file name based on the username and its extension
    $destination = $uploadDir . $username . '.' . $fileExtension;

    // Move the uploaded file to the profile image directory
    if (move_uploaded_file($file['tmp_name'], $destination)) {
        // Update the profile_path in the login table
        $stmt = $conn->prepare("UPDATE login SET profile_path = ? WHERE username = ?");
        $profilePath = 'uploads/profile_images/' . $username . '.' . $fileExtension;
        $stmt->bind_param("ss", $profilePath, $username);
        if ($stmt->execute()) {
            echo json_encode(['success' => 'Profile image uploaded and path saved successfully.']);
        } else {
            echo json_encode(['error' => 'Failed to update profile path in database.']);
        }
        $stmt->close();
    } else {
        echo json_encode(['error' => 'Failed to move uploaded file.']);
    }
}

// Function to delete the profile image
function deleteProfileImage($username)
{
    global $uploadDir, $conn;

    $extensions = ['jpg', 'jpeg', 'png']; // Supported extensions

    foreach ($extensions as $ext) {
        $imagePath = $uploadDir . $username . '.' . $ext;
        if (file_exists($imagePath)) {
            unlink($imagePath); // Delete the old image
            // Update the profile_path in the login table
            $stmt = $conn->prepare("UPDATE login SET profile_path = NULL WHERE username = ?");
            $stmt->bind_param("s", $username);
            if ($stmt->execute()) {
                echo json_encode(['success' => 'Old profile image deleted and path removed from database.']);
            } else {
                echo json_encode(['error' => 'Failed to update profile path in database.']);
            }
            $stmt->close();


            break;
        }
    }
}

// Close the database connection
$conn->close();
?>

 
