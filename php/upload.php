<?php
require_once "fileFunctions.php";
require_once "config/constants.php";

$path = $fileDir . $_REQUEST['directory'];
$thumbpath = $thumbDir . $_REQUEST['directory'];
$fileType = $_REQUEST["fileType"];
$filename = sanitize_file_name($_FILES['Filedata']['name']);
$arr = getExtension('.', $filename, -2);
$extension = $arr[1];
$base = $arr[0];

move_uploaded_file($_FILES['Filedata']['tmp_name'], $tempDir. $filename);
 
if(file_exists($path.$filename))   
{
	$counter = checkName($path,$base,$extension,1);
	$base .= '_'.$counter;
}
rename($tempDir.$filename, $path.$base.'.'.$extension);

$thumbase = $base; 
$thumbextension = $extension;
$thumbCreated = false;
$videoProxy = false;
if(file_exists($thumbpath.$thumbase.'.'.$thumbextension))
{
	$counter = checkName($thumbpath,$thumbase,$thumbextension,1);
	$thumbase .= '_'.$counter;
}
$width = 0;
$height = 0;
if($fileType == "images")
{
	$thumbCreated = true;
	//createThumbFromCenter($path.$base.'.'.$extension,$thumbpath,$thumbase,$thumbextension,250,250);
	//createsquarethumb($path.$base.'.'.$extension,$thumbpath,$thumbase,$thumbextension,300);
	$temp = getimagesize($path.$base.'.'.$extension);
	$width = $temp[0]; $height = $temp[1];
}
$playtime = 0;

//try xmp	
$tmp = array();

$size = shell_exec("ls -s " . $path.$base.'.'.$extension) *1024;
$out = array();	
$out["name"] = $base.'.'.$extension;
$out["extension"] = $extension;
$out["size"] = $size;
$out["width"] = $width;
$out["height"] = $height;
if($thumbCreated)
	$out["thumb"] =  $thumbase.'.'.$thumbextension;
else
	$out["thumb"] = '';
if($videoProxy)
	$out["video_proxy"] = $thumbase . ".flv";
else
	$out["video_proxy"] = false; 
$out["playtime"] = $playtime;
//$out["tags"] = $tags;	

	header("Content-type: application/json; charset=UTF-8");
	echo json_encode($out);
?>