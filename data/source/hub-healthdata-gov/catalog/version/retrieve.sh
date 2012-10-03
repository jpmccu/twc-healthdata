#!/bin/bash
#
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3> 
#3> <#>
#3>    a doap:Project; 
#3>    dcterms:description 
#3>      "Script to retrieve and convert a new version of the dataset.";
#3>    rdfs:seeAlso 
#3>      <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Automated-creation-of-a-new-Versioned-Dataset>;
#3>    prov:wasDerivedFrom <https://github.com/jimmccusker/twc-healthdata/blob/master/data/source/hub-healthdata-gov/catalog/version/retrieve.sh>;
#3> .

today=`date +%Y-%b-%d`
if [ ! -e $today ]; then
   mkdir -p $today/source

   hhs='http://hub.healthdata.gov'
   sadi='http://aquarius.tw.rpi.edu/projects/datafaqs/services/sadi/core/select-datasets/by-ckan-installation'
   echo "Requesting $hhs dataset listing from $sadi"

   curl -sH "Content-Type: text/turtle" -d "<$hhs> a <http://purl.org/twc/vocab/datafaqs#CKAN> ." $sadi > $today/source/datasets.ttl

   echo $today/source/datasets.ttl
   pushd $today &> /dev/null
      aggregate-source-rdf.sh source/datasets.ttl
   popd &> /dev/null
fi
