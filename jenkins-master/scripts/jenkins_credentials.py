from jenkinsapi.jenkins import Jenkins
from jenkinsapi.credential import UsernamePasswordCredential, SSHKeyCredential

api = Jenkins("http://127.0.0.1:8080")
# Get a list of all global credentials
creds = api.credentials
credentialsId = creds.credentials.keys()[0]

print("Credentials: {}".format(creds))

#import socket
#s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
#s.connect(("127.0.0.1",9001))
#s.send("CREDENTIALSID " + credentialsId)