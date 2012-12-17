#!/usr/bin/env python
#
# Requires: http://pypi.python.org/pypi/googlemaps
# easy_install http://pypi.python.org/packages/source/g/googlemaps/googlemaps-1.0.2.tar.gz

from googlemaps import GoogleMaps
import os, json
from datetime import *
import csv, sys, urllib, os, collections
endpoint = "http://healthdata.tw.rpi.edu/sparql"

def sparqlSelect(query, endpoint=endpoint):

   data = [l for l in csv.reader(urllib.urlopen(url),delimiter=',')]
   header = data[0]
   result = [dict([(header[i],l[i])
                   for i in range(min(len(header),len(l)))])
                   for l in data[1:]]
   return result

query = '''prefix vcard: <http://www.w3.org/2006/vcard/ns#>
prefix wgs:  <http://www.w3.org/2003/01/geo/wgs84_pos#>

select distinct ?address ?streetAddress ?streetAddress2 ?locality ?region ?postalCode ?country where {
  ?address a vcard:Address.
  OPTIONAL { ?address vcard:street-address   ?streetAddress }
  OPTIONAL { ?address vcard:extended-address ?streetAddress2 }
  OPTIONAL { ?address vcard:locality         ?locality }
  OPTIONAL { ?address vcard:region           ?region }
  OPTIONAL { ?address vcard:postal-code      ?postalCode }
  OPTIONAL { ?address vcard:country-name     ?country }

  OPTIONAL { ?address wgs:latitude ?lat; wgs:longitude ?long }
  FILTER (!bound(?lat) && !bound(?long))
} limit 100'''

outputTemplate = '<{uri}> wgs:latitude {lat} ; wgs:longitude {lng} .\n'

def retrieve():
    
    api_key = os.environ['X_GOOGLE_MAPS_API_Key'] # api_key must be defined to POST/PUT.
    gmaps = GoogleMaps(api_key)
    
    try:
        os.makedirs(str(date.today())+"/automatic")
    except:
        pass
    filename = str(date.today())+"/automatic/address-coordinates.ttl"
    o = open(filename,"w")
    o.write('@prefix wgs: <http://www.w3.org/2003/01/geo/wgs84_pos#> .\n\n');    
    provenance = open(str(date.today())+"/automatic/address-coordinates.prov.ttl","w")
    provenance.write('''@prefix prov:          <http://www.w3.org/ns/prov#>.
@prefix foaf:          <http://xmlns.com/foaf/0.1/> .

<address-coordinates.ttl>
  prov:wasGeneratedBy [
    a prov:Activity, <https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/address-coordinates/version/retrieve.py>;

    prov:qualifiedAssociation [
      a prov:Association;
      prov:hadPlan <https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/address-coordinates/version/retrieve.py>;
    ]
    prov:used [
      prov:value """{sparql}""";
    ];
    prov:used <http://maps.googleapis.com/maps/api/geocode/>.

<https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/address-coordinates/version/retrieve.py> a prov:Plan;
  foaf:homepage <https://github.com/jimmccusker/twc-healthdata/blob/master/data/source/healthdata-tw-rpi-edu/address-coordinates/version/retrieve.py>.
'''.format(sparql=query));    
    
    endpointPrefix = endpoint+"?&format=text%2Fcsv&timeout=0&debug=on&"
    url = endpointPrefix+urllib.urlencode([("query",query)])
    header = None
    
    for line in csv.reader(urllib.urlopen(url),delimiter=","):
        if header == None:
            header = line
            continue
        addressURI = line[0]
        address = ", ".join([x for x in line[1:] if x != ""])
        lat, lng = gmaps.address_to_latlng(address)
        o.write(outputTemplate.format(uri=addressURI,lat=lat,lng=lng))
    
if __name__=='__main__':
    retrieve()
