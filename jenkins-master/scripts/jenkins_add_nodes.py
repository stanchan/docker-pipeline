import io
import json
import jenkins

j = jenkins.Jenkins("http://127.0.0.1:8080")

with io.open("/files/nodes.json", "r", encoding="utf-8") as f:
    nodes = json.load(f)

for key, data in nodes.iteritems():
    params = {
        "port": data["port"],
        "username": data["username"],
        "credentialsId": data["credid"],
        "host": key
    }
    create = True
    for node in j.get_nodes():
        if node["name"] == key:
            create = False
    if create:
        print("Creating Jenkins Slave Node: {}".format(key))
        j.create_node(
            key,
            nodeDescription=data["description"],
            remoteFS=data["remotefs"],
            labels=data["labels"],
            launcher=jenkins.LAUNCHER_SSH,
            launcher_params=params
        )
