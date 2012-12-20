#!/usr/bin/env python
#levelMax=0&semanticTypes=&ontologiesToKeepInResult=1351&textToAnnotate=The data that is used by the Hospital Compare tool can be downloaded for public use. This functionality is primarily used by health policy researchers and the media. The data provided includes process of care, mortality, and readmission quality measures. The collection period for the measures is generally 12 months. However, some measures may be based upon fewer than 12 months. Generally, the Hospital Compare quality measures are refreshed the third month of each quarter&wholeWordOnly=true&mappingTypes=&withDefaultStopWords=true&isVirtualOntologyId=true

import sadi
from rdflib import *
import surf

from surf import *
from surf.query import select

import rdflib
import httplib
from urlparse import urlparse, urlunparse
import urllib
import urllib2

import json

# These are the namespaces we are using beyond those already available
# (see http://packages.python.org/SuRF/modules/namespace.html#registered-general-purpose-namespaces)
ns.register(annotator='http://purl.org/twc/health/vocab/annotator#')

api_key = os.environ['X_BIOPORTAL_API_Key'] # api_key must be defined to POST/PUT.

annotatorUrl = 'http://rest.bioontology.org/obs/annotator'

header = ['score', 'conceptID', 'prefLabel', 'uri', 'synonyms', 'semanticType', 'contextName', 'extras']

# The Service itself
class MeSHAnnotator(sadi.Service):

    # Service metadata.
    label                  = 'annotator'
    serviceDescriptionText = 'Annotates a labeled or described thing with subject headings from Medical Subject Headings (MeSH) using the NCBO Annotator.'
    comment                = 'It is useful to know what a thing is about.'
    serviceNameText        = 'annotator' # Convention: Match 'name' below.
    name                   = 'annotator' # This value determines the service URI relative to http://localhost:9090/
                                         # Convention: Use the name of this file for this value.
    def __init__(self): 
        sadi.Service.__init__(self)

    def getOrganization(self):
        result                      = self.Organization('http://tw.rpi.edu')
        result.mygrid_authoritative = True
        result.protegedc_creator    = 'mccusj@rpi.edu'
        result.save()
        return result

    def getInputClass(self):
        return ns.ANNOTATOR['DescribedThing']

    def getOutputClass(self):
        return ns.ANNOTATOR['AnnotatedThing']

    instanceQuery = '''
prefix dc: <http://purl.org/dc/terms/>
select distinct ?instance where {
    ?instance dc:description ?desc.
}
'''

    def getInstances(self, session, store, graph):
        InputClass = session.get_class(self.getInputClass())
        instances = [i for i in graph.query(self.instanceQuery)]
        return [InputClass(i[0]) for i in instances]

    def process(self, input, output):
        textToAnnotate = input.dcterms_description.first
        # Structure containing parameters
        params = {
            'longestOnly':'false',
            'wholeWordOnly':'true',
            'withContext':'true',
            'filterNumber':'true', 
            'stopWords':'',
            'withDefaultStopWords':'false', 
            'isStopWordsCaseSenstive':'false', 
            'minTermSize':'3', 
            'scored':'true',  
            'withSynonyms':'true', 
            'ontologiesToExpand':'',   
            'ontologiesToKeepInResult':'1351', #MeSH   
            'isVirtualOntologyId':'true', 
            'semanticTypes':'',  #T017,T047,T191&" #T999&"
            'levelMax':'0',
            'mappingTypes':'null', 
            'textToAnnotate':textToAnnotate.encode("utf-8"), 
            'format':'tabDelimited',  #Output formats (one of): xml, tabDelimited, text  
            'apikey':api_key,
        }
        submitUrl = annotatorUrl + '/submit'
        postData = urllib.urlencode(params)
        Concept = output.session.get_class(ns.SKOS['Concept'])
        try:
            fh = urllib2.urlopen(submitUrl, postData)
            result = fh.read().replace("\r","").split('\n')
            fh.close()
            result = [x.split('\t') for x in result if len(x) > 0]
            result = [dict([(header[i],x[i]) for i in range(len(x))]) for x in result]
            concepts = dict([(x['uri'],x) for x in result])
            for cURI in concepts:
                c = concepts[cURI]
                concept = Concept(c['uri'])
                concept.skos_prefLabel = c['prefLabel']
                concept.skos_altLabel.extend(c['synonyms'].split(" /// "))
                concept.dcterms_identifier = c['conceptID']
                concept.save()
                output.dcterms_subject.append(concept)
                #print json.dumps(concepts,sort_keys=True, indent=4)
        except urllib2.HTTPError, e:
            print >> sys.stderr, e
        output.save()

# Used when Twistd invokes this service b/c it is sitting in a deployed directory.
resource = MeSHAnnotator()

# Used when this service is manually invoked from the command line (for testing).
if __name__ == '__main__':
    mimeType = "application/rdf+xml"
    reader= open(sys.argv[1],"r")
    writer = open(sys.argv[2],"w")
    if len(sys.argv) > 3:
        mimeType = sys.argv[3]
    graph = resource.processGraph(reader,mimeType)
    writer.write(resource.serialize(graph,mimeType))
    
