# Delete all of these with:
# grep pvload.sh load-vocabs.sh | grep -v xargs | awk '{print $NF}' | sed "s/'//g" | xargs -n 1 pvdelete.sh

pvdelete.sh 'http://purl.org/NET/scovo#'
pvload.sh 'http://vocab.deri.ie/scovo.rdf' 'http://purl.org/NET/scovo#'
pvdelete.sh 'http://obofoundry.org/ro/ro.owl#'
pvload.sh 'http://obofoundry.org/ro/ro.owl#'
pvdelete.sh 'http://www.w3.org/2004/02/skos/core#'
pvload.sh 'http://www.w3.org/2004/02/skos/core#' -ng 'http://www.w3.org/2004/02/skos/core#'
pvdelete.sh 'http://purl.org/dc/terms'
pvload.sh 'http://dublincore.org/2012/06/14/dcterms.rdf' -ng 'http://purl.org/dc/terms'
pvdelete.sh 'http://www.w3.org/ns/prov#'
pvload.sh 'http://www.w3.org/TR/prov-o/prov-20120724.owl' -ng 'http://www.w3.org/ns/prov#'
pvdelete.sh 'http://inference-web.org/2.0/pml-justification.owl#'
pvload.sh 'http://inference-web.org/2.0/pml-justification.owl#'
pvdelete.sh 'http://inference-web.org/2.0/pml-provenance.owl#'
pvload.sh 'http://inference-web.org/2.0/pml-provenance.owl#'
pvload.sh 'http://rdfs.org/ns/void.rdf' -ng 'http://rdfs.org/ns/void#'
pvload.sh 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
pvload.sh 'http://www.w3.org/2000/01/rdf-schema#'
pvload.sh 'http://www.w3.org/2002/07/owl#'
pvload.sh 'http://www.w3.org/2001/XMLSchema#'
pvload.sh 'http://xmlns.com/foaf/spec/index.rdf' -ng 'http://xmlns.com/foaf/0.1'

pvload.sh 'http://www.w3.org/2000/10/swap/pim/contact#'
pvload.sh 'http://usefulinc.com/ns/doap#'
pvload.sh 'http://sparql.tw.rpi.edu/vocab/conversion.ttl' -ng 'http://purl.org/twc/vocab/conversion/'
pvload.sh 'http://www.w3.org/2006/vcard/ns#'
pvload.sh 'http://www.w3.org/2003/01/geo/wgs84_pos#'

pvload.sh 'http://www.w3.org/ns/sparql-service-description.rdf' -ng 'http://www.w3.org/ns/sparql-service-description#'
pvload.sh 'http://www.w3.org/ns/dcat.ttl' -ng 'http://www.w3.org/ns/dcat#'
pvload.sh 'http://www.semanticdesktop.org/ontologies/2007/03/22/nfo/nfo_data.rdfs' -ng 'http://www.semanticdesktop.org/ontologies/nfo/#'


pvload.sh 'https://raw.github.com/jimmccusker/twc-healthdata/master/ontology/aggregate.owl' -ng 'http://purl.org/twc/health/vocab/aggregate'
pvload.sh 'https://raw.github.com/jimmccusker/twc-healthdata/master/ontology/bioportal-labels.ttl' -ng 'http://purl.bioontology.org/ontology'
pvload.sh 'http://sparql.bioontology.org/sparql/?query=construct+%7B+%3Fs+%3Fp+%3Fo+%7D%0D%0AFROM+%3Chttp%3A%2F%2Fbioportal.bioontology.org%2Fontologies%2FSNOMEDCT%3E+%0D%0AWHERE+%0D%0A%7B%0D%0A++++%3Fs+%3Fp+%3Fo.%0D%0A%7D%0D%0A&csrfmiddlewaretoken=e260b338e5eb10d5f540a46acd4f2e12' -ng http://purl.bioontology.org/ontology/SNOMEDCT
pvload.sh 'http://sparql.bioontology.org/sparql/?query=construct+%7B+%3Fs+%3Fp+%3Fo+%7D%0D%0AFROM+%3Chttp%3A%2F%2Fbioportal.bioontology.org%2Fontologies%2FICD9CM%3E+%0D%0AWHERE+%0D%0A%7B%0D%0A++++%3Fs+%3Fp+%3Fo.%0D%0A%7D%0D%0A&csrfmiddlewaretoken=e260b338e5eb10d5f540a46acd4f2e12' -ng http://purl.bioontology.org/ontology/ICD9CM
