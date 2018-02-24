DebMes("==================================================================="); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("esp_ota_update request: ".$_SERVER['REQUEST_URI']); // После этого в XRay во вкладке debug можно смотреть результат.

$file_extension = "";	// Расширение доступного файла прошивки (hex или bin)

$db = array(
    "18:fe:34:d4:26:e9" => "Garage_Fan",
    "18:FE:AA:AA:AA:BB" => "TEMP-1.0.0"
);
 
if ($params['sketch_req'] == "debug") { 
 DebMes("esp_ota_update. debug message = ".$params['message']); // После этого в XRay во вкладке debug можно смотреть результат.
}
elseif ($params['sketch_req'] != "") { 
 DebMes("sketch_req = ".$params['sketch_req']); // После этого в XRay во вкладке debug можно смотреть результат.
}

$wifimode = array(
    "1" => "wifi.STATION",
    "2" => "wifi.SOFTAP",
    "3" => "wifi.STATIONAP",
    "4" => "wifi.NULLMODE"
);
/*
// Система преобразует переданные с ESP-шки заголовки вида "x-ESP8266-extension" в заголовки, которые в php уже обрабатываются как "HTTP_X_ESP8266_EXTENSION" (т.е. преобразует все символы в апперкейз (в заглавные буквы) и меняет тире на подчёркивание). Но если нужно отправлять заголовки обратно, то уже нужно писать в лоуэркейз (мелкими буквами). причём ВСЕ символы, даже которые изначально в ESP-шке были большими. Т.е. надо писать так: "x-esp8266-extension"
DebMes("HTTP_USER_AGENT = ".$_SERVER["HTTP_USER_AGENT"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_STA_MAC = ".$_SERVER["HTTP_X_ESP8266_STA_MAC"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_STA_IP = ".$_SERVER["HTTP_X_ESP8266_STA_IP"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_FREE_SPACE = ".$_SERVER["HTTP_X_ESP8266_FREE_SPACE"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_MODE = ".$wifimode[$_SERVER["HTTP_X_ESP8266_MODE"]]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_CHIP_SIZE = ".$_SERVER["HTTP_X_ESP8266_CHIP_SIZE"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_CHIP_ID = ".$_SERVER["HTTP_X_ESP8266_CHIP_ID"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_SDK_VERSION = ".$_SERVER["HTTP_X_ESP8266_SDK_VERSION"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_FS_TOTAL = ".$_SERVER["HTTP_X_ESP8266_FS_TOTAL"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_FS_USED = ".$_SERVER["HTTP_X_ESP8266_FS_USED"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_FS_REMAINING = ".$_SERVER["HTTP_X_ESP8266_FS_REMAINING"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_SKETCH_MD5 = ".$_SERVER["HTTP_X_ESP8266_SKETCH_MD5"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("HTTP_X_ESP8266_EXTENSION = ".$_SERVER["HTTP_X_ESP8266_EXTENSION"]); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"); // После этого в XRay во вкладке debug можно смотреть результат.
*/

function check_header($name, $value = false) {
    if(!isset($_SERVER[$name])) {
DebMes("function check_header(name, value = false). Проверка-указано ли имя прошивки: SERVER[name]= ".$_SERVER[$name]); // После этого в XRay во вкладке debug можно смотреть результат.
        return false;
    }
    if($value && $_SERVER[$name] != $value) {
DebMes("[value && _SERVER[name] != value] Проверка-указано ли значение: SERVER[name]= ".$_SERVER[$name]); // После этого в XRay во вкладке debug можно смотреть результат.
        return false;
    }
    return true;
}
 
function sendFile($path, $ext) {
		header("x-esp8266-extension: ".$ext, true);
    header("Content-Type: application/octet-stream", true);
    header("Content-Length: ".filesize($path), true);
    header("x-esp8266-sketch-md5: ".md5_file($path), true);
    header("Content-Disposition: attachment; filename=".basename($path), true);
    header($_SERVER["SERVER_PROTOCOL"]." 200 OK", true, 200);

DebMes("filename = ".$path); // После этого в XRay во вкладке debug можно смотреть результат.
 $chunksize = 1460; // 1460 bytes per one chunk of file.
DebMes("chunksize = ".$chunksize); // После этого в XRay во вкладке debug можно смотреть результат.
 set_time_limit(300);
 $size = intval(sprintf("%u", filesize($path)));
DebMes("size = ".$size); // После этого в XRay во вкладке debug можно смотреть результат.
    if($size > $chunksize)
    { 
DebMes("size > chunksize"); // После этого в XRay во вкладке debug можно смотреть результат.
        $handle = fopen($path, 'rb'); 
        while (!feof($handle))
        { 
          sleep(1);
DebMes("cycle of reading "); // После этого в XRay во вкладке debug можно смотреть результат.
          print(fread($handle, $chunksize));
          ob_flush();
          flush();
          //sleep(1);
        } 
        fclose($handle); 
    }
    else readfile($path);
}

function Answer($file_name, $ext) {
//DebMes("function sendFile(path)".$path); // После этого в XRay во вкладке debug можно смотреть результат.
    header($_SERVER["SERVER_PROTOCOL"].' 200 OK', true, 200);
		header("x-file-name: ".basename($file_name), true);
		header("x-esp8266-extension: ".$ext, true);
    header("Content-Length: ".filesize($file_name));
    header("x-esp8266-sketch-md5: ".md5_file($file_name), true);
    echo "OK";
}

function AfterChecking($path) {
DebMes($_SERVER["HTTP_X_ESP8266_SKETCH_MD5"]." <- SERVER[HTTP_X_ESP8266_SKETCH_MD5]"); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes(md5_file($path). " <- md5_file(localBinary)"); // После этого в XRay во вкладке debug можно смотреть результат.
	if($_SERVER["HTTP_X_ESP8266_SKETCH_MD5"] != md5_file($path)){
DebMes("500 - Downloading was failed! (MD5 does not match)"); // После этого в XRay во вкладке debug можно смотреть результат.
		header($_SERVER["SERVER_PROTOCOL"].' 500 Downloading was failed!', true, 500);
		echo "MD5_FAIL";
	}
	else {
DebMes("200 OK - Download OK, MD5 is match"); // После этого в XRay во вкладке debug можно смотреть результат.
		header($_SERVER["SERVER_PROTOCOL"].' 200 OK', true, 200);
		echo "MD5_OK";
	}
}

if(!check_header('HTTP_USER_AGENT', 'ESP8266-http-Update')) {
DebMes("403 Forbidden - HTTP_USER_AGENT not match with ESP User-Agent"); // После этого в XRay во вкладке debug можно смотреть результат.
    header($_SERVER["SERVER_PROTOCOL"].' 403 Forbidden', true, 403);
    echo "only for ESP8266 updater!\n";
    exit();
}
 

if(
    !check_header('HTTP_X_ESP8266_STA_MAC') ||
    !check_header('HTTP_X_ESP8266_STA_IP') ||
    !check_header('HTTP_X_ESP8266_FREE_SPACE') ||
    !check_header('HTTP_X_ESP8266_MODE') ||
    !check_header('HTTP_X_ESP8266_CHIP_SIZE') ||
    !check_header('HTTP_X_ESP8266_CHIP_ID') ||
    !check_header('HTTP_X_ESP8266_SDK_VERSION') || 
    !check_header('HTTP_X_ESP8266_FS_TOTAL') ||
    !check_header('HTTP_X_ESP8266_FS_USED') ||
    !check_header('HTTP_X_ESP8266_SKETCH_MD5') ||
    !check_header('HTTP_X_ESP8266_FS_REMAINING')
) {
DebMes("403 Forbidden - not all headers is present"); // После этого в XRay во вкладке debug можно смотреть результат.
    header($_SERVER["SERVER_PROTOCOL"].' 403 Forbidden', true, 403);
    echo "only for ESP8266 updater!\n";
    exit();
}

if(!isset($db[$_SERVER['HTTP_X_ESP8266_STA_MAC']])) {
DebMes("SERVER_PROTOCOL. 500 ESP MAC not configured for updates"); // После этого в XRay во вкладке debug можно смотреть результат.
    header($_SERVER["SERVER_PROTOCOL"].' 500 ESP MAC not configured for updates', true, 500);
    echo "ESP MAC not configured for updates!\n";
    exit();
}
 
if(file_exists("./bin/".$db[$_SERVER['HTTP_X_ESP8266_STA_MAC']].".hex")) {
	$localBinary = "./bin/".$db[$_SERVER['HTTP_X_ESP8266_STA_MAC']].".hex";
	DebMes("Найден HEX-файл прошивки: ".$localBinary); // После этого в XRay 		во вкладке 		debug можно смотреть результат.
	$file_extension = "hex";
}
elseif (file_exists("./bin/".$db[$_SERVER['HTTP_X_ESP8266_STA_MAC']].".bin")){
	$localBinary = "./bin/".$db[$_SERVER['HTTP_X_ESP8266_STA_MAC']].".bin";
	DebMes("Найден BIN-файл прошивки: ".$localBinary); // После этого в XRay 		во вкладке 		debug можно смотреть результат.
	$file_extension = "bin";
}
else {
  header($_SERVER["SERVER_PROTOCOL"].' 500 Sketch file does not exist', true, 500);
  echo "500 Sketch file does not exist!\n";
	$file_extension = "no_ext";
	DebMes("Нет доступных файлов прошивки "); // После этого в XRay 		во вкладке 		debug 		можно смотреть результат.
  exit();
}

 
if ($params['sketch_req']=="AfterChecking") {
DebMes("AfterChecking()"); // После этого в XRay во вкладке debug можно смотреть результат.
     AfterChecking($localBinary);
DebMes("==================================================================="); // После этого в XRay во вкладке debug можно смотреть результат.
}
else {

	if($_SERVER["HTTP_X_ESP8266_SKETCH_MD5"] != md5_file($localBinary)){
		if ($params['sketch_req']=="NewSketchChecking") {
DebMes("Answer()"); // После этого в XRay во вкладке debug можно смотреть результат.
			Answer($localBinary, $file_extension);
/*
foreach (getallheaders() as $name => $value) 
  {
	DebMes("Answer. getallheaders -> $name: $value\n"); // После этого в XRay во вкладке debug можно смотреть результат.
  }
*/
		}
		else {
DebMes("sendFile(localBinary)"); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("file_extension = ".$file_extension); // После этого в XRay во вкладке debug можно смотреть результат.
			sendFile($localBinary, $file_extension);
/*
			foreach (getallheaders() as $name => $value) 
			{
				DebMes("SendFile. getallheaders -> $name: $value\n"); // После этого в XRay во вкладке debug можно смотреть результат.
			}
*/
		}
DebMes("==================================================================="); // После этого в XRay во вкладке debug можно смотреть результат.
	} else {
DebMes($_SERVER["HTTP_X_ESP8266_SKETCH_MD5"]." <- SERVER[HTTP_X_ESP8266_SKETCH_MD5]"); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes(md5_file($localBinary). " <- md5_file(localBinary)"); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("304 Not Modified"); // После этого в XRay во вкладке debug можно смотреть результат.
DebMes("==================================================================="); // После этого в XRay во вкладке debug можно смотреть результат.
		header($_SERVER["SERVER_PROTOCOL"].' 304 Not Modified',true, 304);
		echo "You have actual sketch, no need to download\n";
/*
		foreach (getallheaders() as $name => $value) 
		{
			DebMes("Sketch Not Modified. getallheaders -> $name: $value\n"); // После этого в XRay во вкладке debug можно смотреть результат.
		}
*/
	}
}
