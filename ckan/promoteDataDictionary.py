#3> <> prov:specializationOf 
#3>    <https://github.com/jimmccusker/twc-healthdata/blob/master/ckan/promoteDataDictionary.py> .

import os, json

import ckanclient  # see https://github.com/okfn/ckanclient README
# Get latest download URL from http://pypi.python.org/pypi/ckanclient#downloads --\/
# sudo easy_install http://pypi.python.org/packages/source/c/ckanclient/ckanclient-0.10.tar.gz

# See also https://github.com/timrdf/DataFAQs/wiki/CKAN
#    section "Automatically publish dataset on CKAN"

#source = 'http://hub.healthdata.gov/api'
target = 'http://healthdata.tw.rpi.edu/hub/api'

MIRROR = False            # Modify target CKAN with listings from source CKAN.
UPDATE = MIRROR and False # If a dataset already exists in target, update it.

                          #sourceCKAN = ckanclient.CkanClient(base_location=target)
api_key = os.environ['X_CKAN_API_Key'] # api_key must be defined to POST/PUT.
print api_key
ckan = ckanclient.CkanClient(base_location=target, api_key=api_key)

indent = '    '
for name in ckan.package_register_get():
   print name
   ckan.package_entity_get(name) # Get the dataset description.
   dataset = ckan.last_message
   resources = dict([(r['name'],r) for r in dataset['resources']])
   
   if "Data Dictionary" not in resources and "Data Dictionary" in dataset['extras']:
      print "datadict"
      ddURL = dataset['extras']['Data Dictionary']
      ddFormat = ddURL.split(".")[-1]
      if len(ddFormat) > 5:
         ddFormat = None
         ckan.add_package_resource(name, ddURL,name='Data Dictionary',
                                   resource_type='metadata', format=ddFormat)
   if "Technical Documentation" not in resources and "Technical Documentation" in dataset['extras']:
      print "techdoc"
      tdURL = dataset['extras']['Technical Documentation']
      tdFormat = ddURL.split(".")[-1]
      if len(tdFormat) > 5:
         tdFormat = None
      ckan.add_package_resource(name, ddURL, name='Technical Documentation',
                                resource_type='metadata', format=ddFormat)


