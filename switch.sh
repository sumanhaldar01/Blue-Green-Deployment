#!/bin/bash

# 1. Check if green container is running
if docker ps | grep green_app > /dev/null; then
    echo "Green container running"
else
    echo "Green not running. Abort."
    exit 1
fi

# 2. 🔥 Health check (THIS is where it belongs)
echo "Checking health of GREEN..."
if curl -f http://localhost:3002/health > /dev/null; then
    echo "Green is healthy"
else
    echo "Green is NOT healthy. Abort switch."
    exit 1
fi

# 3. Detect current active backend
CURRENT=$(docker exec nginx grep 'server' /etc/nginx/nginx.conf | head -1)

# 4. Switch traffic
if [[ $CURRENT == *"blue"* ]]; then
    echo "Switching BLUE → GREEN"
    sed -i 's/server blue:3000;/server green:3000;/' nginx.conf
else
    echo "Switching GREEN → BLUE"
    sed -i 's/server green:3000;/server blue:3000;/' nginx.conf
fi

# 5. Reload nginx (zero downtime)
docker exec nginx nginx -s reload

echo "Traffic switched successfully 🚀"