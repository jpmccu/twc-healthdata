<?

$conf['endpoint']['local'] = 'http://localhost:8890/sparql';
$conf['home'] = '/var/www/lod/lodspeakr/';
$conf['basedir'] = 'http://healthdata.tw.rpi.edu/lod/';
$conf['debug'] = false;

/*ATTENTION: By default this application is available to
 * be exported and copied (its configuration)
 * by others. If you do not want that, 
 * turn the next option as false
 */ 
$conf['export'] = true;

#If you want to add/overrid a namespace, add it here
$conf['ns']['local']   = 'http://healthdata.tw.rpi.edu/lod/';
$conf['ns']['base']   = 'http://healthdata.tw.rpi.edu/lod/';

$conf['mirror_external_uris'] = $conf['ns']['local'];
?>
