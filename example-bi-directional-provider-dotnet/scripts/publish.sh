#!/bin/bash

SUCCESS=true
if [ "${1}" != true ]; then
	SUCCESS=false
fi

OAS=$(cat example-bi-directional-provider-dotnet/swagger.json | base64)
REPORT=$(cat report.txt | base64)

echo "==> Uploading OAS to Pactflow"
curl \
  -X PUT \
  -H "Authorization: Bearer ${PACT_BROKER_TOKEN}" \
  -H "Content-Type: application/json" \
  "${PACT_BROKER_BASE_URL}/contracts/provider/pactflow-example-bi-directional-provider-dotnet/version/sfdfdfgdrwer" \
  -d '{
   "content": "'$OAS'",
   "contractType": "oas",
   "contentType": "application/yaml",
   "verificationResults": {
     "success": '$SUCCESS',
     "content": "'$REPORT'",
     "contentType": "text/plain",
     "verifier": "verifier"
   }
 }'