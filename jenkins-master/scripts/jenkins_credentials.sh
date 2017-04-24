#!/bin/bash
curl -X POST '127.0.0.1:8080/credentials/store/system/domain/_/createCredentials' \
    --data-urlencode 'json={
        "": "0", 
        "credentials": {
            "scope": "GLOBAL", 
            "id": "", 
            "username": "jenkins", 
            "password": "jenkins", 
            "description": "jenkins-slave credentials", 
            "$class": "com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl"
        }
    }'

echo 'Jenkins username/password credentials created'