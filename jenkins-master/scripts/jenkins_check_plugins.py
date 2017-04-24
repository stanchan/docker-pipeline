import jenkins
import time
import jenkins_plugins_list

plugins = jenkins_plugins_list.plugins("/var/lib/jenkins/plugins.txt")

# cf: https://updates.jenkins-ci.org/download/plugins/

j = jenkins.Jenkins("http://127.0.0.1:8080")
while True:
    info = j.get_plugins()
    installed_plugins = []
    for key in info.keys():
        installed_plugins.append(key[0])
    break

#print("Desired plugins: {}".format(", ".join(set(plugins))))
#print("Installed plugins: {}".format(", ".join(set(installed_plugins))))
print("Remaining plugins: {}".format(", ".join(set(plugins) - set(installed_plugins))))
if len(set(plugins) - set(installed_plugins)) == 0:
    print("OK")
else:
    print("WAIT")