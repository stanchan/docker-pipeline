import jenkins.model.*
import java.util.logging.Logger

def logger = Logger.getLogger("")
def installed = false
def initialized = false

String pluginList = new File("/var/lib/jenkins/plugins.txt").text
def plugins = pluginList.split("\\s?\\r?\\n")
logger.info("Plugin List: " + plugins)
def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()
def uc = instance.getUpdateCenter()
uc.updateAllSites()

plugins.each {
  logger.info("Checking " + it)
  if (!pm.getPlugin(it)) {
    logger.info("Looking at UpdateCenter for " + it)
    if (!initialized) {
      uc.updateAllSites()
      initialized = true
    }
    def plugin = uc.getPlugin(it)
    if (plugin) {
      logger.info("Installing " + it)
      plugin.deploy()
      installed = true
    }
  }
}

/* if (installed) {
  logger.info("Plugins installed, initializing a restart!")
  instance.save()
  instance.doSafeRestart()
} */