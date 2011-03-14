<?php
require_once "includes/functions.php";
require_once "config/constants.php";

function readDirectory($params)
{
	global $fileDir;
	if(isset($params["directory"])) {
		$dir = $fileDir . $params["directory"] ;
		outputDirectoryListing($dir);
	}
	else
	outputDirectoryListing($fileDir);
}
function createDirectory($params)
{
	global $fileDir,$thumbDir;
	if(isset($params["directory"]) && isset($params["name"]) ) {
		$directory = $params["directory"];
		$folderName = $params["name"];

		if($directory != null && $directory !="" && $directory !=" ")
		{
			$dir = $fileDir.$directory.$folderName;
			mkdir($fileDir.$directory.$folderName,0777);
			chmod($fileDir.$directory.$folderName,0777);
			mkdir($thumbDir.$directory.$folderName, 0777);
			chmod($thumbDir.$directory.$folderName,0777);
		}
		else
		{
			$dir = $fileDir.$folderName;
			mkdir($fileDir.$folderName, 0777);
			mkdir($thumbDir.$folderName, 0777);
			chmod($fileDir.$folderName, 0777);
			chmod($thumbDir.$folderName, 0777);
		}

		$mtime = filemtime($dir);
		$type="folder";
		$size = dirsize($dir);
		$size *= 1024;
		$createthumb = 0;
		$results = array();
		$arr =  array("name"=>$folderName,"createdate"=>$mtime,"size"=>$size,"type"=>$type,"createthumb"=>$createthumb);
		array_push($results, $arr);
		serializeArray($results);

	}
	else
	sendFailed("Missing Parameters");
}
function removeDirectory($params)
{
	global $fileDir,$thumbDir;
	if(isset($params["directory"])) {
		rm_recursive($fileDir . $params["directory"]);
		rm_recursive($thumbDir . $params["directory"]);
		sendSuccess();
	}
	else
	sendFailed("Directory is not specified");
}
function removeFile($params)
{
	global $fileDir,$thumbDir;

	if(isset($params["file"]))
	{
		unlink($fileDir . $params["file"]);
		if($params["removethumb"]) {
			unlink($thumbDir . $params["file"]);
		}
		sendSuccess();
	}
	else
	sendFailed("File was not specified");
}
function renameItem($params)
{
	global $fileDir,$thumbDir;
	if (isset($params['oldname']) && isset($params['newname'])) {
		rename ($fileDir . $params["oldname"],$fileDir . $params["newname"]);
		if(file_exists($thumbDir . $params["oldname"]))
		rename ($thumbDir . $params["oldname"],$thumbDir . $params["newname"]);
		sendSuccess();
	}
	else
		sendFailed("Missing arguments for file rename");
}
function moveFile($params)
{
	global $fileDir,$thumbDir;
	if(isset($params['name']) && isset($params['path'])
	&& isset($params['newPath']) && isset($params['type']) && isset($params['id']))
	{
		// get the mapping that was passed
		$name = $params["name"];
		$path = $fileDir . $params["path"];
		$newPath = $fileDir . $params["name"];

		rename($path.$name,$newPath.$name);
		if($params['type'] == "images")
		{
			$thumbPath = $thumbDir . $params["path"];
			$newThumbPath = $thumbDir . $params["name"];
			rename($thumbPath.$name,$newThumbPath.$name);
		}
		$sql = "UPDATE media SET path='" . $newPath  . "' WHERE id='" . $params['id'] . "'";
		if($result = queryDatabase($sql))
		sendSuccess();
		else
		die ("Query failed");
	}
	else
	{
		die ("Missing Parameters");
	}
}
function getXMP($params)
{
	global $fileDir;
	if(isset($params['file']))
	{
		$file = $fileDir . $params["file"];
		$result = parseXMP($file);
		if($result[0] == true) {
			header("Content-Type: text/xml");
			echo $result[1];
		}
		else
		sendFailed($result[1]);
	}
	else
	sendFailed("file parameter is not set");
}
function getID3($params)
{
	global $fileDir;
	// Initialize getID3 engine
	$getid3 = new getID3;
	$array2xml = new array2xml;
	// Tell getID3() to use UTF-8 encoding - must send proper header as well.
	$getid3->encoding = 'UTF-8';

	// Tell browser telling it use UTF-8 encoding as well.
	header("Content-type: text/xml");

	// Analyze file
	if(isset($params['file']))
	{
		$file = $fileDir . $params["file"];
		try {
			$info = $getid3->Analyze($file);
			$array2xml->formatarray2xml($info);
			echo $array2xml->output;
		}
		catch (Exception $e) {
			die('An error occured: ' .  $e->message);
		}
	}
	else
	die("invalid file");
}
function getPlayTime($params)
{
	global $fileDir;
	if(isset($params['file'])) {
		$file = $fileDir . $params["file"];
		if(file_exists($file)) {
			$result = getPlaytimeID3($file);
			if($result[0] == true)
			sendSuccess($result[1]);
			else
			sendFailed($result[1]);
		}
		else
		sendFailed("file doesnt exist");
	}
	else
	sendFailed("invalid file");
}
function downloadZip($params) {
	global $fileDir,$tempDir;
	$name = "archive";
	$archive = new PclZip($tempDir.$name. '.zip');
	$fileArr = explode(",",$params["files"]);
	$fileArr2 = array();
	foreach($fileArr  as $f)
	{
		$f = $fileDir . $f;
		$fileArr2[] = $f;
	}
	$v_list = $archive->create($fileArr2);
	 
	if ($v_list == 0)
	{
		die("Error : ".$archive->errorInfo(true));
	}
	else
	{
		$fileContent = file_get_contents($tempDir.$name. '.zip');
		header("Content-Type: application/zip");
		$header = "Content-Disposition: attachment; filename=\"";
		$header .= $name. '.zip';
		$header .= "\"";
		header($header);
		header("Content-Length: " . strlen($fileContent));
		header("Content-Transfer-Encoding: binary");
		header("Cache-Control: no-cache, must-revalidate, max-age=60");
		header("Expires: Sat, 01 Jan 2000 12:00:00 GMT");
		print($fileContent);
	}
}
function getDirSize($params) {
	global $fileDir;
	if(isset($params["directory"])) {
		$size = dirSize($fileDir.$params["directory"]) * 1024;
		sendSuccess($size);
	}
	else
		sendFailed("Directory is not specified");
}
/*
 * ##########################################################################################
 * ################################# Help Functions #########################################
 * ##########################################################################################
 */
function outputDirectoryListing($newdir){
	$dir=opendir($newdir);
	$resultList = array();
	
	if($dir)
	{
		while(($file = readdir($dir)) !== false){
			
			if($file !== "." && $file !== ".." && $file != "migThumbs" && $file != ".DS_Store"){
				
				$mtime = filemtime($newdir.$file);
				
				if(is_file($newdir.$file))
				{	
					$type="file";
					$size = shell_exec("du -k " . $newdir.$file);
					$chars = preg_split("/[\s,]*\\\"([^\\\"]+)\\\"[\s,]*|" . "[\s,]*'([^']+)'[\s,]*|" . "[\s,]+/", $size, -1, PREG_SPLIT_OFFSET_CAPTURE);	
					//print_r($chars);
					$size = $chars[0][0];
					$createthumb = preg_match_all('/^.*\.(jpg|jpeg|png|gif|tiff|tiff|bmp|mov|m4v|flv|f4v|mp4)$/i',$file, $arr, PREG_PATTERN_ORDER);
					$childrencount = 0;
				}
				else
				{
					$type="folder";
					$size = dirsize($newdir.$file);
					$createthumb = 0;
					$childrencount = num_files($newdir.$file,3);
				}
				$size *= 1024;
				//$size = byteSize($size);
				$arr =  array("name"=>$file,"createdate"=>$mtime,"size"=>$size,"type"=>$type,"createthumb"=>$createthumb,"childrencount"=>$childrencount);
				array_push($resultList, $arr);
				
			}
		}
		serializeArray($resultList);
		closedir($dir);
	}
}
function num_files($dir, $type, $ext="")
{
// type 1: files only
// type 2: direcories only
// type 3: files and directories added
// type 4: files and directories separated with a space

    if (!isset($dir) OR empty($dir))
    {
        echo '<b>Syntax error:</b> $dir value empty.';
        exit;
    }

    $num_files = 0;
    $num_dirs = 0;
    switch($type)
    { 
        case 1: // count only files, not dirs
            if ($dir = @opendir($dir))
            {
                while (($file = readdir($dir)) !== false)
                {
                    if(is_file($file) AND $file != "." AND $file != "..")
                    {
                        if (isset($ext) AND !empty($ext))
                        {
                            $extension = end(explode(".", $file));
                            if ($ext == $extension)
                            {
                                $num_files++;
                            }
                        }
                        else
                        {
                            $num_files++;
                        }
                    }
                }  
                closedir($dir);
                $total = $num_files;
            }
        break;

        case 2: // count only dirs, not files
            if ($dir = opendir($dir))
            {
                while (($file = readdir($dir)) !== false)
                {
                    if(is_dir($file) AND $file != "." AND $file != "..")
                    {
                        $num_dirs++;
                    }
                }  
                closedir($dir);    
                $total = $num_dirs;
            }
        break;

        case 3: // count files PLUS dirs in once variable
            if ($dirhandler = opendir($dir))
            {
            	//echo $dir;
                while (($file = readdir($dirhandler)) !== false)
                {
                        if ($file != "." && $file != "..")
                        {
                            $num_files++;
                        }
                    
                }  
                closedir($dirhandler);
                $total = $num_files;
            }
        break;

        case 4: // count files AND dirs separately
            if ($dirhandler = opendir($dir))
            {
                while (($file = readdir($dirhandler)) !== false)
                {
                    if(is_file($file) AND $file != "." AND $file != "..")
                    {
                        $num_files++;
                    }

                    if(is_dir($file) AND $file != "." AND $file != "..")
                    {
                        $num_dirs++;
                    }
                }  
                closedir($dirhandler);
                $total = $num_files." ".$num_dirs;
            }
        break;

        default:
            echo '<b>Syntax error:</b> $type value empty.';
        break;
    }

    return $total;
}
function rm_recursive($filepath)
{
	if (is_dir($filepath) && !is_link($filepath))
	{
		if ($dh = opendir($filepath))
		{
			while (($sf = readdir($dh)) !== false)
			{
				if ($sf == '.' || $sf == '..')
				{
					continue;
				}
				if (!rm_recursive($filepath.'/'.$sf))
				{
					throw new Exception($filepath.'/'.$sf.' could not be deleted.');
				}
			}
			closedir($dh);
		}
		return rmdir($filepath);
	}
	return unlink($filepath);
}
function createThumbFromCenter($file,$thumbDirectory,$base,$extension,$new_w,$new_h)
{
	// if (preg_match("/jpg|jpeg/",strtolower($extension)))
	// $src_img=imagecreatefromjpeg($file);
	// if (preg_match("/png/",strtolower($extension))) {
	// 	$src_img=imagecreatefrompng($file);
	// 	imagealphablending($src_img, true); // setting alpha blending on
	// 	imagesavealpha($src_img, true); // save alphablending setting (important)
	// }
	// 
	// if (preg_match("/gif/",strtolower($extension)))
	// $src_img=imagecreatefromgif($file);
	// 
	// // assuming that $img holds the image with which you are working
	// $img_width  = imagesx($src_img);
	// $img_height = imagesy($src_img);
	// 
	// // New image size
	// $width  = $new_w;
	// $height = $new_h;
	// 
	// // Starting point of crop
	// $tlx = floor($img_width / 2) - floor ($width / 2);
	// $tly = floor($img_height / 2) - floor($height / 2);
	// 
	// // Adjust crop size if the image is too small
	// if ($tlx < 0)
	// {
	// 	$tlx = 0;
	// }
	// if ($tly < 0)
	// {
	// 	$tly = 0;
	// }
	// 
	// if (($img_width - $tlx) < $width)
	// {
	// 	$width = $img_width - $tlx;
	// }
	// if (($img_height - $tly) < $height)
	// {
	// 	$height = $img_height - $tly;
	// }
	// 
	// $dst_img = imagecreatetruecolor($width, $height);
	// imagecopy($dst_img, $src_img, 0, 0, $tlx, $tly, $width, $height);
	// if (preg_match("/png/",strtolower($extension))) {
	// 
	// 	imagepng($dst_img,$thumbDirectory.$base.'.'.$extension,9);
	// 	//imagealphablending($dst_img, true); // setting alpha blending on
	// 	//imagesavealpha($dst_img, true); // save alphablending setting (important)
	// }
	// 
	// else if (preg_match("/jpg|jpeg/",strtolower($extension)))
	// imagejpeg($dst_img,$thumbDirectory.$base.'.'.$extension,100);
	// else
	// imagegif($dst_img,$thumbDirectory.$base.'.'.$extension);
	// imagedestroy($dst_img);
	// imagedestroy($src_img);
}
function createthumb($file,$thumbDirectory,$base,$extension,$new_w,$new_h)
{
	if (preg_match("/jpg|jpeg/",$extension))
	$src_img=imagecreatefromjpeg($file);
	if (preg_match("/png/",$extension))
	$src_img=imagecreatefrompng($file);
	if (preg_match("/gif/",$extension))
	$src_img=imagecreatefromgif($file);

	$old_x=imageSX($src_img);
	$old_y=imageSY($src_img);

	if ($old_x > $old_y)
	{
		$thumb_w=$new_w;
		$thumb_h=$old_y*($new_h/$old_x);
	}
	if ($old_x < $old_y)
	{
		$thumb_w=$old_x*($new_w/$old_y);
		$thumb_h=$new_h;
	}
	if ($old_x == $old_y)
	{
		$thumb_w=$new_w;
		$thumb_h=$new_h;
	}
	$dst_img=ImageCreateTrueColor($thumb_w,$thumb_h);
	imagecopyresampled($dst_img,$src_img,0,0,0,0,$thumb_w,$thumb_h,$old_x,$old_y);
	if (preg_match("/png/",$extension))
	imagepng($dst_img,$thumbDirectory.$base.'.'.$extension);
	else if (preg_match("/jpg|jpeg/",$extension))
	imagejpeg($dst_img,$thumbDirectory.$base.'.'.$extension);
	else
	imagegif($dst_img,$thumbDirectory.$base.'.'.$extension);
	imagedestroy($dst_img);
	imagedestroy($src_img);

}
function createsquarethumb($file,$thumbDirectory,$base,$extension,$thumbwidth)
{
	if (preg_match("/jpg|jpeg/",$extension))
	$src_img=imagecreatefromjpeg($file);
	if (preg_match("/png/",$extension))
	$src_img=imagecreatefrompng($file);
	if (preg_match("/gif/",$extension))
	$src_img=imagecreatefromgif($file);


	$origWidth = imagesx($src_img);
	$origHeight = imagesy($src_img);
	$x = ($origWidth - $thumbwidth)/2;
	$y = ($origHeight - $thumbwidth)/2;

	$dst_img=ImageCreateTrueColor($thumbwidth,$thumbwidth);

	imagecopyresized($dst_img, $src_img, 0, 0, $x, $y, $thumbwidth, $thumbwidth, $thumbwidth, $thumbwidth);

	if (preg_match("/png/",$extension))
	imagepng($dst_img,$thumbDirectory.$base.'_square.'.$extension);
	else if (preg_match("/jpg|jpeg/",$extension))
	imagejpeg($dst_img,$thumbDirectory.$base.'_square.'.$extension);
	else
	imagegif($dst_img,$thumbDirectory.$base.'_square.'.$extension);
	imagedestroy($dst_img);
	imagedestroy($src_img);
		
}
function parseXMP($file) {
	$result = array();
	if(file_exists($file)) {
		$size = shell_exec("du -k " . $file);
		$chars = preg_split("/[\s,]*\\\"([^\\\"]+)\\\"[\s,]*|" . "[\s,]*'([^']+)'[\s,]*|" . "[\s,]+/", $size, -1, PREG_SPLIT_OFFSET_CAPTURE);
		$size = $chars[0][0];

		if($size < 2000) {

			$fh = fopen($file,'rb') or die($php_errormsg);
			$content = fread($fh,filesize($file));
			header("Content-Type: text/plain");
				
			if(strpos($content, "<x:xmpmeta")) {

				$tempArr = explode("<x:xmpmeta",$content);
				$tempStr = "<x:xmpmeta" . $tempArr[1];
				$tempArr = explode("</x:xmpmeta>",$tempStr);
				$tempStr = $tempArr[0] . "</x:xmpmeta>";
				$result[0] = true;
				$result[1] = $tempStr;
			}
			else {
				$result[0] = false;
				$result[1] = "parsing failed";
			}
		}
		else {
			$result[0] = false;
			$result[1] = "file size is too big";
		}
		//		try {
		//			$myFile = "tmp.sh";
		//			$fh = fopen("tmp.sh",'wb') or die($php_errormsg);
		//			$execcmd = "./xmpcommand -compact get " . $file . " >> tmp.xml";
		//			$fh = fopen($myFile, 'w') or die("can't open file");
		//			fwrite($fh, $execcmd);
		//			fclose($fh);
		//			chmod($myFile,0777);
		//			exec("./tmp.sh");
		//			$fh = fopen("tmp.xml",'rb') or die($php_errormsg);
		//			$content = fread($fh,filesize("tmp.xml"));
		//			$result[0] = true;
		//			$result[1] = $content;
		//		}
		//		catch (Exception $e) {
		//			$result[0] = false;
		//			$result[1] = "FAILS";
		//			return $result;
		//		}
}
else {
	$result[0] = false;
	$result[1] = "file doesnt exist";
}
return $result;
}
function getKeywords($file) {
	$result = parseXMP($file['file']);
	if($result[0] == true) {
		$xmp = $result[1];
		$tempArr = explode("<dc:subject>",$xmp);
		$tempArr = explode("</dc:subject>",$tempArr[1]);
		$tempArr = explode("<rdf:Bag>",$tempArr[0]);
		$tempArr = explode("</rdf:Bag>",trim($tempArr[1]));
		$tempArr = explode("<rdf:li>",trim($tempArr[0]));

		$tags = '';
		foreach($tempArr as $li) {
			if(trim($li) != '')
			$tags .= strip_tags(trim($li)) .',';
		}
		$tags = substr($tags,0,strlen($tags)-1);
		return $tags;
	}
	else
	return '';
}
// Analyze file
function getPlaytimeID3($file) {
	// Initialize getID3 engine
	$getid3 = new getID3;
	// Tell getID3() to use UTF-8 encoding - must send proper header as well.
	$getid3->encoding = 'UTF-8';
	$result = array();
	try {

		$info = $getid3->Analyze($file);
		if(isset($info["playtime_seconds"])) {
			$result[0] = true;
			$result[1] = $info["playtime_seconds"];
		}
		else {
			$result[0] = false;
			$result[1] = "file format doesnt have playtime";
		}
		return $result;
	}
	catch (Exception $e) {
		$result[0] = false;
		$result[1] = $e->message;
		return $result;
	}
}
function getExtension($delim, $str, $lim = 1)
{
	if ($lim > -2) return explode($delim, $str, abs($lim));

	$lim = -$lim;
	$out = explode($delim, $str);
	if ($lim >= count($out)) return $out;

	$out = array_chunk($out, count($out) - $lim + 1);

	return array_merge(array(implode($delim, $out[0])), $out[1]);
}
function sanitize_file_name( $filename )
{
	$filename_raw = $filename;
	$special_chars = array("?", "[", "]", "/", "\\", "=", "<", ">", ":", ";", ",", "'", "\"", "&", "$", "#", "*", "(", ")", "|", "~", "`", "!", "{", "}", chr(0));
	$filename = str_replace($special_chars, '', $filename);
	$filename = preg_replace('/[\s-]+/', '-', $filename);
	$filename = trim($filename, '.-_');

	// Split the filename into a base and extension[s]
	$parts = explode('.', $filename);

	return $filename;
}
function checkName($t,$b,$e,$index)
{
	if(file_exists($t.$b.'_'.$index.'.'.$e))
	{
		$index++;
		return checkName($t,$b,$e,$index);
	}
	else
	return $index;
}
/**
 * Calculate the size of a directory by iterating its contents
 *
 * @author      Aidan Lister <aidan@php.net>
 * @version     1.2.0
 * @link        http://aidanlister.com/repos/v/function.dirsize.php
 * @param       string   $directory    Path to directory
 */
function dirsize($path)
{
    // Init
    $size = 0;

    // Trailing slash
    if (substr($path, -1, 1) !== DIRECTORY_SEPARATOR) {
        $path .= DIRECTORY_SEPARATOR;
    }

    // Sanity check
    if (is_file($path)) {
        return filesize($path);
    } elseif (!is_dir($path)) {
        return false;
    }

    // Iterate queue
    $queue = array($path);
    for ($i = 0, $j = count($queue); $i < $j; ++$i)
    {
        // Open directory
        $parent = $i;
        if (is_dir($queue[$i]) && $dir = @dir($queue[$i])) {
            $subdirs = array();
            while (false !== ($entry = $dir->read())) {
                // Skip pointers
                if ($entry == '.' || $entry == '..') {
                    continue;
                }

                // Get list of directories or filesizes
                $path = $queue[$i] . $entry;
                if (is_dir($path)) {
                    $path .= DIRECTORY_SEPARATOR;
                    $subdirs[] = $path;
                } elseif (is_file($path)) {
					$temp = shell_exec("du -k " . $path);
					$chars = preg_split("/[\s,]*\\\"([^\\\"]+)\\\"[\s,]*|" . "[\s,]*'([^']+)'[\s,]*|" . "[\s,]+/", $temp, -1, PREG_SPLIT_OFFSET_CAPTURE);	
					$size += $chars[0][0];
                }
            }

            // Add subdirectories to start of queue
            unset($queue[0]);
            $queue = array_merge($subdirs, $queue);

            // Recalculate stack size
            $i = -1;
            $j = count($queue);

            // Clean up
            $dir->close();
            unset($dir);
        }
    }

    return $size;
}

function byteSize($bytes)  
{ 
    $size = $bytes; 
    if($size < 1024){ 
        $size = number_format($size, 2); 
        $size .= ' KB'; 
    }  
    else { 
    	if($size / 1024 < 1024)  { 
            $size = number_format($size / 1024, 2); 
            $size .= ' MB'; 
       }  
        else if ($size / 1024 / 1024 < 1024) { 
            $size = number_format($size / 1024 / 1024, 2); 
            $size .= ' GB'; 
        }  
    } 
    return $size; 
} 
//function createFont($params)
//{
//	//./3.0.0.477/bin/mxmlc AkkuratRegular.as -output=fonts/Akkurat/AkkuratRegular.swf
//	if (!isset($params['classname']) || !isset($params['ttf']))
//	{
//		die("font name or file not specified .");
//	}
//	$class = $params['classname'];
//	$ttf = $params['ttf'];
//
//	$fh = fopen($class.'.as', 'w');
//	$stringData = '
//	package
//	{
//		import flash.display.Sprite;
//		import flash.text.Font;
//		public class ' . $class . ' extends Sprite
//		{
//			public static var FONTNAME_NORMAL:String = "' . $class . '";
//			public function '.  $class . ' ()
//			{
//			    Font.registerFont(font);
//			}
//			public function get fontName_Normal():String
//			{
//				return FONTNAME_NORMAL;
//			}
//			[Embed(source="../'. $ttf . '", fontName=" '. $class .'")] public static var font:Class;
//		}
//	}';
//	fwrite($fh, $stringData);
//	fclose($fh);
//	///Compile the file!
//	$command = "../3.0.0.477/bin/mxmlc " . $class . ".as -output=../" . substr($ttf,0,-3) . "swf";
//	$output = shell_exec($command);
//	//remove AS file
//	unlink($class.".as");
//	sendSuccess();
//}
//
//function ZipFolder($params) // this is what gets called from flash
//{
//	// include the library from http://www.phpconcept.net/pclzip/index.en.php
//	// create a unique file name.. this is prepended with manewc.com-
//	$uniqueFileName = uniqid($params["prefix"]);
//
//	// create the zip
//	$archive = new PclZip('../temporary/'.$uniqueFileName.'.zip');
//	$fileArr = explode(",",$params["files"]);
//	$v_list = $archive->create($fileArr);
//
//	if ($v_list == 0)
//	{
//		die("Error : ".$archive->errorInfo(true));
//	}
//	else
//	{
//		sendSuccess($uniqueFileName.'.zip');
//	}
//}
?>