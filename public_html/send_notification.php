<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// 1. Path to your service account JSON file
define('SERVICE_ACCOUNT_PATH', __DIR__ . '/firebase-service-account.json');

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $topic = $_POST['topic'] ?? '';
    $title = $_POST['title'] ?? '';
    $body = $_POST['body'] ?? '';

    if (empty($topic) || empty($title) || empty($body)) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
        exit;
    }

    try {
        // 2. Get OAuth2 access token
        $accessToken = getFirebaseAccessToken();
        
        // 3. Prepare HTTP v1 message
        $projectId = getProjectIdFromJson(SERVICE_ACCOUNT_PATH);
        $fcmUrl = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";
        
        $message = [
            'message' => [
                'topic' => $topic,
                'notification' => [
                    'title' => $title,
                    'body' => $body
                ],
                'android' => [
                    'priority' => 'HIGH'
                ]
            ]
        ];

        // 4. Send request
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => $fcmUrl,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json'
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_SSL_VERIFYPEER => false,
            CURLOPT_POSTFIELDS => json_encode($message)
        ]);
        
        $result = curl_exec($ch);
        $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($status !== 200) {
            throw new Exception("FCM error: $result");
        }

        echo json_encode(['success' => true, 'message' => 'Notification sent']);
    } catch (Exception $e) {
        http_response_code(500);
        echo json_encode(['success' => false, 'message' => $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Method not allowed']);
}

// Helper functions
function getFirebaseAccessToken() {
    $serviceAccount = json_decode(file_get_contents(SERVICE_ACCOUNT_PATH), true);
    $privateKey = $serviceAccount['private_key'];
    $clientEmail = $serviceAccount['client_email'];
    $tokenUrl = 'https://oauth2.googleapis.com/token';
    
    // Create JWT assertion
    $now = time();
    $jwtHeader = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
    $jwtClaimSet = base64_encode(json_encode([
        'iss' => $clientEmail,
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'aud' => $tokenUrl,
        'exp' => $now + 3600,
        'iat' => $now
    ]));
    $jwtData = "$jwtHeader.$jwtClaimSet";
    
    // Sign with private key
    openssl_sign($jwtData, $signature, $privateKey, 'sha256');
    $jwtSignature = base64_encode($signature);
    $jwt = "$jwtData.$jwtSignature";
    
    // Exchange for access token
    $response = file_get_contents($tokenUrl, false, stream_context_create([
        'http' => [
            'method' => 'POST',
            'header' => 'Content-Type: application/x-www-form-urlencoded',
            'content' => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt
            ])
        ]
    ]));
    
    $tokenData = json_decode($response, true);
    return $tokenData['access_token'];
}

function getProjectIdFromJson($path) {
    $json = json_decode(file_get_contents($path), true);
    return $json['project_id'];
}