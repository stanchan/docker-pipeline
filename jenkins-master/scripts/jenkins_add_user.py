import json
import requests

def main():
    data = {
        "credentials": {
            "scope": "GLOBAL",
            "username": "jenkins",
            "privateKeySource": {
                "privateKey": "-----BEGIN RSA PRIVATE KEY-----\nX\n-----END RSA PRIVATE KEY-----",
                "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey$DirectEntryPrivateKeySource"
            },
            "stapler-class": "com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey"
        }
    }

    payload = {
        "json": json.dumps(data),
        "Submit": "OK",
    }
    r = requests.post("http://%s:%d/credential-store/domain/_/createCredentials" % ("127.0.0.", 8080), data=payload)
    if r.status_code != requests.codes.ok:
        print r.text