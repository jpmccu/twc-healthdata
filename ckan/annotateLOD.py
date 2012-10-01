#3> <> prov:specializationOf 
#3>    <https://github.com/jimmccusker/twc-healthdata/blob/master/ckan/promoteDataDictionary.py> .

import os, json
import csv, sys, urllib, os, collections
import ckanclient  # see https://github.com/okfn/ckanclient README
# Get latest download URL from http://pypi.python.org/pypi/ckanclient#downloads --\/
# sudo easy_install http://pypi.python.org/packages/source/c/ckanclient/ckanclient-0.10.tar.gz

# See also https://github.com/timrdf/DataFAQs/wiki/CKAN
#    section "Automatically publish dataset on CKAN"

endpoint = "http://healthdata.tw.rpi.edu/sparql"

health = 'http://purl.org/twc/health/vocab/'

def getTypes(uri):
   return [x['type'] for x in
           sparqlSelect('select distinct ?type where {{ <{uri}> a ?type }}'.format(uri=uri))]

def getGraphs(ds):
   query = '''
prefix dcat:       <http://www.w3.org/ns/dcat#> 
prefix void:       <http://rdfs.org/ns/void#> 
prefix prov:       <http://www.w3.org/ns/prov#> 
prefix datafaqs:   <http://purl.org/twc/vocab/datafaqs#> 
prefix dcterms:       <http://purl.org/dc/terms/>

select distinct ?version ?exemplar ?layer ?dump
where {{
   <{dataset}> void:subset ?version.
   ?version void:subset ?layer.
   ?version void:dataDump ?dump.
   OPTIONAL {{ ?layer void:exampleResource ?exemplar. }}
   OPTIONAL {{
     ?layer void:subset ?sample.
     graph ?sample {{
       [] void:inDataset ?version
     }}
   }}
}}
'''.format(dataset=ds)
   graphs = sparqlSelect(query)
   for d in graphs:
      d['layerTypes'] = set(getTypes(d['layer']))
   return graphs

def sparqlSelect(query, endpoint=endpoint):
   endpointPrefix = endpoint+"?&format=text%2Fcsv&timeout=0&debug=on&"
   url = endpointPrefix+urllib.urlencode([("query",query)])
   data = [l for l in csv.reader(urllib.urlopen(url),delimiter=',')]
   header = data[0]
   result = [dict([(header[i],l[i])
                   for i in range(min(len(header),len(l)))])
                   for l in data[1:]]
   return result

ckanURI = 'http://healthdata.tw.rpi.edu/hub/api'
endpoint = 'http://healthdata.tw.rpi.edu/sparql'

api_key = os.environ['X_CKAN_API_Key'] # api_key must be defined to POST/PUT.
ckan = ckanclient.CkanClient(base_location=ckanURI, api_key=api_key)

datasets = sparqlSelect('''
prefix dcat:       <http://www.w3.org/ns/dcat#> 
prefix void:       <http://rdfs.org/ns/void#> 
prefix prov:       <http://www.w3.org/ns/prov#> 
prefix datafaqs:   <http://purl.org/twc/vocab/datafaqs#> 
prefix dcterms:       <http://purl.org/dc/terms/>

select distinct ?dataset ?ckanDataset ?identifier
where {
   ?dataset
      a void:Dataset, dcat:Dataset;
      prov:wasDerivedFrom ?distribution
   .

   ?distribution
      a dcat:Distribution
   .

   ?ckanDataset
      a dcat:Dataset, datafaqs:CKANDataset;
      dcat:distribution ?distribution;
      prov:wasAttributedTo <http://healthdata.tw.rpi.edu>;
      dcterms:identifier ?identifier
   .

}''')

def getRawDataset(graphs):
   raw = [g for g in graphs
          if 'http://purl.org/twc/vocab/conversion/EnhancedDataset' not in g['layerTypes']]
   if len(raw) > 0:
      return raw[0]
   else:
      return None

def getEnhancedDataset(graphs):
   raw = [g for g in graphs
          if 'http://purl.org/twc/vocab/conversion/EnhancedDataset' in g['layerTypes']]
   if len(raw) > 0:
      return raw[0]
   else:
      return None

indent = '    '
#print datasets
for d in datasets:
 if d['identifier'] == 'hospital-compare':
   name = d['identifier']
   dataset = d['dataset']
   print name, dataset
   graphs = getGraphs(dataset)
   print graphs
   ckan.package_entity_get(name) # Get the dataset description.
   ckanDataset = ckan.last_message
   resources = collections.defaultdict(dict)
   resources.update(dict([(r['name'],r) for r in ckanDataset['resources']]))

   resources['Abstract Dataset']['name'] = 'Abstract Dataset'
   resources['Abstract Dataset']['format'] = 'meta/void'
   resources['Abstract Dataset']['resource_type'] = 'metadata'
   resources['Abstract Dataset']['url'] = dataset

   rawDataset = getRawDataset(graphs)
   if rawDataset:
      resources['Naive Conversion Example']['name'] = "Naive Conversion Example"
      resources['Naive Conversion Example']['format'] = 'rdf'
      resources['Naive Conversion Example']['resource_type'] = 'example'
      resources['Naive Conversion Example']['url'] = rawDataset['exemplar']
   elif 'Naive Conversion Example' in resources:
      resources.pop('Naive Conversion Example')
   enhancedDataset = getEnhancedDataset(graphs)
   if enhancedDataset:
      resources['Enhanced Conversion Example']['name'] = "Enhanced Conversion Example"
      resources['Enhanced Conversion Example']['format'] = 'rdf'
      resources['Enhanced Conversion Example']['resource_type'] = 'example'
      resources['Enhanced Conversion Example']['url'] = enhancedDataset['exemplar']
   elif 'Enhanced Conversion Example' in resources:
      resources.pop('Enhanced Conversion Example')

   resources['SPARQL Endpoint']['name'] = "SPARQL Endpoint"
   resources['SPARQL Endpoint']['format'] = 'api/sparql'
   resources['SPARQL Endpoint']['resource_type'] = 'api'
   resources['SPARQL Endpoint']['url'] = endpoint
   
   ckanDataset['extras']['sparql_graph_name'] = graphs[0]['version']
   
   resources['Download']['name'] = "Download"
   resources['Download']['format'] = 'rdf'
   resources['Download']['resource_type'] = 'data file'
   resources['Download']['url'] = graphs[0]['dump']

   ckanDataset['resources'] = resources.values()
   ckan.package_entity_put(ckanDataset)

   #                  if x != None]
   #if len(sparqlEndpoint) > 0:
      
   # if "SPARQL endpoint" not in resources and "Data Dictionary" in dataset['extras']:
   #    print "datadict"
   #    ddURL = dataset['extras']['Data Dictionary']
   #    ddFormat = ddURL.split(".")[-1]
   #    if len(ddFormat) > 5:
   #       ddFormat = None
   #       ckan.add_package_resource(name, ddURL,name='Data Dictionary',
   #                                 resource_type='metadata', format=ddFormat)
   # if "Technical Documentation" not in resources and "Technical Documentation" in dataset['extras']:
   #    print "techdoc"
   #    tdURL = dataset['extras']['Technical Documentation']
   #    tdFormat = ddURL.split(".")[-1]
   #    if len(tdFormat) > 5:
   #       tdFormat = None
   #    ckan.add_package_resource(name, ddURL, name='Technical Documentation',
   #                              resource_type='metadata', format=ddFormat)


