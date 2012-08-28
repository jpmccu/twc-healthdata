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
#3> .

today=`date +%Y-%b-%d`
if [ ! -e $today ]; then
   mkdir -p $today/source
   curl -sH "Content-Type: text/turtle" -d '<http://hub.healthdata.gov> a <http://purl.org/twc/vocab/datafaqs#CKAN> .'  http://aquarius.tw.rpi.edu/projects/datafaqs/services/sadi/core/select-datasets/by-ckan-installation > $today/source/datasets.rdf
   echo $today/source/datasets.rdf
fi
