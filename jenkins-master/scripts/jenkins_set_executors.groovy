import hudson.model.*;
import jenkins.model.*;

println "--> setting master executors"
Jenkins.instance.setNumExecutors(0)
