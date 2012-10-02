#!/bin/bash

pushd `dirname $0` &> /dev/null
   source ../../../csv2rdf4lod-source-me-as-root.sh
   source ../../../csv2rdf4lod-source-me-when-ckaning.sh

   versionID=`date +%Y-%b-%d_%H_%M_%S`
   mkdir -p version/$versionID/source
   log=version/$versionID/source/log-$versionID.txt

   cr-vars.sh >> $log
popd &> /dev/null
