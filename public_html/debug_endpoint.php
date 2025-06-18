<?php
// debug_endpoint.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: *");
header("Content-Type: application/json");

$log = [
    'timestamp' => date('Y-m-d H:i:s'),
    'method' => $_SERVER['REQUEST_METHOD'],
    'headers' => getallheaders(),
    'get_params' => $_GET,
    'post_params' => $_POST,
    'raw_input' => file_get_contents('php://input'),
    'files' => $_FILES,
    'server' => [
        'remote_addr' => $_SERVER['REMOTE_ADDR'],
        'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? null
    ]
];

file_put_contents('debug_log.txt', print_r($log, true), FILE_APPEND);

echo json_encode([
    'success' => true,
    'received_data' => $log,
    'message' => 'Debug information captured'
]);
?>