import os
import re
import sys
import json
import urllib2
import base64

nodeDefaultVersion = 'node-v6.9.4-linux-x64.tar.xz'
nodeFileExts = ['.tar.xz', '.tar.gz']

def main():
	get_vcap_config()
	appinfo = get_application_info()
	# service = find_spring_config_service(appinfo)
	# if service != None:
	# 	get_spring_cloud_config(service, appinfo)

def detect():
	print 'detect called'
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)
	# print service
	if service == None:
		sys.exit(1)
	print 'edgemicro-config'
	sys.exit(0)

def compile():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)
	# print >> sys.stderr, "service-config:"
	# json.dump(service, sys.stderr, indent=4)
	# print >> sys.stderr
	if service == None:
		sys.exit(1)
	print '-o %s -e %s -u %s -p %s' % (service["credentials"]["org"], service["credentials"]["env"], service["credentials"]["user"], service["credentials"]["pass"])

def getOrgEnv():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)
	if service == None:
		sys.exit(1)
	print '-o %s -e %s' % (service["credentials"]["org"], service["credentials"]["env"])

def getEdgemicroVersion():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)
	if service == None:
		sys.exit(1)
	print '%s' % (service["credentials"]["edgemicro_version"])

def getEdgemicroPort():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)
	if service == None:
		sys.exit(1)
	print '%s' % (service["credentials"]["edgemicro_port"])

def getAppName():
	appinfo = get_application_info()
	# json.dump(appinfo, sys.stderr, indent=4)
	print appinfo['uris'][0].replace('.', '-')

# get Node.js version
# the default version is 6.9.4
#
def getNodejsVersion():
	creds = getEdgemicroServiceCredential()
	nodeVersion = creds.get('nodejs_version', nodeDefaultVersion)
	print nodeVersion


# return the Node.js folder name, which is the Node.js
# version with the file ext truncated.
#
def nodejsVersionFolderName():
	creds = getEdgemicroServiceCredential()
	nodeVersion = creds.get('nodejs_version', nodeDefaultVersion)
	folderName = ''
	for ext in nodeFileExts:
		if nodeVersion.endswith(ext.strip()):
			folderName = nodeVersion.replace(ext,'')
			break

	if folderName == '' :
		print 'Invalid Node.js file extension; expected: ' + ','.join(nodeFileExts)
		sys.exit(1)
	else:
		print folderName


# get the enable_custom_plugins property from the credentials object
#
def getEnableCustomPlugins():
	creds = getEdgemicroServiceCredential()
	enableCustomPlugins = creds.get('enable_custom_plugins','false')
	print enableCustomPlugins

# enableCustomPlugins
# this update the default.yaml with the plugins listed in the
# plugins property.
#
def enableCustomPlugins():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)

	if service == None:
		sys.exit(1)
	creds = service.get('credentials')
	enableCustomPlugins = creds.get('enable_custom_plugins','false')

	if enableCustomPlugins.lower() == 'true':
		pluginsString = creds.get('plugins', None)
		if pluginsString != None :
			edgemicroVersion = creds.get('edgemicro_version')
			plugins = pluginsString.split(',')
			pluginSequence = '\n'.join(map(appendNewLine, plugins)) #creates - plugin1\n - plugin2\n
			pluginSequence = '\n' + pluginSequence + '\n'
			enableSpikeArrest = creds.get('enable_spike_arrest','false')

			if enableSpikeArrest.lower() == 'true':
				search = 'oauth\n      - spikearrest'
				overridePluginSequenceForCustomPlugins(pluginSequence, edgemicroVersion, search)
			else:
				search = 'oauth'
				overridePluginSequenceForCustomPlugins(pluginSequence, edgemicroVersion, search)

			print 'Plugin sequence is: ' + pluginSequence
		else:
			print 'plugins property is missing from credentials object.'
			sys.exit(1)

def appendNewLine(plugin):
	return '      - ' + plugin

# helper function calls overridePluginSequence twice to update both the default.yaml.
# and the org-env-config.yaml file, which are located in the .edgemicro directory
# within the container.
# @pluginSequence - the new plugin sequence as a string
# @edgemicroversion - edgemicro version number
# @search - the search paramter for the reqular expression
#
def overridePluginSequenceForCustomPlugins(pluginSequence, edgemicroVersion, search):
	homepath = '/home/vcap/'
	yamlfile = os.path.join(homepath,'.edgemicro','default.yaml')
	overridePluginSequence(pluginSequence, edgemicroVersion, search, yamlfile)
	creds = getEdgemicroServiceCredential()
	yamlfile = 	os.path.join(homepath,'.edgemicro',creds.get('org') + '-' + creds.get('env') + '-config.yaml')
	overridePluginSequence(pluginSequence, edgemicroVersion, search, yamlfile)

# override the plugin sequence
# this function replaces the plugins: sequence: section with what is passed
# into the plugins parameter.
# @pluginSequence - the new plugin sequence as a string
# @edgemicroversion - edgemicro version number
# @search - the search paramter for the reqular expression
# @yamfile - the yaml file that needs to be updated
#
def overridePluginSequence(pluginSequence, edgemicroVersion, search, yamlfile):
	pluginsSection = "  plugins:\n    sequence:\n"
	sequenceToUpdate = re.compile(r"""\s.*- """ + search + """\n""")
	buildpath = os.environ['BUILD_DIR']
	#correctly updates the file, however, edgemicro does not pick up the changes when configure runs
	#updateFile(plugins, sequence, os.path.join(buildpath,'apigee_edge_micro','microgateway-' + edgemicroVersion,'config','default.yaml'))
	#update the default.yaml in the .edgemicro directory
	updateFile(pluginSequence, sequenceToUpdate, yamlfile)
	#update in the .edgemicro/org-env-config.yaml file as well
	#updateFile(plugins, sequence, os.path.join('/home/vcap/','.edgemicro',creds.get('org') + '-' + creds.get('env') + '-cache-config.yaml'))

def updateFile(pluginSequence, sequenceToUpdate, yamlfile):
	data = file(yamlfile,'r').read()
	data = sequenceToUpdate.sub(pluginSequence, data)
	#print 'updated data is: ' + data
	file(yamlfile,'w').write(data)

# get the onpremises property from the credentails object
#
def getOnpremises():
	creds = getEdgemicroServiceCredential()
	isOnpremises = creds.get('onpremises','false')
	print isOnpremises

# get the onpremises config object
#
def getOnpremisesConfig():
	creds = getEdgemicroServiceCredential()
	onpremisesConfig = creds.get('onprem_config', None)
	if onpremisesConfig == None:
		print 'Missing onpremises_config object.'
		sys.exit(1)

	print '-o %s -e %s -u %s -p %s -r %s -m %s -v %s' % \
		(creds["org"], creds["env"], \
		creds["user"], creds["pass"], \
		onpremisesConfig["runtime_url"], \
		onpremisesConfig["mgmt_url"], \
		onpremisesConfig["virtual_host"])

# get edgemicro service object
# if the credentials object exist then continue
# otherwise exit immediately
#
def getEdgemicroServiceCredential():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)
	if service == None:
		print 'Missing Edgemicro service object.'
		sys.exit(1)

	creds = service.get('credentials')

	if creds == None:
		print 'Missing the Edgemicro credentials service object.'
		sys.exit(1)

	return creds

# Update the default.yaml file to include the spike arrest
# if the credentails object contains enable_spike_arrest : true
# then continue otherwise exit.
#
def enableSpikeArrest():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)

	if service == None:
		sys.exit(1)
	creds = service.get('credentials')
	enableSpikeArrest = creds.get('enable_spike_arrest','false')

	if enableSpikeArrest.lower() == 'true':
		spikeConfig = getSpikeArrestConfig(creds)
		if spikeConfig != None :
			edgemicroVersion = creds.get('edgemicro_version')
			spikeArrestConfig = '\nspikearrest:\n' + \
				'  timeUnit: ' + spikeConfig.get('timeunit', 'minute') + \
				'\n' + '  allow: ' + spikeConfig.get('allow', '30') + '\n'
			buffersize = spikeConfig.get('buffersize')
			if buffersize is not None:
				spikeArrestConfig = spikeArrestConfig + '  buffersize: ' + buffersize + '\n'
			buildpath = os.environ['BUILD_DIR']
			yamlfile = os.path.join(buildpath,'apigee_edge_micro','microgateway-' + edgemicroVersion,'config','default.yaml')
			fh = open(yamlfile, 'a')
			fh.write(spikeArrestConfig)
			addPluginToPluginsSequence('      - spikearrest\n', edgemicroVersion)
			print 'Spike Arrest is enabled: ' + spikeArrestConfig


# Get the spike arrest config from the credential object
#
def getSpikeArrestConfig(credential):
	spikeConfig = credential.get('spike_arrest_config')
	if spikeConfig is None:
		return None
	return spikeConfig

# add the plugin to the sequence
#
def addPluginToPluginsSequence(plugin, edgemicroVersion):
	pluginsSection = "  plugins:\n    sequence:\n"
	sequence = re.compile(r"""  plugins:\n    sequence:\n(      - .*\n)""")
	buildpath = os.environ['BUILD_DIR']
	yamlfile = os.path.join(buildpath,'apigee_edge_micro','microgateway-' + edgemicroVersion,'config','default.yaml')
	data = file(yamlfile,'r').read()
	#update the first group in this case it should be - oauth
	# result is - oauth\n - spikearrest
	#data = sequence.sub(r'\g<1>' + pluginsSection + plugin, data)
	data = sequence.sub(pluginsSection + r'\g<1>' + plugin, data)
	file(yamlfile,'w').write(data)

def updateSpikeArrest():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)
	if service == None:
		sys.exit(1)
	creds = service.get("credentials")
	updateMicroConfig(creds.get("timeunit", "minute"), creds.get("allow", "30"))

# retreive the yaml_included property from the service.
#
def yamlIncluded():
	creds = getEdgemicroServiceCredential()
	print creds.get('yaml_included','false').lower()

# retrieve the yaml name
#
def yamlName():
	creds = getEdgemicroServiceCredential()
	filename = creds.get('yaml_name', None)
	if filename == None or filename == '':
		print 'yaml_name property is not defined in the edgemicro service'
		sys.exit(1)

	print creds.get('yaml_name')


# Update the default.yaml file to include the quota.
# if the credentails object contains enable_quota : true
# then continue otherwise exit.
#
def enableQuota():
	appinfo = get_application_info()
	service = find_edgemicro_service(appinfo)

	if service == None:
		sys.exit(1)
	creds = service.get('credentials')
	enableQuota = creds.get('enable_quota','false')

	if enableQuota.lower() == 'true':
		edgemicroVersion = creds.get('edgemicro_version')
		buildpath = os.environ['BUILD_DIR']
		yamlfile = os.path.join(buildpath,'apigee_edge_micro','microgateway-' + edgemicroVersion,'config','default.yaml')
		enableSpikeArrest = creds.get('enable_spike_arrest','false')

		if enableSpikeArrest.lower() == 'true':
			newSequence = '\n      - spikearrest\n      - quota'
			overridePluginSequence(newSequence, edgemicroVersion, 'spikearrest', yamlfile)
		else:
			newSequence = '\n      - oauth\n      - quota\n'
			overridePluginSequence(newSequence, edgemicroVersion, 'oauth', yamlfile)

		print 'Quota is enabled.'
	else:
		print 'Quota is not enabled.'
		sys.exit(1)



def updateMicroConfig(timeunit, allow):
	timeunitPattern = re.compile(r"""(timeUnit: )(\w+)""", re.MULTILINE)
	allowPattern = re.compile(r"""(allow: )(\w+)""", re.MULTILINE)
	buildpath = os.environ['BUILD_DIR']
	yamlfile = os.path.join(buildpath,'apigee_edge_micro','microgateway-2.3.1','config','default.yaml')
	data = file(yamlfile,'r').read()
	data = timeunitPattern.sub(r'\g<1>' + timeunit, data)
	data = allowPattern.sub(r'\g<1>' + allow, data)
	file(yamlfile,'w').write(data)


vcap_config = None
log_level = 1

def get_vcap_config():
	global vcap_config
	global log_level
	vcap_config = json.loads(os.getenv('VCAPX_CONFIG', '{}'))
	log_level = vcap_config.get('loglevel', 1)

# Get Application Info
#
# Certain information about the application is used in
# the query to the configuration servers, to allow them
# to return config values dependent on the application
# instance deployment
#
def get_application_info():
	appinfo = {}
	vcap_application = json.loads(os.getenv('VCAP_APPLICATION', '{}'))
	appinfo['name'] = vcap_application.get('application_name')
	if appinfo['name'] == None:
		print >> sys.stderr, "VCAP_APPLICATION must specify application_name"
		sys.exit(1)
	appinfo['profile'] = vcap_application.get('space_name', 'default')
	appinfo['uris'] = vcap_application.get('uris')
	return appinfo

# Find bound configuration service
#
# We only read configuration from bound config services that
# are appropriately tagged. And since, for user-provided services,
# tags can only be set inside the credentials dict, not in the
# top-level one, we check for tags in both places.
#
def find_edgemicro_service(appinfo):
	vcap_services = json.loads(os.getenv('VCAP_SERVICES', '{}'))
	for service in vcap_services:
		service_instances = vcap_services[service]
		for instance in service_instances:
			tags = instance.get('tags', []) + instance.get('credentials',{}).get('tags',[])
			if 'edgemicro' in tags:
				return instance
	return None

def get_access_token(credentials):
	client_id = credentials.get('client_id','')
	client_secret = credentials.get('client_secret','')
	access_token_uri = credentials.get('access_token_uri')
	if access_token_uri is None:
		return None
	req = urllib2.Request(access_token_uri)
	req.add_header('Authorization', 'Basic ' + base64.b64encode(client_id + ":" + client_secret))
	body = "grant_type=client_credentials"
	response = json.load(urllib2.urlopen(req, data=body))
	access_token = response.get('access_token')
	token_type = response.get('token_type')
	return token_type + " " + access_token

def get_spring_cloud_config(service, appinfo):
	if log_level > 1:
		print >> sys.stderr, "spring-cloud-config:"
		json.dump(service, sys.stderr, indent=4)
		print >> sys.stderr
	credentials = service.get('credentials', {})
	access_token = get_access_token(credentials)
	uri = credentials.get('uri')
	if uri is None:
		print >> sys.stderr, "services of type spring-config-server must specify a uri"
		return
	uri += "/" + appinfo['name']
	uri += "/" + appinfo['profile']
	try:
		if log_level > 1:
			print >> sys.stderr, "GET", uri
		req = urllib2.Request(uri)
		if access_token is not None:
			req.add_header('Authorization', access_token)
		config = json.load(urllib2.urlopen(req))
	except urllib2.URLError as err:
		print >> sys.stderr, err
		return
	if log_level > 1:
		json.dump(config, sys.stderr, indent=4)
		print >> sys.stderr
	save_config_properties(service, config)

def save_config_properties(service, config):
	#
	# Targets are configurable through VCAPX_CONFIG
	# Provided defaults direct properties to various places
	# based on simple pattern matching.
	#
	default_target = 'env'
	default_targets = [
		{
			'filter': '[0-9A-Z_]+$',
			'target': 'env',
		},
		{
			'filter': '([a-z0-9]+\\.)+[a-z0-9]+$',
			'target': 'file:config-server.properties',
			'format': 'properties',
		},
		{
			'filter': '[a-z0-9]+$',
			'target': 'file:config-server.yml',
			'format': 'yml',
		}
	]
	targets = vcap_config.get('targets', default_targets)
	#
	# Iterate through the properties and stick them in dicts for all
	# the targets that match the property.
	#
	# We iterate through the properties in reversed order, as it looks like
	# the Spring Cloud Config Server always returns the most specific context
	# first. So this order leads to the correct merge result if the same
	# property appears in multiple contexts.
	#
	for sources in reversed(config.get('propertySources', [])):
		for key, value in sources.get('source', {}).items():
			used = False
			for target in targets:
				match = re.match(target.get('filter', '.*'), key)
				if match is not None:
					used = True
					target['target'] = target.get('target', 'stderr')
					target['properties'] = target.get('properties', {})
					target['properties'][key] = value
					if log_level > 1:
						print >> sys.stderr, key, "->", target['target']
			if not used and log_level > 0:
				print >> sys.stderr, "Property", key, "was ignored because it did not match any target"
	#
	# Now iterate through the dicts and save the properties in the proper places
	#
	for target in targets:
		properties = target.get('properties', {}).items()
		if len(properties) < 1:
			continue
		destination = target.get('target', 'stderr')
		if destination == 'env':
			for key, value in properties:
				add_environment_variable(key, value)
		elif destination == 'stderr':
			write_property_file(sys.stderr, properties, target.get('format', 'text'))
		elif destination == 'stdout':
			write_property_file(sys.stdout, properties, target.get('format', 'text'))
		elif destination.startswith('file:'):
			filename = destination[5:]
			parts = filename.rsplit('.', 1)
			format = target.get('format', parts[1] if len(parts) > 1 else 'properties')
			with open(filename, 'wb') as property_file:
				write_property_file(property_file, properties, format)
		else:
			print >> sys.stderr, "Illegal target type", destination, "in VCAPX_CONFIG"
	#
	# And update VCAP_CONFIG to reflect downloaded properties
	#
	vcap_config['targets'] = targets
	add_environment_variable('VCAP_CONFIG', json.dumps(vcap_config))

def write_property_file(file, properties, format):
	if format == 'json':
		json.dump(properties, file, indent=4)
	elif format == 'yml':
		print >> file, '---'
		for key, value in properties:
			print >> file, key, value
	elif format in [ 'properties', 'text' ]:
		for key, value in properties:
			print >> file, key + '=' + value
	else:
		print >> sys.stderr, "Illegal format", format, "in VCAPX_CONFIG"

def add_environment_variable(key, value):
	#
	# There's no point sticking the property into our own environment
	# since we are a child of the process we want to affect. So instead,
	# for environment variables, we depend on our caller to set and
	# export the real environment variables. We simply place them on our
	# stdout for the caller to consume.
	#
	print key, value

if __name__ == "__main__":
	main()
