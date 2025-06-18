#!/bin/bash

echo "=== Testing Fixed API ==="
echo "Current time: $(date)"

# Test 1: Simple POST without files
echo -e "\n1. Testing API without images..."
curl -X POST \
  -F "action=createReport" \
  -F "title=Test Report" \
  -F "description=Testing API functionality" \
  -F "category=IT" \
  -F "location=Test Location" \
  -F "username=testuser" \
  http://localhost:8000/apireports.php

echo -e "\n\n2. Checking debug logs..."
tail -n 10 /home/vboxuser/Downloads/AplicatieAndroidProvidenta-main2/public_html/api_debug.log

echo -e "\n\n3. Testing with image upload..."
# Create a small test image
echo "Creating test image..."
echo "fake image data" > /tmp/test_image.jpg

curl -X POST \
  -F "action=createReport" \
  -F "title=Test Report with Image" \
  -F "description=Testing image upload" \
  -F "category=IT" \
  -F "location=Test Location" \
  -F "username=testuser" \
  -F "images[]=@/tmp/test_image.jpg" \
  http://localhost:8000/apireports.php

echo -e "\n\n4. Final debug log check..."
tail -n 20 /home/vboxuser/Downloads/AplicatieAndroidProvidenta-main2/public_html/api_debug.log
