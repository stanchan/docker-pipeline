import jenkins.model.*
import java.util.logging.Logger

def logger = Logger.getLogger("")
def installed = false
def initialized = false

String pluginList = new File('/var/lib/jenkins/remove_plugins.txt').text
def plugins = pluginList.split()
logger.info("" + plugins)
def instance = Jenkins.getInstance()
def pm = instance.getPluginManager()

plugins.each {
  logger.info("Checking " + it)
  def actPlugin = pm.getPlugin(it)
  if (!actPlugin) {
    logger.info("Plugin not found " + it)
  } else {
    actPlugin.disable()
  }
}
