import io
import os
import json
import subprocess

jdk_path = os.environ['JAVA_HOME']
certs_path = os.environ['CERTS_HOME']
json_file = "{}/certs.json".format(certs_path)
key_tool = "{}/bin/keytool".format(jdk_path)
key_store = "{}/jre/lib/security/cacerts".format(jdk_path)

if os.path.isfile(json_file):
    with io.open(json_file, "r", encoding="utf-8") as f:
        certs = json.load(f)
    for key, data in certs.iteritems():
        if os.path.isfile(data["file"]):
            print("Add {} cert to {}...".format(key, key_store))
            subprocess.call([key_tool, "-trustcacerts", "-keystore", key_store, "-storepass", "changeit",
                "-noprompt", "-importcert", "-alias", key, "-file", data["file"]])
else:
    print("No certs in {} to add to JDK".format(certs_path))
