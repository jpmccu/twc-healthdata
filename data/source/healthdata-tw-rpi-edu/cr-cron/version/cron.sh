#!/bin/bash
#
#3> <> rdfs:seeAlso <https://github.com/jimmccusker/twc-healthdata/wiki/Automation>;
#3>    prov:specializationOf <https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh> .
#
#3> <https://raw.github.com/jimmccusker/twc-healthdata/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh>
#3>    foaf:homepage <https://github.com/jimmccusker/twc-healthdata/blob/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh> .

if [ "$1" == "--help" ]; then
   # Determine the absolute path to this script.
   D=`dirname "$0"`
   script_home="`cd \"$D\" 2>/dev/null && pwd || echo \"$D\"`"

   echo
   echo "This script is run by cron to automate an installation of csv2rdf4lod-automation."
   echo "  See:"
   echo "    https://github.com/jimmccusker/twc-healthdata/wiki/Automation"
   echo "    https://github.com/jimmccusker/twc-healthdata/blob/master/data/source/healthdata-tw-rpi-edu/cr-cron/version/cron.sh"
   echo
   echo "Place something similar to the following into your crontab (by running 'crontab -e')"
   echo
   echo "# m h  dom mon dow   command"
   echo "`date +%M` `date +%k`  *   *   *     $script_home/`basename $0`"
   echo
   echo "# ^^ Be sure to put an extra newline, or the last command will not invoke."
   exit
fi

pushd `dirname $0` &> /dev/null

   # Boostrap ourselves with environment variables and paths.
   source ../../../csv2rdf4lod-source-me.sh
   source ../../../csv2rdf4lod-source-me-as-`whoami`.sh
   source ../../../csv2rdf4lod-source-me-when-ckaning.sh
   export CLASSPATH=$CLASSPATH`$CSV2RDF4LOD_HOME/bin/util/cr-situate-classpaths.sh`
   export PATH=$PATH`$CSV2RDF4LOD_HOME/bin/util/cr-situate-paths.sh`

   see='https://github.com/timrdf/csv2rdf4lod-automation/wiki/CSV2RDF4LOD-not-set'
   if [[ "${#CSV2RDF4LOD_HOME}" -eq 0 ]]; then
      echo "[ERROR] CSV2RDF4LOD_HOME is not set; cannot continue." > `dirname $0`/bootstrap-error.txt
      echo "        see $see"                                     >> `dirname $0`/bootstrap-error.txt
      date                                                        >> `dirname $0`/bootstrap-error.txt
   fi

   versionID=`md5.sh $0` # < - - - needs - /\
   mkdir -p $versionID/doc/logs
   logID=`date +%Y-%b-%d_%H_%M`

   lock=`pwd`/.lock
   log=`pwd`/$versionID/doc/logs/cron-$logID.log # - - - - - - - - - log - - - - - - - - - - - -
   conversion_root=`cr-conversion-root.sh`
popd &> /dev/null

pushd $conversion_root &> /dev/null

   echo "BEGIN cron ps --user `whoami` `date`"                >> $log
   echo "#3> <#cron> a prov:Activity; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   ps --user `whoami`                                         >> $log
   echo "END cron ps --user `whoami` `date`"                  >> $log
   echo                                                       >> $log
   # Replaced with .lock:
   #already_running=`ps --user \`whoami\` | grep 'cron.sh' | grep -v 'grep' | wc -l | awk '{printf("%s",$1)}'`
   #echo "Number of cron.sh already_running:$already_running:" >> $log
   #if [[ ${#already_running} -gt 0 && "$already_running" -gt 1 ]]; then
   #   echo                                                    >> $log
   #   echo "cron.sh is already running; aborting."            >> $log
   #   ps --user `whoami` | grep 'cron.sh'                     >> $log
   #   ps --user `whoami` | grep 'cron.sh' | wc -l             >> $log
   #   exit 1
   #fi
   if [ -e $lock ]; then
      echo "cron.sh lock exists; aborting ($lock)."           >> $log
      echo "END cron `date`"                                  >> $log
      exit 1
   else
      echo $$ `date` > $lock
   fi
   echo                                                       >> $log


   #
   # Git any new dcat.ttl, retrieve.sh, and update this cron script.
   echo "BEGIN cron git pull `date`"    >> $log
   echo "#3> <#git-pull> a prov:Activity; prov:wasInformedBy <#cron>; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [ `which git` ]; then
      git pull 2>&1                     >> $log
   else
      echo "ERROR: git is not on PATH." >> $log
   fi
   echo "END cron git pull `date`"      >> $log
   echo                                 >> $log
  
 
   #
   # CSV2RDF4LOD_* environment variables control the processing.
   echo "BEGIN cron cr-vars.sh `date`"      >> $log
   echo "user name: $SUDO_USER as `whoami`" >> $log
   cr-vars.sh                               >> $log
   echo "END cron cr-vars.sh `date`"        >> $log
   echo                                     >> $log


   #
   # Populate our local writable CKAN instance with the entries from a third party CKAN instance.
   echo "BEGIN cron cr-mirror-ckan.py `date`"                                            >> $log
   echo "#3> <#cr-mirror-ckan> a prov:Activity; prov:wasInformedBy <#cron>; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[  "$CSV2RDF4LOD_CKAN" == "true"      && \
         ${#CSV2RDF4LOD_CKAN_SOURCE}   -gt 0 && \
         ${#CSV2RDF4LOD_CKAN_WRITABLE} -gt 0 && \
         ${#X_CKAN_API_Key}            -gt 0 && \
         `which cr-mirror-ckan.py` ]]; then
      echo cr-mirror-ckan.py $CSV2RDF4LOD_CKAN_SOURCE/api $CSV2RDF4LOD_CKAN_WRITABLE/api >> $log
      cr-mirror-ckan.py $CSV2RDF4LOD_CKAN_SOURCE/api $CSV2RDF4LOD_CKAN_WRITABLE/api 2>&1 >> $log
   else
      echo "   ERROR: Failed to invoke cr-mirror-ckan.py:"                               >> $log
      echo "      CSV2RDF4LOD_CKAN:          $CSV2RDF4LOD_CKAN"                          >> $log
      echo "      CSV2RDF4LOD_CKAN_SOURCE:   $CSV2RDF4LOD_CKAN_SOURCE"                   >> $log
      echo "      CSV2RDF4LOD_CKAN_WRITABLE: $CSV2RDF4LOD_CKAN_WRITABLE"                 >> $log
      echo "      cr-mirror-ckan.py path:    `which cr-mirror-ckan.py`"                  >> $log
      echo "      X_CKAN_API_Key:            $X_CKAN_API_Key"                            >> $log
   fi
   echo "END cron cr-mirror-ckan.py `date`"                                              >> $log
   echo                                                                                  >> $log


   #
   # DCAT files provide the data download URLs.
   echo "BEGIN cron cr-publish-dcat-to-endpoint.sh `date`"                                     >> $log
   echo "#3> <#cr-publish-dcat> a prov:Activity; prov:wasInformedBy <#cron>; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[ ${#CSV2RDF4LOD_BASE_URI}              -gt 0 && \
         ${#CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID} -gt 0 && \
         `which cr-publish-dcat-to-endpoint.sh` ]]; then
      echo "pwd: `pwd`"                                                                        >> $log
      cr-publish-dcat-to-endpoint.sh cr:auto                                              2>&1 >> $log
   else
      echo "   ERROR: Failed to invoke cr-publish-dcat-to-endpoint.sh:"                        >> $log
      echo "      CSV2RDF4LOD_BASE_URI:              $CSV2RDF4LOD_BASE_URI"                    >> $log
      echo "      CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID: $CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"       >> $log
      echo "      cr-publish-dcat-to-endpoint.sh path: `which cr-publish-dcat-to-endpoint.sh`" >> $log
   fi
   echo "END cron cr-publish-dcat-to-endpoint.sh `date`"                                       >> $log
   echo                                                                                        >> $log


   #
   # cr-retrieve.sh follows the DCAT descriptions to download the files.
   echo "BEGIN cron cr-retrieve.sh `date`"           >> $log
   echo "#3> <#cr-retrieve> a prov:Activity; prov:wasInformedBy <#cron>; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   example="hub-healthdata-gov/food-recalls"
   example=""
   if [ ${#example} -gt 0 ]; then
      pushd $example
      echo "(only working with example `cr-pwd.sh`)" >> $log
   fi
   cr-retrieve.sh -w --skip-if-exists 2>&1           >> $log
   if [ ${#example} -gt 0 ]; then
      popd
   fi
   echo "END cron cr-retrieve.sh `date`"             >> $log
   echo                                              >> $log


   #
   # Analyze the retrieved files and determine their file format.
   echo "BEGIN cron cr-publish-droid-to-endpoint.sh `date`"                                      >> $log
   echo "#3> <#cr-publish-droid> a prov:Activity; prov:wasInformedBy <#cron>; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[ ${#CSV2RDF4LOD_BASE_URI}              -gt 0 && \
         ${#CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID} -gt 0 && \
         `which cr-publish-droid-to-endpoint.sh`     && \
         `which cr-droid.sh` ]]; then
      echo "pwd: `pwd`"                                                                          >> $log
      cr-publish-droid-to-endpoint.sh cr:auto                                               2>&1 >> $log
      # TODO cr-droid.ttl's coming up empty during cron, but useful manually.
   else
      echo "   ERROR: Failed to invoke cr-publish-droid-to-endpoint.sh:"                         >> $log
      echo "      CSV2RDF4LOD_BASE_URI:              $CSV2RDF4LOD_BASE_URI"                      >> $log
      echo "      CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID: $CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"         >> $log
      echo "      cr-publish-droid-to-endpoint.sh path: `which cr-publish-droid-to-endpoint.sh`" >> $log
      echo "      cr-droid.sh path:                     `which cr-droid.sh`"                     >> $log
   fi
   echo "END cron cr-publish-droid-to-endpoint.sh `date`"                                        >> $log
   echo                                                                                          >> $log


   #
   # The VoID metadata organizes the RDF datasets created by converting each original dataset.
   echo "BEGIN cron cr-publish-void-to-endpoint.sh `date`"                                     >> $log
   echo "#3> <#cr-publish-void> a prov:Activity; prov:wasInformedBy <#cron>; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[ ${#CSV2RDF4LOD_BASE_URI}              -gt 0 && \
         ${#CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID} -gt 0 && \
         `which cr-publish-void-to-endpoint.sh` ]]; then
      echo "pwd: `pwd`"                                                                        >> $log
      echo cr-publish-void-to-endpoint.sh cr:auto                                              >> $log
      cr-publish-void-to-endpoint.sh cr:auto                                              2>&1 >> $log
   else
      echo "   ERROR: Failed to invoke cr-publish-void-to-endpoint.sh:"                        >> $log
      echo "      CSV2RDF4LOD_BASE_URI:              $CSV2RDF4LOD_BASE_URI"                    >> $log
      echo "      CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID: $CSV2RDF4LOD_PUBLISH_OUR_SOURCE_ID"       >> $log
      echo "      cr-publish-void-to-endpoint.sh path: `which cr-publish-void-to-endpoint.sh`" >> $log
   fi
   echo "END cron cr-publish-void-to-endpoint.sh `date`"                                       >> $log
   echo                                                                                        >> $log


   #
   # Find all asserted properties and classes, and assert rdfs:isDefinedBy to their namespace.
   echo "BEGIN cron cr-publish-isdefinedby-to-endpoint.sh `date`"                            >> $log
   echo "#3> <#cr-publish-isdefinedby> a prov:Activity; prov:wasInformedBy <#cron>; prov:startedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
   if [[ ${#CSV2RDF4LOD_BASE_URI}                -gt 0 && \
         ${#CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT} -gt 0 && \
         `which cr-publish-isdefinedby-to-endpoint.sh` ]]; then
      # The SPARQL endpoint is needed b/c we query for all asserted properties and classes.
      echo "pwd: `pwd`"                                                                      >> $log
      cr-publish-isdefinedby-to-endpoint.sh cr:auto                                     2>&1 >> $log
   else
      echo "   ERROR: Failed to invoke cr-publish-isdefinedby-to-endpoint.sh:"               >> $log
      echo "      CSV2RDF4LOD_BASE_URI:                $CSV2RDF4LOD_BASE_URI"                >> $log
      echo "      CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT: $CSV2RDF4LOD_PUBLISH_SPARQL_ENDPOINT" >> $log
      echo "                        path:    `which cr-publish-isdefinedby-to-endpoint.sh`"  >> $log
   fi
   echo "END cron cr-publish-isdefinedby-to-endpoint.sh `date`"                              >> $log
   echo                                                                                      >> $log


popd &> /dev/null

echo                                                                                   >> $log
echo "#3> <#cron> a prov:Activity; prov:endedAtTime `dateInXSDDateTime.sh --turtle` ." >> $log
echo "END cron `date`"                                                                 >> $log
rm $lock
