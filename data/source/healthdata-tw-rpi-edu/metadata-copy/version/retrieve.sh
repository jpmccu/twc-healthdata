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
   literalSparql='prefix dcat: <http://www.w3.org/ns/dcat#> 
prefix void: <http://rdfs.org/ns/void#> 
prefix prov: <http://www.w3.org/ns/prov#> 

construct {
  ?voidDS ?p ?o.
} where {
  ?voidDS a void:Dataset;
    prov:wasDerivedFrom ?download.

  ?dcatDS a dcat:Dataset;
    dcat:distribution [ dcat:accessURL ?download ].
   ?dcatDS ?p ?o.
  filter (isLiteral(?o))
}'
   bnodeSparql='prefix dcat:       <http://www.w3.org/ns/dcat#> 
prefix void:       <http://rdfs.org/ns/void#> 
prefix prov:       <http://www.w3.org/ns/prov#> 

construct {
  ?voidDS ?p1 ?b.
  ?b ?p2 ?o.
} where {
  ?voidDS a void:Dataset;
    prov:wasDerivedFrom ?download.

  ?dcatDS a dcat:Dataset;
    dcat:distribution [ dcat:accessURL ?download ].
   ?dcatDS ?p1 ?b.
   ?b rdf:value []; ?p2 ?o.
  filter (isBlank(?b))
}'

   curl -sG --data-urlencode "query=$literalSparql" --data-urlencode "format=application/rdf+xml" $endpoint > $today/source/literals.rdf
   curl -sG --data-urlencode "query=$bnodeSparql" --data-urlencode "format=application/rdf+xml" $endpoint > $today/source/bnodes.rdf
#  echo $datasets
#  curl -sH "Content-Type: text/csv" -d "<$hhs> a <http://purl.org/twc/vocab/datafaqs#CKAN> ." $sadi > $today/source/datasets.ttl

   pushd $today &> /dev/null
      aggregate-source-rdf.sh source/literals.rdf source/bnodes.rdf
   popd &> /dev/null
fi
