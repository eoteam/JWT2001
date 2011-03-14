<?php

/**
 * execute.php is a generic file which looks up the function it
 * should call in the read/write function files. The results from
 * the function are serialized as XML and returned to the application
 */

require_once "readFunctions.php";
require_once "writeFunctions.php";
require_once "fileFunctions.php";
require_once "customFunctions.php";
require_once "includes/functions.php";
require_once "config/constants.php";
// get any parameters that were passed in the post 

if (isset($_GET['mode']) && $_GET['mode'] == 'test') { // this is a test mode for passing params via GET

	$postData = $_GET;
	unset($postData['mode']);
	
} else {

	$postData = $_POST;
}
	

// iterate through the array, cleaning data as we go!

$params = array();

// escape all post data, for security!

foreach ($postData as $key=>$value) {
	//echo $key;
	if ($key != 'submit')  //???
		 	$params[$key] = addslashes($value);
	if($params[$key] == 'NULL') {
		$value = NULL;
	}
}
// append custom functions to vaildActions array!

$validActions = array_merge($validReadFunctions,$validWriteFunctions);
$validActions = array_merge($validActions,$validFileFunctions);
$validActions = array_merge($validActions,$customFunctions);

// if we don't have a valid function, quit
if (!isset($params['action']) || !in_array($params['action'],$validActions))
{
    die("Invalid Action Specified.");
}

// get the result from the query_function
$action = $params['action'];
$result = $action($params);

//output the serialized xml
ouputMySQLResults($result);
?>
