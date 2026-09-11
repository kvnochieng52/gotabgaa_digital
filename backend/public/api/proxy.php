<?php
define('UPSTREAM', 'http://102.210.28.247/tmp_hls/tv/');
$file = isset($_GET['file']) ? basename($_GET['file']) : 'index.m3u8';
$isTs = substr($file, -3) === '.ts';
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: *');
while (ob_get_level()) ob_end_clean();
if ($isTs) {
    header('Content-Type: video/mp2t');
    header('Cache-Control: public, max-age=30');
    $ch = curl_init(UPSTREAM . $file);
    curl_setopt_array($ch, [CURLOPT_FOLLOWLOCATION=>true,CURLOPT_TIMEOUT=>20,CURLOPT_CONNECTTIMEOUT=>4,CURLOPT_RETURNTRANSFER=>false,CURLOPT_ENCODING=>'',CURLOPT_BUFFERSIZE=>131072,CURLOPT_USERAGENT=>'GotabgaaProxy/2.0',CURLOPT_WRITEFUNCTION=>function($ch,$data){ echo $data; flush(); return strlen($data); }]);
    curl_exec($ch);
    curl_close($ch);
    exit;
}
$ch = curl_init(UPSTREAM.'index.m3u8');
curl_setopt_array($ch,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_FOLLOWLOCATION=>true,CURLOPT_TIMEOUT=>8,CURLOPT_CONNECTTIMEOUT=>4,CURLOPT_USERAGENT=>'GotabgaaProxy/2.0']);
$playlist = curl_exec($ch);
$code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);
if (!$playlist || $code < 200 || $code >= 300) { http_response_code(502); exit('Stream unavailable'); }
$proto = (!empty($_SERVER['HTTPS']) && $_SERVER['HTTPS']!=='off') ? 'https' : 'http';
$base = $proto.'://'.$_SERVER['HTTP_HOST'].'/api/proxy.php?file=';
$playlist = preg_replace_callback('/^(?!#)(\S+\.ts)/m', function($m) use ($base){ return $base.basename($m[1]); }, $playlist);
header('Content-Type: application/vnd.apple.mpegurl');
header('Cache-Control: no-cache');
echo $playlist;
