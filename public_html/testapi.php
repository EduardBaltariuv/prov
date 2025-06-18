<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

try {
    $data = [
        'post' => $_POST,
        'files' => $_FILES,
        'json' => json_decode(file_get_contents('php://input'), true)
    ];
    
    echo json_encode([
        'success' => true,
        'data' => $data
    ]);
    
} catch (Throwable $e) {
    echo json_encode([
        'success' => false,
        'error' => $e->getMessage()
    ]);
}