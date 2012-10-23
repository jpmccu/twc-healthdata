<?

$conf['endpoint']['local'] = 'http://localhost:8890/sparql';
$conf['home'] = '/var/www/lodspeakr/';
$conf['basedir'] = 'http://healthdata.tw.rpi.edu/';
$conf['debug'] = false;

/*ATTENTION: By default this application is available to
 * be exported and copied (its configuration)
 * by others. If you do not want that, 
 * turn the next option as false
 */ 
$conf['export'] = true;

# If you want to add/override a namespace, add it here
$conf['ns']['health'] = 'http://healthdata.tw.rpi.edu/source/hub-healthdata-gov/vocab/';
$conf['ns']['local']   = 'http://purl.org/twc/health/';
$conf['ns']['base']   = 'http://healthdata.tw.rpi.edu/';
$conf['ns']['logd']   = 'http://logd.tw.rpi.edu/';
$conf['ns']['inf'] = 'http://inference-web.org/2.1exper/pml-provenance.owl#';
//$conf['ns']['local']   = 'http://healthdata.tw.rpi.edu/source/';
$conf['mirror_external_uris'] = $conf['ns']['local'];
//$conf['root'] = "http://healthdata.tw.rpi.edu/";

$conf['ns']['nfo'] = 'http://www.semanticdesktop.org/ontologies/nfo/#';


$conf['type']['priority']['void:Dataset']          = 0;
$conf['type']['priority']['conv:AbstractDataset']  = 1;
$conf['type']['priority']['conv:VersionedDataset'] = 1;
$conf['type']['priority']['conv:LayerDataset']     = 1;

?>
