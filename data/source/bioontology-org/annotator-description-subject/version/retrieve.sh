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
   mkdir -p $today/automatic

   endpoint='http://healthdata.tw.rpi.edu/sparql'
   literalSparql='prefix dcat: <http://www.w3.org/ns/dcat#> 

prefix void: <http://rdfs.org/ns/void#> 
prefix prov: <http://www.w3.org/ns/prov#> 
prefix dc:    <http://purl.org/dc/terms/> 

construct {
  ?voidDS dc:description ?desc.
} where {
  ?voidDS a void:Dataset;
          dc:description ?desc.
}'

   curl -sG --data-urlencode "query=$literalSparql" --data-urlencode "format=application/rdf+xml" $endpoint > $today/source/descriptions.rdf
   python ../../../../../annotator/annotator.py $today/source/descriptions.rdf $today/automatic/subjects.rdf

   pushd $today &> /dev/null
      aggregate-source-rdf.sh automatic/subjects.rdf
   popd &> /dev/null
fi
