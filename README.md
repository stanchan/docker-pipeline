# Pipeline Docker

Pipeline Delivery Framework.

This is a fully functional Jenkins server, based on the Long Term Support release
http://jenkins-ci.org/


<img src="http://jenkins-ci.org/sites/default/files/jenkins_logo.png"/>

# SSH Keys and Passwords
The keys/passwords used in this repo are for demo purposes only! You will need to change them for any real deployments. 

# Running on Docker

```
docker-compose up
```

# Usage

```
docker run -p 8080:8080 -p 50000:50000 jenkins
```

This will store the workspace in /var/lib/jenkins. All Jenkins data lives in there - including plugins and configuration.
You will probably want to make that a persistent volume (recommended):

```
docker run -p 8080:8080 -p 50000:50000 -v /your/home:/var/lib/jenkins jenkins
```

This will store the jenkins data in `/your/home` on the host.
Ensure that `/your/home` is accessible by the jenkins user in container (jenkins user - uid 998) or build the docker container with the `user` arg and apply the `-u some_other_user` parameter with `docker run`.


You can also use a volume container:

```
docker run --name myjenkins -p 8080:8080 -p 50000:50000 -v /var/lib/jenkins jenkins
```

Then myjenkins container has the volume (please do read about docker volume handling to find out more).

## Backing up data

If you bind mount in a volume - you can simply back up that directory
(which is jenkins_home) at any time.

This is highly recommended. Treat the jenkins_home directory as you would a database - in Docker you would generally put a database on a volume.

If your volume is inside a container - you can use ```docker cp $ID:/var/lib/jenkins``` command to extract the data, or other options to find where the volume data is.
Note that some symlinks on some OSes may be converted to copies (this can confuse jenkins with lastStableBuild links etc)

For more info check Docker docs section on [Managing data in containers](https://docs.docker.com/engine/tutorials/dockervolumes/)

# Setting the number of executors

You can specify and set the number of executors of your Jenkins master instance using a groovy script. By default its set to 2 executors, but you can extend the image and change it to your desired number of executors :

`jenkins_set_executors.groovy`
```
import jenkins.model.*
Jenkins.instance.setNumExecutors(5)
```

and `Dockerfile`

```
FROM jenkins
COPY scripts/jenkins_set_executors.groovy /var/lib/jenkins/init.groovy.d/jenkins_set_executors.groovy
```

# Attaching build executors

You can run builds on the master (out of the box) but if you want to attach build slave servers: make sure you map the port: ```-p 50000:50000``` - which will be used when you connect a slave agent.

# Passing JVM parameters

You might need to customize the JVM running Jenkins, typically to pass system properties or tweak heap memory settings. Use JAVA_OPTS environment 
variable for this purpose :

```
docker run --name myjenkins -p 8080:8080 -p 50000:50000 --env JAVA_OPTS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Dhudson.footerURL=http://mycompany.com" jenkins
```

# Configuring logging

Jenkins logging can be configured through a properties file and `java.util.logging.config.file` Java property.
For example:

```
mkdir data
cat > data/log.properties <<EOF
handlers=java.util.logging.ConsoleHandler
jenkins.level=FINEST
java.util.logging.ConsoleHandler.level=FINEST
EOF
docker run --name myjenkins -p 8080:8080 -p 50000:50000 --env JAVA_OPTS="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false -Djava.util.logging.config.file=/var/lib/jenkins/log.properties" -v `pwd`/data:/var/lib/jenkins jenkins
```

# Upgrading

All the data needed is in the /var/lib/jenkins directory - so depending on how you manage that - depends on how you upgrade. Generally - you can copy it out - and then "docker pull" the image again - and you will have the latest LTS - you can then start up with -v pointing to that data (/var/lib/jenkins) and everything will be as you left it.

As always - please ensure that you know how to drive docker - especially volume handling!

# Questions?

Jump on irc.freenode.net and the #jenkins room. Ask!
