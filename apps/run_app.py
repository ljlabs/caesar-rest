#!/usr/bin/env python

from __future__ import print_function

############################################################
#              MODULE IMPORTS
############################################################
# - Standard modules
import os
import sys
import json
import time
import datetime
import numpy as np
import argparse

# - caesar_rest modules
import caesar_rest
from caesar_rest import __version__, __date__
from caesar_rest import logger
from caesar_rest.app import app 



#### GET SCRIPT ARGS ####
def str2bool(v):
	if v.lower() in ('yes', 'true', 't', 'y', '1'):
		return True
	elif v.lower() in ('no', 'false', 'f', 'n', '0'):
		return False
	else:
		raise argparse.ArgumentTypeError('Boolean value expected.')

###########################
##     ARGS
###########################
def get_args():
	"""This function parses and return arguments passed in"""
	parser = argparse.ArgumentParser(description="Parse args.")

	# - Specify cmd options
	parser.add_argument('-config','--config', dest='config', required=False, type=str, help='Configuration file') 
	
	args = parser.parse_args()	

	return args


##############
##   MAIN   ##
##############
def main():
	"""Main function"""

	#===========================
	#==   PARSE ARGS
	#===========================
	logger.info("Parsing cmd line arguments ...")
	try:
		args= get_args()
	except Exception as ex:
		logger.error("Failed to get and parse options (err=%s)",str(ex))
		return 1

	# - Input filelist
	configfile= args.config

	#===============================
	#==   CONFIGURE APP
	#===============================
	if configfile:
		logger.info("Configuring app options from file %s ..." % configfile)
		app.config.from_pyfile(configfile, silent=False)
	

	#===============================
	#==   RUN APP
	#===============================
	logger.info("Running app ...")
	app.run(debug=True)
	#app.run()


	return 0



###################
##   MAIN EXEC   ##
###################
if __name__ == "__main__":
	sys.exit(main())
