<?php

// ADD CUSTOM FUNCTIONS TO THIS FILE!

// Be sure to add your function name to $customFunctions!!

$customFunctions = array("deleteDataset","createDataset","addCountryToDataset","updateDatasetRow","listFlags","cleanup","countWords","getLinks","deleteClient");


function deleteClient($params) {

	if(isset($params['id']))
	{
		$sql = "SELECT tablename FROM `datasets` ";
		$sql .= " WHERE contentid = :contentid";
		$sendParams['contentid'] = $params['id'];
		$tables = array();
		if($result = queryDatabase($sql,$sendParams)) {
			while ($row = $result->fetch(PDO::FETCH_OBJ))
       		{
            	array_push($tables, $row->tablename);
        	}
			$sql = "DELETE FROM `content`";
			$sql .= " WHERE id = :id";
			$sendParams = array();
			$sendParams['id'] = $params['id'];
			if($result = queryDatabase($sql,$sendParams)) {
				if(count($tables) > 0) {
					$sql = "DROP TABLE ";
					foreach($tables as $table)
						$sql .= "`". $table ."`,";
					$sql = substr($sql,0,strlen($sql)-1); 
					if($result = queryDatabase($sql)) 
						sendSuccess();
					else die("Query Failed: " . $result->errorInfo());
				}
				else sendSuccess();
			}
			else die("Query Failed: " . $result->errorInfo()); 
		}
		else die("Query Failed: " . $result->errorInfo());
	}
	else die ("No id provided.");	
}


function listFlags($params) {
	$sql = "SELECT content.migtitle,content.id FROM content WHERE content.templateid='4'";
	$resultList = array();
	if($result = queryDatabase($sql)) {
		while ($row = $result->fetch(PDO::FETCH_OBJ))
        {
            array_push($resultList, $row);
            //print_r(mixed expression [, bool return])
        }
	}
	$names = array();
	foreach($resultList as $row) {
		$sql = "SELECT media.id,media.name FROM media WHERE media.name LIKE '%".  strtolower(addslashes($row->migtitle)). "%'";
		//echo $sql;
		if($result = queryDatabase($sql)) {
			while ($row2 = $result->fetch(PDO::FETCH_OBJ))
        	{
        		$r = array();
        		$r["name"] = $row->migtitle;
        		$r["contentid"] = $row->id;
        		$r["mediaid"] = $row2->id;
        		$r["file"] = $row2->name;
        		array_push($names,$r);
        	}
		}
	}
/*
	header("Content-type: application/json; charset=UTF-8");
	echo json_encode($names);
*/
	$sql = "INSERT INTO content_media (contentid,mediaid,statusid) VALUES ";
	foreach($names as $r) {
		$sql .=  "(".$r["contentid"].",".$r["mediaid"].",4),";
	}
	echo $sql;
}
function addCountryToDataset($params)
{
	$action = $params['action'];
	$result = $action($params);
	
	$sql = "SELECT datasets.name FROM datasets WHERE contentid='" . $params['contentid'] . "'";
	$result = queryDatabase($sql);
	
	if ($result)
    {
    	while ($row = $result->fetch(PDO::FETCH_OBJ))
        {

			$params2 = array();
			$params2["action"] = "insertRecord";
			$params2["tablename"] = $row->name;
			
		}
	}
}
function deleteDataset($params)
{
	if(isset($params['tablename']) && isset($params['id'])) {
		//delete row from `dataset` table
		$sendParams = array();
		$sql = "DELETE FROM `datasets` ";
		$sql .= " WHERE id = :id";
		$sendParams['id'] = $params['id'];	
		if($result = queryDatabase($sql,$sendParams)) 
		{	
	
			$sql = "DROP TABLE `" . $params['tablename'] . "`";
			if($result = queryDatabase($sql))
				sendSuccess();
			else die("Query Failed: " . $result->errorInfo());			
		}
		else die("Query Failed: " . $result->errorInfo());			
	}
	else die ("Missing parameters");
}

function createDataset($params)
{
	if(isset($params['contentid']) && isset($params['tablename']) && isset($params['type']) && isset($params['time']))
	{
		$tablename = $params['tablename'];	
		$sendParams = array();

			
		$sql = "INSERT into `datasets` (`contentid`,`tablename`,`type`,`time`,`options`,`range`,`multiplier`,`unit`,`name`,`createdby`,`modifiedby`) VALUES (";

		$sql .= ":contentid,";
		$sendParams['contentid'] = $params['contentid'];
				
		$sql .= ":tablename,";
		$sendParams['tablename'] = $tablename;
		
		$sql .= ":type,";
		$sendParams['type'] = $params['type'];
		
		$sql .= ":time,";
		$sendParams['time'] = $params['time'];
		
		$sql .= ":options,";
		$sendParams['options'] = $params['options'];

		$sql .= ":range,";
		if($params['time'] == 1)
			$sendParams['range'] = $params['years'];		
		else
			$sendParams['range'] = '';
			
		$sql .= ":multiplier,";
		$sendParams['multiplier'] = $params['multiplier'];
		
		$sql .= ":unit,";
		$sendParams['unit'] = $params['unit'];
			
		$sql .= ":name,";
		$sendParams['name'] = $params['name'];
		
		$sql .= ":createdby,";
		$sendParams['createdby'] = $params['createdby'];
			
		$sql .= ":modifiedby";
		$sendParams['modifiedby'] = $params['modifiedby'];

		$sql .=')';
		
		if($result = queryDatabase($sql,$sendParams,$datasetid)) 
		{
				
		}
		else die("Query Failed: " . $result->errorInfo());

		if($params['type'] == 1)  
		 	$type = "decimal(25,15)";
		 else $type = "varchar(255)";
		
		$sql = "CREATE TABLE `". $tablename ."` ( 
				`id` int(11) NOT NULL auto_increment, 
				`countryid` int(11) NOT NULL, ";		
		if($params['time'] == 1)
		{
			$years = explode(",", $params['years']);
			foreach ($years as $year)
			{
				$sql .= "`".$year."` ". $type . " default NULL,";
			}
		}
		else
		{
			$sql .= "`value` " .$type. " default NULL,";
		}
		$t = time();	
		$sql .= "PRIMARY KEY (`id`),  
				 KEY `". $t ."_countryid_fk` (`countryid`),
				 CONSTRAINT `". $t ."_countryid_fk` FOREIGN KEY (`countryid`) REFERENCES `content` (`id`) ON DELETE CASCADE ON UPDATE CASCADE) ENGINE=InnoDB  DEFAULT CHARSET=latin1";
				 
		if($result = queryDatabase($sql)) 
		{
			if($params['countryids'] != '') {
				$countryids = explode(",", $params['countryids']);
				$sql = "INSERT INTO `" . $tablename . "` (`countryid`)";
				$sql .= " VALUES ";
				foreach ($countryids as $countryid) {
					$sql .= "('".$countryid."'),";
				}
				$sql = substr($sql,0,strlen($sql)-1); 
				if($result = queryDatabase($sql)) {
					sendSuccess($datasetid.','.$tablename);
				}
				else die("Query Failed: " . $result->errorInfo());
			}
			else sendSuccess($datasetid.','.$tablename);
		}
		else die("Query Failed: " . $result->errorInfo());
	}
	else die("Missing Parameters");
}
function updateDatasetRow($params) //+
{

	$numParamsToUpdate = 0; // counts num of params to update.
	$sendParams = array();

	// make sure we have a content id and tablename
	if (isset($params['countryid']) && isset($params['tablename'])) {

		// gets array of fields name for 'tablename'
		$columnsArray = getTableColumns($params['tablename']);
			
		$sql = "UPDATE `".$params['tablename']."` SET ";
		foreach ($params as $key=>$value) {

			if ($key != 'action' && $key != 'countryid' && $key != 'tablename' && $key != 'tags' && $key != 'verbosity') {
				$numParamsToUpdate++;
					
				if (in_array($key, $columnsArray)) // checks for misspelling of field name
				{
					$sql .= "`".$key . "` = :".$key.", ";
					$sendParams[$key] = processText($value);	
				} 
				else die("Unknown field name '$key'.");
			}
		}

		if ($numParamsToUpdate==0) { //no other name/value pairs provided
			die("No name/value pairs provided to update.");
		}
		else {
			// remove last comma and space!
			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " WHERE countryid = :countryid";
			$sendParams['countryid'] = $params['countryid'];
		}
	} else die("No id or tablename provided.");
	if ($numParamsToUpdate > 0) {
		//echo $sql;
		//print_r($sendParams);
		if($result = queryDatabase($sql, $sendParams))
		 	sendSuccess();
	}
}



function cleanup($params) {
	
	$sql = "SELECT GROUP_CONCAT(id) as ids, countryid,COUNT(countryid) FROM `hsbc_world_alcohol_consumption_2003` GROUP BY countryid ORDER BY countryid";
	if($result = queryDatabase($sql)) {
		while ($row = $result->fetch(PDO::FETCH_OBJ)) {
			$arr = explode(",",$row->ids);
			if(count($arr) > 1) {
				//echo $row->ids. "    " . $arr[1] . "<br>";
				$sql = "DELETE FROM `hsbc_world_alcohol_consumption_2003` WHERE id='".$arr[1] ."'";
				queryDatabase($sql);
			}
		}
	}
	
}

function countWords($params) {
	$file_content = $params["text"];
	$words = (array_count_values(str_word_count(strtolower ($file_content),1)));
	$twords = ( str_word_count(strtolower ($file_content),1));

	$warr = array();
 
	foreach ($words as $key=>$val) {
		$w = array();
		$w["count"] = $val;
		$w["word"] = $key; 
		$warr[] = $w;
 	}
    
	$unique_words = count($words);
	$total_words = count($twords);

	usort($warr,"cmp");
	$warr = array_reverse($warr);
	header("Content-type: application/json; charset=UTF-8");
	echo json_encode($warr);	
}
function getLinks($params) {
	preg_match_all("/http:\/\/(www\.)?([^.]+\.[^.\s]+\.?[^.\s]*)/i", $params["text"], $matches);
	$all_urls = $matches[0];
    $all_urls = array_count_values($all_urls);
    $links = array();
    foreach($all_urls as $key=>$value) {
    	$link= array();
    	$link["value"] = $key;
    	$link["count"] = $value;
    	$links[] = $link;
    }  
    header("Content-type: application/json; charset=UTF-8");
	echo json_encode($links);
}
function cmp($a, $b)
{

    if ($a["count"] == $b["count"]) {
        return 0;
    }
    return ($a["count"] < $b["count"]) ? -1 : 1;
}


?>