#!/bin/bash
#
#3> <> rdfs:seeAlso <https://github.com/jimmccusker/twc-healthdata/wiki/Automation>;
#3>    prov:specializationOf <https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh> .
#
#3> <https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh>
#3>    foaf:homepage <https://github.com/jimmccusker/twc-healthdata/blob/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh> .

pushd `dirname $0` &> /dev/null
   source ../../../csv2rdf4lod-source-me-as-root.sh
   source ../../../csv2rdf4lod-source-me-when-ckaning.sh

   versionID=`date +%Y-%b-%d_%H_%M_%S`
   mkdir -p version/$versionID/source
   log=version/$versionID/source/log-$versionID.txt

   cr-vars.sh >> $log
popd &> /dev/null
