<?php
$header[] = "Content-type: text/xml";

// create a new cURL resource
$q = $_GET['q'];
$ch = curl_init( "http://google.com/complete/search?output=toolbar&q=".$q );

// set Return Transfer, Timout and Htttp Header
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HTTPHEADER, $header);

//curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);

// grab URL and pass it to the browser
$xmlData = curl_exec($ch);

if (curl_errno($ch)) {
	echo curl_error($ch);
} else {
	curl_close($ch);
	header("Content-type: text/xml");
	echo $xmlData;
}
?>