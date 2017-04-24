import io
import os
import json
import jenkins

j = jenkins.Jenkins("http://127.0.0.1:8080")

with io.open("/jobs/jobs.json", "r", encoding="utf-8") as f:
    nodes = json.load(f)

for key, data in nodes.iteritems():
    if os.path.isfile(data["file"]):
        with io.open(data["file"], "r", encoding="utf-8") as c:
            config = c.read()
        print("Adding Jenkins Job: {}".format(key))
        j.create_job(key, config)
    else:
        print("File not found! ({})".format(data["file"]))
