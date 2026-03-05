#!/bin/bash

dotnet example-bi-directional-provider-dotnet/bin/Release/net10.0/example-bi-directional-provider-dotnet.dll &
API_PID=$!


echo "Started dotnet API with process ID: $API_PID"

echo "Waiting for API to be ready..."
for i in $(seq 1 30); do
    if curl -s http://localhost:9000/swagger/v1/swagger.json > /dev/null 2>&1; then
        echo "API is ready"
        break
    fi
    sleep 1
done

echo "Running schemathesis test to generate report"
# On Linux (CI), --net=host shares the host network namespace so 'localhost' reaches the host.
# On macOS, Docker Desktop containers run in a VM and need 'host.docker.internal' to reach the host.
if [[ "$(uname)" == "Linux" ]]; then
    SCHEMATHESIS_API_HOST="localhost"
else
    SCHEMATHESIS_API_HOST="host.docker.internal"
fi
docker run --net="host" schemathesis/schemathesis:stable run --checks all http://${SCHEMATHESIS_API_HOST}:9000/swagger/v1/swagger.json > report.txt

echo "Stopping dotnet API"
kill -9 $API_PID
