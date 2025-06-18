<?php
// Debug script to test image uploads
header('Content-Type: text/plain');

echo "=== PHP UPLOAD CONFIGURATION DEBUG ===\n";
echo "upload_max_filesize: " . ini_get('upload_max_filesize') . "\n";
echo "post_max_size: " . ini_get('post_max_size') . "\n";
echo "max_file_uploads: " . ini_get('max_file_uploads') . "\n";
echo "file_uploads: " . (ini_get('file_uploads') ? 'ON' : 'OFF') . "\n";
echo "upload_tmp_dir: " . ini_get('upload_tmp_dir') . "\n";
echo "memory_limit: " . ini_get('memory_limit') . "\n";

echo "\n=== DIRECTORY PERMISSIONS ===\n";
$uploadDir = '/home/u842828699/domains/darkcyan-clam-483701.hostingersite.com/public_html/uploads/';
echo "Upload directory: " . $uploadDir . "\n";
echo "Directory exists: " . (is_dir($uploadDir) ? 'YES' : 'NO') . "\n";
if (is_dir($uploadDir)) {
    echo "Directory readable: " . (is_readable($uploadDir) ? 'YES' : 'NO') . "\n";
    echo "Directory writable: " . (is_writable($uploadDir) ? 'YES' : 'NO') . "\n";
    echo "Directory permissions: " . substr(sprintf('%o', fileperms($uploadDir)), -4) . "\n";
}

echo "\n=== POST DATA ===\n";
print_r($_POST);

echo "\n=== FILES DATA ===\n";
print_r($_FILES);

echo "\n=== TEST COMPLETE ===\n";
?>
