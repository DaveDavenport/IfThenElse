#!/usr/bin/env python

#this script was obtained from http://blog.yjl.im/2010/08/using-python-to-get-google-reader.html
# Changed to load the username/password from file.

import os
from xml.dom import minidom
from xml.dom import EMPTY_NAMESPACE
try:
  import json
except ImportError:
  import simplejson as json
import urllib
import urllib2

import ConfigParser

config = ConfigParser.ConfigParser();
config.sections()
config.read(os.getenv("HOME")+"/.google-reader.config");

username = config.get("Google Reader", "username");
password = config.get("Google Reader", "password");

#username = 'username@gmail.com'
#password = 'password'

# Authenticate to obtain Auth
auth_url = 'https://www.google.com/accounts/ClientLogin'
auth_req_data = urllib.urlencode({
    'Email': username,
    'Passwd': password,
    'service': 'reader'
    })
auth_req = urllib2.Request(auth_url, data=auth_req_data)
auth_resp = urllib2.urlopen(auth_req)
auth_resp_content = auth_resp.read()
auth_resp_dict = dict(x.split('=') for x in auth_resp_content.split('\n') if x)
AUTH = auth_resp_dict["Auth"]

# Create a cookie in the header using the Auth
header = {'Authorization': 'GoogleLogin auth=%s' % AUTH}

####################################
### PART 1: Getting unread count ###
####################################

reader_base_url = 'http://www.google.com/reader/api/0/unread-count?%s'
reader_req_data = urllib.urlencode({ 'all': 'true', 'output': 'json'})

reader_url = reader_base_url % (reader_req_data)
reader_req = urllib2.Request(reader_url, None, header)
reader_resp = urllib2.urlopen(reader_req)
#reader_resp_content = reader_resp.read()
#j = json.loads(reader_resp_content)
j = json.load(reader_resp)
count = ([c['count'] for c in j['unreadcounts'] if c['id'].endswith('/state/com.google/reading-list')] or [0])[0]

print count
#if count:
#  print 'Unread: %d' % count
#else:
#  print 'No unread items.'

###################################
### PART 2: Getting unread list ###
###################################

#if count:
#  ATOM_NS = 'http://www.w3.org/2005/Atom'

#  reader_base_url = r'http://www.google.com/reader/atom/user%2F-%2Fstate%2Fcom.google%2freading-list?n=50'
#  reader_url = reader_base_url
#  reader_req = urllib2.Request(reader_url, None, header)
#  reader_resp = urllib2.urlopen(reader_req)
#  doc = minidom.parse(reader_resp)
#  doc.normalize()
#
#  for entry in doc.getElementsByTagNameNS(ATOM_NS, u'entry'):
#    title = entry.getElementsByTagNameNS(ATOM_NS, u'title')[0].firstChild.data
#    if [True for cat in entry.getElementsByTagNameNS(ATOM_NS, u'category') if cat.getAttributeNS(EMPTY_NAMESPACE, u'term').endswith('/state/com.google/read')]:
#      continue
#    print title
