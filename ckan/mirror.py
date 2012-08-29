import os, json

import ckanclient  # see https://github.com/okfn/ckanclient README
# Get latest download URL from http://pypi.python.org/pypi/ckanclient#downloads --\/
# sudo easy_install http://pypi.python.org/packages/source/c/ckanclient/ckanclient-0.10.tar.gz

# See also https://github.com/timrdf/DataFAQs/wiki/CKAN
#    section "Automatically publish dataset on CKAN"

source = 'http://hub.healthdata.gov/api'
target = 'http://aquarius.tw.rpi.edu/projects/healthdata/api'

MIRROR = False            # Modify target CKAN with listings from source CKAN.
UPDATE = MIRROR and False # If a dataset already exists in target, update it.

sourceCKAN = ckanclient.CkanClient(base_location=source)
api_key = os.environ['X_CKAN_API_Key'] # api_key must be defined to POST/PUT.
targetCKAN = ckanclient.CkanClient(base_location=target, api_key=api_key)

indent = '    '
for name in sourceCKAN.package_register_get():
   
   if name == 'hospital-compare':

      sourceCKAN.package_entity_get(name) # Get the dataset description.
      dataset = sourceCKAN.last_message

      altID   = source.replace('/api','') + '/dataset/' + dataset['id']
      altName = source.replace('/api','') + '/dataset/' + dataset['name']
      dataset['extras']['prov_alternateOf'] = altName
      # Would like to assert two alternates, but their model is limiting.

      if MIRROR: del dataset['id'] # DELETING
      print name + ' ' + dataset['name']
      if 'download_url' in dataset:
         print indent + 'download_url: ' + dataset['download_url']
      if 'url' in dataset:
         print indent + 'url:          ' + dataset['url']
      for resource in dataset['resources']:
         if MIRROR: del resource['id'] # DELETING
         if 'url' in resource:
            print indent + 'resource:     ' + resource['url']
            print indent + 'format:       ' + resource['format']
            # Formats seen on healthdata.gov: 
            #    CSV Text XLS XML Feed Query API Widget RDF
      #print json.dumps(dataset,sort_keys=True, indent=4)
      if MIRROR:
         try: # See if dataset is listed in targetCKAN
            targetCKAN.package_entity_get(dataset['name'])
            if UPDATE: 
               # Update target's existing entry from source's
               targetCKAN.package_entity_put(dataset) 
            else:
               print ('NOTE: skipping ' + dataset['name'] + ' ' +
                     'b/c already listed at ' + target)

            #update = targetCKAN.last_message
            #update['notes'] = 'Updated.'
            #targetCKAN.package_entity_put(update)

         except ckanclient.CkanApiNotFoundError:
            # Dataset is not listed on this CKAN
            print 'INFO: adding ' + dataset['name'] + ' to ' + target
            try:
               targetCKAN.package_register_post(dataset) # POST
            except ckanclient.CkanApiConflictError:
               print ('WARNING: '+
                     'Conflict error when trying to POST ' + dataset['name'])

#new_dataset = {
# 'name':  'test-dataset-3',
# 'notes': 'automatic submission',
#}
