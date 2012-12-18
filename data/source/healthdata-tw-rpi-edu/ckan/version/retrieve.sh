#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3> 
#3> <#>
#3>    a doap:Project; 
#3>    dcterms:description 
#3>      "Script to retrieve RDF from CKAN datasets loaded into the SPARQL endpoint.";
#3>    rdfs:seeAlso 
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>;
#3>    prov:wasDerivedFrom <https://github.com/jimmccusker/twc-healthdata/blob/master/data/source/hub-healthdata-gov/ckan/version/retrieve.sh>;
#3> .

today=`date +%Y-%b-%d`
if [ ! -e $today ]; then
   mkdir -p $today/source

   endpoint='http://healthdata.tw.rpi.edu/sparql'
   sparql='PREFIX datafaqs: <http://purl.org/twc/vocab/datafaqs#>
SELECT DISTINCT ?d
WHERE {
 GRAPH <http://purl.org/twc/health/source/healthdata-tw-rpi-edu/dataset/catalog/version/2012-Dec-17> { 
 ?d a datafaqs:CKANDataset
 }
}'

   curl -sG --data-urlencode "query=$sparql" --data-urlencode "format=text/csv" $endpoint | sed -e s/\"//g | tail -n +2 > $today/source/datasets.txt
   mkdir -p $today/automatic
   pushd $today/automatic
   for url in `cat ../source/datasets.txt`; do
      echo $url
      pcurl.py -f turtle $url.rdf
   done
   popd
#  echo $datasets
#  curl -sH "Content-Type: text/csv" -d "<$hhs> a <http://purl.org/twc/vocab/datafaqs#CKAN> ." $sadi > $today/source/datasets.ttl

#   echo $today/source/datasets.ttl
#   pushd $today &> /dev/null
#      aggregate-source-rdf.sh source/datasets.ttl
#   popd &> /dev/null
fi
