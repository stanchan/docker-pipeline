import io
import json

from base64 import b64decode
from jenkinsapi.jenkins import Jenkins
from jenkinsapi.credential import UsernamePasswordCredential, SSHKeyCredential

api = Jenkins("http://127.0.0.1:8080")
creds = api.credentials

with io.open("/var/lib/jenkins/credentials.json", "r", encoding="utf-8") as f:
    passwd_creds = json.load(f)

for key, value in passwd_creds.iteritems():
    desc = str(value["description"])
    if "encoded" in value and value["encoded"]:
        password = b64decode(str(value["password"]))
    else:
        password = str(value["password"])
    cred_dict = {
        "credential_id": str(key),
        "description": str(value["description"]),
        "userName": str(value["userName"]),
        "password": password
    }
    creds[desc] = UsernamePasswordCredential(cred_dict)

with io.open("/var/lib/jenkins/keys.json", "r", encoding="utf-8") as f:
    ssh_creds = json.load(f)

for key, value in ssh_creds.iteritems():
    desc = str(value["description"])
    if "encoded" in value and value["encoded"]:
        private_key = b64decode(str(value["private_key"]))
    else:
        private_key = str(value["private_key"])
    cred_dict = {
        "credential_id": str(key),
        "description": str(value["description"]),
        "userName": str(value["userName"]),
        "passphrase": str(value["passphrase"]),
        "private_key": private_key
    }
    creds[desc] = SSHKeyCredential(cred_dict)
