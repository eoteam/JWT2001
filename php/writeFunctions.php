<?php
require_once "readFunctions.php";


function insertCustomField($params) 
{
	global $creationColumns;
	if (isset($params['tablename']) && isset($params["tablename2"])) {
		
		$columnsArray = getTableColumns($params['tablename']);
		$cfColumnsArray = getTableColumns('customfields');	
		$commandFields = array("action","tablename","tablename2");
		
		$sendParams = array();
		
		if(!isset($params["customfieldid"])) {
						
			$sql = "INSERT INTO `customfields` ";
			$sql .= "(";

			foreach ($params as $key=>$value) {
				if (!in_array($key,$commandFields) && !in_array($key,$columnsArray) && !in_array($key,$creationColumns)) {
					if (in_array($key, $cfColumnsArray)) // checks for misspelling of field name
						$sql .= $key . ",";
					else die("Unknown field name '$key'.");
				}
			}
			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .= ")";
	
			// put values into SQL
			$sql .= " VALUES (";

			foreach ($params as $key=>$value) {
				if (!in_array($key,$commandFields) && !in_array($key,$columnsArray)) {
					$sql .= ":".$key.",";
					$sendParams[$key] = processText($value);
				}
			}
			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .=")";
		
			if ($result = queryDatabase($sql,$sendParams,$customfieldid)) {
				
				$sql = "SELECT sqltype FROM customfieldtypes WHERE id = " . $params["typeid"];
				if($result = queryDatabase($sql)) {
					$row = $result->fetch(PDO::FETCH_OBJ);
					$sqltype = $row->sqltype;
				}
				else die("Query Failed: " . $result->errorInfo());
				
				if(isset($params["tablename2"]))
					$tablename = $params["tablename2"];
				else
					$tablename = $params["tablename"];
				$sql = "ALTER TABLE `". $tablename . "` ADD `". $params["name"] ."` ". $sqltype ." NOT NULL";
				if ($result = queryDatabase($sql))
					$ok = true;	
				else die("Query Failed: " . $result->errorInfo());	
			}
			else die("Query Failed: " . $result->errorInfo());
		}
		else 
			$customfieldid = $params["customfieldid"];
			
		$sendParams = array();
		$sql = "INSERT INTO `".$params['tablename']."` ";
		$sql .= "(";

		foreach ($params as $key=>$value) {
			if (!in_array($key,$commandFields) && !in_array($key,$cfColumnsArray)) {
				if (in_array($key, $columnsArray)) // checks for misspelling of field name
					$sql .= $key . ",";
				else die("Unknown field name '$key'.");
			}
		}
		if(isset($params['customfieldid'])) {
			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .=")";
		}
		else {
			$sql .= "customfieldid)";
		}

		// put values into SQL
		$sql .= " VALUES (";
		foreach ($params as $key=>$value) {
			if (!in_array($key,$commandFields) && !in_array($key,$cfColumnsArray) && in_array($key,$columnsArray)) {
				$sql .= ":".$key.",";
				$sendParams[$key] = processText($value);
			}
		}
		if(isset($params['customfieldid'])) {
			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .=")";	
		}
		else {
			$sql .= ":customfieldid)";
		}
		$sendParams['customfieldid'] = 	$customfieldid;
		//print_r($sendParams). "<br><br>";
		//echo $sql;
		if ($result = queryDatabase($sql,$sendParams,$insertid)) {
			sendSuccess($insertid.','.$customfieldid);
		}
		else die("Query Failed: " . $result->errorInfo());
	}
	else 
		die ("No id or tablename provided.");

}
function updateCustomField($params)
{
	global $creationColumns;
	if(isset($params['tablename'])) {
		$commandFields = array("action","tablename","tablename2","id");
		if(isset($params['id']) && isset($params['customfieldid']))
		{
			if(isset($params['name'])) {
				$sql = "SELECT name FROM customfields WHERE id = :id ";
				$sendParams['id'] = $params['customfieldid'];
				$result = queryDatabase($sql,$sendParams);
				$row = $result->fetch(PDO::FETCH_OBJ);
				$oldname = $row->name;
				
				$sql = "SHOW COLUMNS FROM ". $params['tablename2'] ." where Field = '" . $oldname."'";
				$result = queryDatabase($sql);
				$row = $result->fetch(PDO::FETCH_OBJ);
				$type = $row->Type;
								
				$sql = "ALTER TABLE ". $params['tablename2'] . " CHANGE `".$oldname."` `".$params['name']."` ". $type ." NOT NULL";
				$result = queryDatabase($sql);
			}
			
			$columnsArray = getTableColumns($params['tablename']);
			$cfColumnsArray = getTableColumns('customfields');

			$sendParams = array();
			$sql = "UPDATE ". $params['tablename']  ." SET ";
			foreach ($params as $key=>$value)
			{
				if (!in_array($key,$cfColumnsArray) && !in_array($key,$commandFields))
				{
					if (in_array($key, $columnsArray)) // checks for misspelling of field name
					{
						$sql .= $key . " = :".$key.", ";
						
						$sendParams[$key] = processText($value);
					}
					else die("Unknown field name '$key'.");
				}
			}
			$sql = substr($sql,0,strlen($sql)-2);
			$sql .= " WHERE id = :id";
			$sendParams['id'] = $params['id'];
			
			if($result = queryDatabase($sql, $sendParams))
			{
				$columnsTermTaxArray = getTableColumns('customfields');
				$sendParams = array();
				$sql  = " UPDATE `customfields` SET ";
				foreach ($params as $key=>$value)
				{
					if (!in_array($key,$commandFields)  && !in_array($key,$creationColumns) && !in_array($key,$columnsArray) )
					{
						if (in_array($key, $cfColumnsArray)) // checks for misspelling of field name
						{
							$sql .= $key . " = :".$key.", ";
							$sendParams[$key] = processText($value);
						}
						else die("Unknown field name '$key'.");
					}
				}
				$sql = substr($sql,0,strlen($sql)-2);				
				$sql .= " WHERE id = :id";
				if(count($sendParams) > 0) {	
					$sendParams['id'] = $params['customfieldid'];
				
					if($result = queryDatabase($sql, $sendParams)) {
						sendSuccess();
					} 
					else die("Query Failed: " . $result->errorInfo());
				}
				else sendSuccess(); 
			}	 
			else die("Query Failed: " . $result->errorInfo());			
		}
		else die("No id or customfieldid provided");
	}
	else {
		die("No tablename provided");
	}
}
function deleteCustomField($params) //+
{
	$sendParams = array();
	if(isset($params["customfieldid"]) && isset($params["tablename2"]))
	{
		//remove the column from table2
		$sql = "SELECT name FROM customfields WHERE id = :id ";
		$sendParams['id'] = $params["customfieldid"];
		if($result = queryDatabase($sql, $sendParams));
		else die("Query Failed: " . $result->errorInfo()); 
		
		if($result->rowCount() > 0 ) {
			$row = $result->fetch(PDO::FETCH_OBJ);
			$column = $row->name;
		
		
			$sql = "ALTER TABLE " . $params['tablename2'] . " DROP " . $column;		
			if($result = queryDatabase($sql));
			else die("Query Failed: " . $result->errorInfo()); 
		
			$sql = "DELETE FROM customfields WHERE id = :id ";
			$sendParams['id'] = $params['customfieldid'];
			if($result = queryDatabase($sql, $sendParams))
				sendSuccess();		 
			else die("Query Failed: " . $result->errorInfo()); 		
		}
		else sendSuccess();
	}
	
	else if(isset($params['id']) && isset($params['tablename']))
	{
		
		$sql = "DELETE FROM " . $params["tablename"] . " WHERE id = :id ";
		$sendParams['id'] = $params['id'];
		if($result = queryDatabase($sql, $sendParams))
			sendSuccess();		 
		else die("Query Failed: " . $result->errorInfo()); 	
	}
	 
	else 
		die ("No id or tablename provided.");
}




function updateTag($params) 
{
	/*
		* Script will attempt to update tag at table 'term_taxonomy' by id or at table 'terms' by termid
		* You will get an error if you provided invalid field names.

		** REQUIRED PARAMS
		id - primary key of the record to update from 'term_taxonomy' table
		termid - primary key of the record to update from 'terms' table

		** OTHER PARAMS
		name/value pairs to update:
		- name
		- parentid
		- description
		- color
		- date1
		- date2
		- displyorder
		*/

	// gets arrays of field names for tables 'terms' and 'term_taxonomy'
	$columnsTermTaxArray = getTableColumns('term_taxonomy');

	if(isset($params['id']) && isset($params['termid']))
	{
		$sendParams = array();
		$sql = "UPDATE `term_taxonomy` SET ";
		foreach ($params as $key=>$value)
		{
			if ($key != 'action' && $key != 'id' && $key != 'name' && $key != 'slug')
			{
				if (in_array($key, $columnsTermTaxArray)) // checks for misspelling of field name
				{
					$sql .= $key . " = :".$key.", ";
					$sendParams[$key] = processText($value);
				}
				else die("Unknown field name '$key'.");
			}
		}
		// remove last comma and space!
		$sql = substr($sql,0,strlen($sql)-2);
		$sql .= " WHERE id = :id";
		$sendParams['id'] = $params['id'];

		if($result = queryDatabase($sql, $sendParams))
		{
			if(isset($params['name']))
			{
				$sendParams = array();
				$sql  = " UPDATE `terms` SET ";
				$sql .= " name = :name, slug = :slug ";
				$sql .= " WHERE id = :termid";

				$sendParams['name'] = processText($params['name']);
				$sendParams['slug'] = generateSlug($params['name']);
				$sendParams['termid'] = $params['termid'];
					
				if($result = queryDatabase($sql, $sendParams)) {
					sendSuccess();
				} else die("Query Failed: " . $result->errorInfo());
			} else sendSuccess();
		} else die("Query Failed: " . $result->errorInfo());
	} else die("No id or termid is provided.");
}

function updateRecord($params) //+
{
	/*
		* Script will attempt to update multiple fields (name/value pairs) of one record by id.
		* You will get an error if you provided invalid field names.

		** REQUIRED PARAMS
		tablename - name of the table to update
		id - primary key of the record to update

		** OTHER PARAMS
		verbosity - (1 = ids + titles only, 2 - all fields + named custom fields, 3 - all fields)
		name/value pairs to update - field names from 'tablename'
		if a param is sent called 'password' it will automatically be encrypted.
		*/

	$numParamsToUpdate = 0; // counts num of params to update.
	$sendParams = array();

	// make sure we have a content id and tablename
	if (isset($params['id']) && isset($params['tablename'])) {

		// gets array of fields name for 'tablename'
		$columnsArray = getTableColumns($params['tablename']);
			
		$sql = "UPDATE `".$params['tablename']."` SET ";
		foreach ($params as $key=>$value) {

			if ($key != 'action' && $key != 'id' && $key != 'tablename' && $key != 'tags' && $key != 'verbosity') {
				$numParamsToUpdate++;
					
				if (in_array($key, $columnsArray)) // checks for misspelling of field name
				{
					if ($key == 'password') {
						$sql .= "`".$key . "` = :".$key.", ";
						$sendParams[$key] = text_crypt($value);
					}
					else {
						$sql .= "`".$key . "` = :".$key.", ";
						$sendParams[$key] = processText($value);
					}
				} else die("Unknown field name '$key'.");
			}
		}

		if ($numParamsToUpdate==0) { //no other name/value pairs provided
			die("No name/value pairs provided to update.");
		}
		else {
			// remove last comma and space!
			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " WHERE id = :id";
			$sendParams['id'] = $params['id'];
		}
	} else die("No id or tablename provided.");
	if ($numParamsToUpdate > 0) {
		$result = queryDatabase($sql, $sendParams);
	}
		
	//if ($params['tablename'] == "content") {
	//	updateContainerPaths($params['id'],null); // updates 'containerpath' field
	//}

	if (isset($params['verbosity']))
	{
		$params2['verbosity'] = $params['verbosity'];
		$params2['contentid'] = $params['id'];
		$result = getContent($params2);

		// output the serialized xml
		return $result;
	}
	else sendSuccess();
}

function updateRecords($params) //+
{
	/*
		* Script will attempt to update one field (updatefield/updatevalue) of multiple records by idfield/idvalues (comma-delimited) and other name/value pair parameters.
		* You will get an error if you provided invalid field names.

		** REQUIRED PARAMS
		tablename - name of the table to update
		updatefield - name of the field to update
		updatevalue - value of the field to update
		idfield - name of the parameter to specify records
		idvalues - values of idfield; expects formatted id string (id,id,id)

		** OTHER PARAMS
		* name/value pairs to specify records to update; should be field names from 'tablename'
		* verbosity - (1 = ids + titles only, 2 - all fields + named custom fields, 3 - all fields)
		*/

	/* examples:
	 * action=updateRecords & tablename=comments & updatefield=statusid & updatevalue=4 & idfield=id & idvalues=1,2,3,4
	 * action=updateRecords & tablename=media_terms & updatefield=termid & updatevalue=7 & idfield=contentid & idvalues=4,5
	 */

	$sendParams = array();

	// gets array of fields name for 'tablename'
	$columnsArray = getTableColumns($params['tablename']);

	// make sure we have a content id and tablename
	if (isset($params['tablename']) && isset($params['idfield']) && isset($params['idvalues']) && isset($params['updatefield']) && isset($params['updatevalue'])) {
		$sql = "UPDATE `".$params['tablename']."` SET ";

		if (in_array($params['updatefield'], $columnsArray)) // checks for misspelling of field name
		$sql .= $params['updatefield']." = :updatevalue ";
		else die("Unknown field name '".$params['updatefield']."'.");

		if (in_array($params['idfield'], $columnsArray)) // checks for misspelling of field name
		$sql .= " WHERE ".$params['idfield']." IN ( ";
		else die("Unknown field name '".$params['idfield']."'.");
			
		// $params['idvalues'] can be comma-delimited
		$manyvalues = explode(",",$params['idvalues']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
			
		$sql .= " )";
		$sendParams['updatevalue'] = $params['updatevalue'];
	} else {
		die("No tablename or idfield/idvalue or updatefield/updatevalue parameters provided.");
	}

	foreach ($params as $key=>$value)
	{
		if ($key != 'action' && $key != 'tablename' && $key != 'updatefield' && $key != 'updatevalue' && $key != 'idfield' && $key != 'idvalues') {
			if (in_array($key,$columnsArray)) {
				$sql .= " AND " . $key . " = :".$key;
				$sendParams[$key] = $value;
			} else die("Unknown field name '$key'.");
		}
	}
	
	// get the results
	if ($result = queryDatabase($sql, $sendParams)) {
//		if ($params['tablename'] == "content") {
//			updateContainerPaths($params['id'],null); // updates 'containerpath' field
//		}

		if (isset($params['verbosity'])) {
			$params2['verbosity'] = $params['verbosity'];
			$params2['contentid'] = $params['id'];
			$result = getContent($params2);

			// output the serialized xml
			return $result;
		}
		else sendSuccess();
	} else die("Query Failed: " . $result->errorInfo());
}

function updateMediaByPath($params) //+
{
	/*
		* Script will attempt to replace 'oldpath' parameter with 'newpath' parameter in table 'media'

		** REQUIRED PARAMS
		oldpath
		newpath
		*/

	if (isset($params['oldpath']) && isset($params['newpath'])) {
		$sendParams = array();
		$sql = "UPDATE `media` ";
		$sql .= " SET `path` = REPLACE(`path`, :oldpath, :newpath)";
		$sendParams['oldpath'] = $params['oldpath'];
		$sendParams['newpath'] = $params['newpath'];
	} else die("Missing path parameters: oldpath and newpath are not provided.");

	// get the results
	if ($result = queryDatabase($sql, $sendParams)) {
		sendSuccess();
	} else die("Query Failed: " . $result->errorInfo());
}

function updateContainerPaths($params, $insertid) //+
{
	/*
		* Helper for updateRecord and insertRecord (for 'content' table).
		* Script will attempt to update field 'containerpath' at 'content' table

		** REQUIRED PARAMS

		** OTHER PARAMS
		id - could be comma-delimited list
		*/

	$sendParams = array();
	$sql = "SELECT id FROM content";

	if (isset($params['id'])) {
		$sql .= " WHERE id IN ( ";

		$manyvalues = explode(",",$params['id']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	} else $sql .= " WHERE id IN ($insertid)";

	$result = queryDatabase($sql, $sendParams);

	while ($row = $result->fetch(PDO::FETCH_ASSOC)) {

		// get the tree path to this piece of content!

		$row2['id'] = $row['id'];
		$strPath = "";
		do {
			$sql = "SELECT U2.migtitle AS parent, U2.id AS id, U2.parentid AS parentid
				FROM content AS U1
				LEFT JOIN content AS U2 ON U2.id = U1.parentid
				WHERE U1.id = '".$row2['id']."'";

			$result2 = queryDatabase($sql);
			$row2 = $result2->fetch(PDO::FETCH_ASSOC);

			$strPath = $row2['parent'] . "<>" . $strPath;
		}
		while ($row2['id'] != '1');
			
		// remove last comma!
		$strPath = substr($strPath,0,strlen($strPath)-2);

		if ($strPath)
		{
			$sql = "UPDATE content SET containerpath = '" . $strPath . "' WHERE id = '".$row['id']."'";
			queryDatabase($sql);
		}
	}
	return $strPath;
}
function updateContentAndRevision($params) 
{
		/*

		* Script will attempt to update multiple fields (name/value pairs) 
		* of the record in the table `content` by provided id
		* and make the revision of it 
		* only if provided modifying fields are customfields
		* otherwise the updateRecord() function will be called with provided parameters

		** REQUIRED PARAMS
		id - primary key of the record to make a revision of 

		** OTHER PARAMS
		name/value pairs to update

		*/
	
	$customfieldsArray = array(); // array of rows of 'name' fields from 'customfields' table 

	// make sure we have a content id
	if (isset($params['id'])) {
		$sql = "SELECT name FROM customfields WHERE groupid='1'";
		$result = queryDatabase($sql);
		if($result->rowCount() > 0 ) {
			while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
				$customfieldsArray[] = $row['name'];
			}
		} else die("No customfields.");
		
		$countModifFields = 0;
		// checks if at least one modified field is a field at 'customfields' table
		foreach ($params as $key=>$value) {
			if (in_array($key, $customfieldsArray)) {
				$countModifFields++; 
			}
		}
		
		$params['tablename'] = "content";
		
		if ($countModifFields == 0) { // no fields from 'customfields' table 
			updateRecord($params); // so no need to make revision -> call updateRecord function
		} 
		else { // at least one field to mogify from 'customfields' table -> make revision 
			
			// 1. duplicate the modifying row
			$autoIncrementContent = getAutoIncrement('content'); // get auto-increment for the new record
			duplicateRows('content','id',$params['id'],$autoIncrementContent);
						
			// 2. update old row (always not a revision) :
			// 	a. change modifieddate using time()
			// 	b. plus the rest of $params (modifying fields) 
			$params['modifieddate'] = time();
			updateRecord($params);
			
			// 3. update new duplicated row (which is new revision) : 
			// 	a. change is_revision to '1' (true)
			// 	b. set $params['id'] to $autoIncrementContent
			$paramsUpd = array();
			$paramsUpd['tablename'] = $params['tablename'];
			$paramsUpd['id'] = $autoIncrementContent;
			$paramsUpd['is_revision'] = "1";
			updateRecord($paramsUpd);

			sendSuccess();
		}
	} else die("No id provided.");
}
function revertRevision($params)
{
		/*

		* Script will attempt to revert to the content record by revertid

		** REQUIRED PARAMS
		id - primary key of non-revision record 
		revertid - primary key of the record to be reverted back instead of non-revision record
		
		*/
	
	// make sure we have a content id of the non-revision   
	if (isset($params['id']) && isset($params['revertid'])) {
		
		// 1. duplicate the record by provided id and set the id of the new record to $autoIncrementContent
		$autoIncrementContent = getAutoIncrement('content'); // get auto-increment for the new record
		duplicateRows('content','id',$params['id'],$autoIncrementContent);
		
		// 2. make the revision of the duplicated record :
		//	a. change is_revision to '1' 
		$paramsUpd = array();
		$paramsUpd['tablename'] = "content";
		$paramsUpd['id'] = $autoIncrementContent;
		$paramsUpd['is_revision'] = '1';
		updateRecord($paramsUpd);

		// 3. copy all the fields of revertid record to id record
		// and change is_revision to '0'
		$sql = "SELECT content.* from `content` WHERE id = " . $params['revertid'];
		$result = queryDatabase($sql);
		$rows = $result->fetch(PDO::FETCH_ASSOC);
		
		foreach ($rows as $key=>$value) {
			if (($key != 'id') && ($key != 'is_revision')) {
				$rowsUpd[$key] = $value;
			}
		}
		$rowsUpd['tablename'] = "content";
		$rowsUpd['id'] = $params['id'];
		$rowsUpd['is_revision'] = '0';
		$rowsUpd['modifieddate'] = time();
		updateRecord($rowsUpd);
		
		// 4. delete the record by provided revertid
		$sql = "DELETE FROM `content` WHERE id = " .$params['revertid'];
		if (!$result2 = queryDatabase($sql))
		die("Query Failed: " . $result2->errorInfo());		
		
		sendSuccess();
		
	} else die("No id provided.");
}

function insertTag($params) //+
{
	/*
		* Script will attempt to insert tag to 'terms' and 'term_taxonomy' tables
		* You will get an error if you provided invalid field names.

		** REQUIRED PARAMS
		name - tag name
		taxonomy - 'tag' or 'category' only

		If taxonomy = 'tag' then :
		1. check 'terms'
		2. if tag does exist in 'terms' then get tag id from 'terms' and insert new record into 'term_taxonomy' with existent id and taxonomy = 'tag'
		3. if tag doesn't exist in 'terms' then insert it into 'terms' and then into 'term_taxonomy' with new id

		If taxonomy = 'category' then :
		1. check 'terms'
		2. if tag does exist in 'terms' then get tag id from 'terms' and insert new record into 'term_taxonomy' with existent id and taxonomy = 'category'
		3. if tag doesn't exist in 'terms' then insert it into 'terms'
		3a. then insert two records into 'term_taxonomy' - first one with taxonomy = 'category' and second one with taxonomy = 'tag'
			
		** OTHER PARAMS
		verbose - for displaying results (true = display ids only, false - all fields from 'term_taxonomy')
		name/value pairs to set parameters for the tag :
		- slug
		- parentid (optional) - if doesn't exist then parentid = id = autoincrement
		- description
		- color
		- date1
		- date2
		- displyorder
		*/

	if (isset($params['name']) && isset($params['taxonomy']) && ($params['taxonomy']=='tag' || $params['taxonomy']=='category'))
	{
		// gets array of field names for the table 'term_taxonomy'
		$columnsArray = getTableColumns('term_taxonomy');

		// checks whether tag is already exist in the table 'terms'
		$sendParams = array();
		$slug = generateSlug($params['name']); // generate the slug using Name parameter

		$sql = "SELECT id FROM `terms` WHERE slug = :slug";
		$sendParams['slug'] = $slug;

		$result = queryDatabase($sql,$sendParams);
		$isnewtag = false; // false if tag does exist in 'terms'

		if ($result->rowCount() > 0) { 	// tag does exist in 'terms'
			$row = $result->fetch(PDO::FETCH_ASSOC);
			$idTerms = $row['id']; // get term id
		}
		else // tag doesn't exist in 'terms'
		{
			$sendParams = array();

			// get auto-increment for the new record
			$autoIncrementTerms = getAutoIncrement('terms');

			// insert into 'terms'
			$sql = "INSERT INTO `terms` (id,name,slug) VALUES (:id,:name,:slug)";
			$sendParams['name'] = processText($params['name']);
			$sendParams['id'] = $autoIncrementTerms;

			if (isset($params['slug'])) {
				$sendParams['slug'] = processText($params['slug']);
			}
			else {
				$sendParams['slug'] = $slug;
			}

			if ($result = queryDatabase($sql,$sendParams))
			{
				$isnewtag = true; // changes to true if tag didn't exist before
				$idTerms = $autoIncrementTerms; // set term id as auto-increment
			} else die("Query Failed: " . $result->errorInfo());
		}
			
		// if 'taxonomy' parameter is equal to 'tag'
		if ($params['taxonomy']=="tag") {

			// insert one record to 'term_taxonomy'

			$sendParams = array();
			$sql = "INSERT into `term_taxonomy` (id,parentid,termid,";
			foreach ($params as $key=>$value) {
				if ($key != 'action' && $key != 'parentid' && $key != 'name' && $key != 'slug' && $key != 'parentid' && $key != 'termid' && $key != 'verbose') {
					if (in_array($key, $columnsArray)) { // checks for misspelling of field name
						$sql .= $key.",";
					} else die ("Unknown field name '$key'.");
				}
			}

			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .= ")";

			// put values into SQL
			$sql .= " VALUES (";

			// get auto-increment for the new record
			$autoIncrementTermTax = getAutoIncrement('term_taxonomy');

			$sql .= "'".$autoIncrementTermTax."',"; // id

			if (isset($params['parentid'])) { // if parentid is set
				$sql .= "'".$params['parentid']."',"; // parentid
			} else {
				// if parentid is not set then parentid = id
				$sql .= "'".$autoIncrementTermTax."',";
			}

			$sql .=  "'".$idTerms."',"; // termid

			foreach ($params as $key=>$value) {
				if ($key != 'action' && $key != 'id' && $key !='name' && $key != 'slug' && $key != 'parentid' && $key != 'termid' && $key != 'verbose') {
					$sql .= ":".$key.",";
					$sendParams[$key] = processText($value);
				}
			}

			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .=")";

		} // if 'taxonomy' parameter is equal to 'category'
		else if ($params['taxonomy']=="category") {

			// insert records to 'term_taxonomy':
			// first with taxonomy = 'category', ALWAYS
			// second with taxonomy = 'tag', ONLY IF tag doesn't exist in 'terms'

			$sendParams = array();
			$sql = "INSERT into `term_taxonomy` (id,parentid,termid,taxonomy,";
			foreach ($params as $key=>$value) {
				if ($key != 'action' && $key != 'parentid' && $key != 'name' && $key != 'slug' && $key != 'parentid' && $key != 'termid' && $key != 'taxonomy' && $key != 'verbose') {
					if (in_array($key, $columnsArray)) { // checks for misspelling of field name
						$sql .= $key.",";
					} else die ("Unknown field name '$key'.");
				}
			}

			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .= ")";

			// put values into SQL
			$sql .= " VALUES ";

			// first with taxonomy = 'category'
			///////////////////////////////////////////////////////////////
			$sql .= "(";

			// get auto-increment for the new record
			$autoIncrementTermTax = getAutoIncrement('term_taxonomy');

			$sql .= "'".$autoIncrementTermTax."',"; // id

			if (isset($params['parentid'])) { // if parentid is set
				$sql .= "'".$params['parentid']."',"; // parentid
			} else {
				// if parentid is not set then parentid = id
				$sql .= "'".$autoIncrementTermTax."',";
			}

			$sql .=  "'".$idTerms."',"; // termid
			$sql .=  "'category',"; // taxonomy

			foreach ($params as $key=>$value) {
				if ($key != 'action' && $key != 'id' && $key !='name' && $key != 'slug' && $key != 'parentid' && $key != 'termid' && $key != 'taxonomy' && $key != 'verbose') {
					$sql .= ":".$key.",";
					$sendParams[$key] = processText($value);
				}
			}

			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .=")";
			///////////////////////////////////////////////////////////////

			if ($isnewtag) { // tag was inserted to 'terms'
				// so insert second record with taxonomy = 'tag'
				///////////////////////////////////////////////////////////////
				$sql .= ", (";

				$nextTermTax = $autoIncrementTermTax + 1;

				$sql .= "'".$nextTermTax."',"; // id

				if (isset($params['parentid'])) { // if parentid is set
					$sql .= "'".$params['parentid']."',"; // parentid
				} else {
					// if parentid is not set then parentid = id
					$sql .= "'".$nextTermTax."',";
				}

				$sql .=  "'".$idTerms."',"; // termid
				$sql .= "'tag',"; // taxonomy
					
				foreach ($params as $key=>$value) {
					if ($key != 'action' && $key != 'id' && $key !='name' && $key != 'slug' && $key != 'parentid' && $key != 'termid' && $key != 'taxonomy' && $key != 'verbose') {
						$sql .= ":".$key.",";
						//$sendParams[$key] = processText($value);
					}
				}

				// remove last comma
				$sql = substr($sql,0,strlen($sql)-1);
				$sql .=")";
				///////////////////////////////////////////////////////////////
			}

		} else die("Invalid Taxonomy parameter.");


		// insert to 'term_taxonomy' and get the results
		if ($result = queryDatabase($sql,$sendParams,$insertid)) {

			// SELECT fields according to Verbose parameter

			if (isset($params['verbose']) && $params['verbose'] == 'true' && $isnewtag && $params['taxonomy'] == 'category') {
				$sql = "SELECT id, parentid, termid FROM `term_taxonomy` WHERE id = '".$autoIncrementTermTax."'";
			} else if (isset($params['verbose']) && $params['verbose'] == 'true') {
				$sql = "SELECT id, parentid, termid FROM `term_taxonomy` WHERE id = '".$insertid."'";
			} else if ((!isset($params['verbose']) || (isset($params['verbose']) && $params['verbose'] == 'true')) && $isnewtag && $params['taxonomy'] == 'category') {
				$sql = "SELECT * FROM `term_taxonomy` WHERE id = '".$autoIncrementTermTax."'";
			} else if (!isset($params['verbose']) || (isset($params['verbose']) && $params['verbose'] == 'true')) {
				$sql = "SELECT * FROM `term_taxonomy` WHERE id = '".$insertid."'";
			} else $sql = "SELECT id FROM `term_taxonomy` WHERE id = '".$insertid."'"; // verbose = false

			if ($result = queryDatabase($sql)) {
				return $result;
			} else die("Query Failed: " . $result->errorInfo());

		} else die("Query Failed: " . $result->errorInfo());

	} else die("No tag name or taxonomy provided; or invalid taxonomy parameter.");
}

function insertRecord($params) //+
{
	/*
		* Script will attempt to insert a record with all other name/value pair parameters provided
		* You will get an error if you provided invalid field names.

		** REQUIRED PARAMS
		tablename - name of the table to insert the record in
		name/value pairs to set fields for the inserting record; should be field names from the 'tablename'

		** OTHER PARAMS
		verbose
		containerpath
		if a param is sent called 'password' it will automatically be encrypted.
		*/

	// gets array of fields name for 'tablename'
	$columnsArray = getTableColumns($params['tablename']);
	$sendParams = array();

	// make sure we have a tablename
	if (isset($params['tablename'])) {
		$sql = "INSERT INTO `".$params['tablename']."` ";
		$sql .= "(";

		foreach ($params as $key=>$value) {
			if ($key != 'action' && $key != 'tablename' && $key != 'tags' && $key != 'verbose') {

				if (in_array($key, $columnsArray)) // checks for misspelling of field name
				$sql .= $key . ",";
				else die("Unknown field name '$key'.");
			}
		}

		// remove last comma
		$sql = substr($sql,0,strlen($sql)-1);
		$sql .= ")";

		// put values into SQL
		$sql .= " VALUES (";

		foreach ($params as $key=>$value) {
			if ($key != 'action' && $key != 'tablename' && $key != 'tags' && $key != 'verbose') {

				if ($key == 'password') {
					$sql .= ":".$key.",";
					$sendParams[$key] = text_crypt($value);
				}
				else {
					$sql .= ":".$key.",";
					$sendParams[$key] = processText($value);
				}
			}
		}

		// remove last comma
		$sql = substr($sql,0,strlen($sql)-1);
		$sql .=")";

	} else die("No tablename provided.");

	// get the results
	if ($result = queryDatabase($sql,$sendParams,$insertid)) {

		if($params['tablename'] == 'content')
		{
			$tokens = updateContainerPaths(null, $insertid); // updates 'containerpath' field
		}

		if (isset($params['verbose'])) {
			if($params['verbose'] == 'true')
				$sql = "SELECT * FROM `".$params['tablename']."`  WHERE id = '".$insertid."'";
			else 
				$sql = "SELECT id FROM `".$params['tablename']."`  WHERE id = '".$insertid."'";
			if ($result = queryDatabase($sql)) 
				return $result;
		 	else die("Query Failed: " . $result->errorInfo());
		} 
		else 
		sendSuccess($insertid);
	} else die("Query Failed: " . $result->errorInfo());
}
function insertRecordsByKey($params)
{
	$columnsArray = getTableColumns($params['tablename']);
	$sendParams = array();

	// make sure we have a tablename
	if (isset($params['tablename'])) {
		$sql = "INSERT INTO `".$params['tablename']."` ";
		$sql .= "(".$params['manyfield'].",";

		foreach ($params as $key=>$value) {
			if ($key != 'action' && $key != 'tablename' && $key != 'tags' && $key != 'verbose' && $key != 'manyids' && $key != 'manyfield') {
				if (in_array($key, $columnsArray)) // checks for misspelling of field name
				$sql .= $key . ",";
				else die("Unknown field name '$key'.");
			}
		}
		$sql = substr($sql,0,strlen($sql)-1);
		$sql .= ")";
		$sql .= " VALUES ";
		$manyids = explode(',',$params['manyids']);
		//print_r($manyids);
		
		
		foreach($manyids as $manyid) {
			$sql .= "(:".$params['manyfield'].$manyid.",";
			$sendParams[$params['manyfield'].$manyid] = $manyid;
			foreach ($params as $key=>$value) {
				if ($key != 'action' && $key != 'tablename' && $key != 'tags' && $key != 'verbose' && $key != 'manyids' && $key != 'manyfield') {
					$sql .= ":".$key.",";
					$sendParams[$key] = $value;
				}	
			}
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .="),";
		}
		
		$sql = substr($sql,0,strlen($sql)-1);
		//echo $sql;

	} else die("No tablename provided.");
	// get the results

	if ($result = queryDatabase($sql,$sendParams,$insertid)) {
		$results = array();
		foreach($manyids as $manyid) {
			$temp = array();
			$temp[$params['manyfield']] = $manyid;
			$temp['id'] = $insertid; 
			array_push($results,$temp);
			$insertid++;
		}
		header("Content-type: application/json; charset=UTF-8");
		echo json_encode($results);
	} else die("Query Failed: " . $result->errorInfo());
}

function insertRecordWithRelatedTag($params) //+
{
	/*
		* Script will attempt to insert a record with related tags
		* You will get an error if you provided invalid field names.

		** REQUIRED PARAMS
		tablename - name of the table (should be 'content' or 'media')
		tags - comma-delimited list of related tags -> if found, this will attempt to add tags if they don't already exist in the system, otherwise it will tie tags to the content or media being inserted.
		name/value pairs to set fields for the record; should be field names from 'tablename'
		*/

	if (isset($params['tablename']) && isset($params['tags'])) {

		// get auto increment of the 'tablename'
		$autoIncrement = getAutoIncrement($params['tablename']);

		// insert record to 'tablename'
		if($result = insertRecord($params)) {
			// relate tags using auto increment
			associateTags($params['tablename'], $autoIncrement, $params['tags']);
			return $result;
		} else die ("Insert Record Failed: " . $result->errorInfo());
	} else die("No tablename or tags provided.");
}

function deleteTag($params) //+
{
	/*
		* Script will attempt to delete tag from 'term_taxonomy' and then from related tables 'content_terms' and 'media_terms'

		** REQUIRED PARAMS
		id - primary key of the record at table 'term_taxonomy' to delete
		*/

	if(isset($params['id']))
	{
		$sendParams = array();
		$sql = "DELETE FROM `term_taxonomy` WHERE id = :id ";
		$sendParams['id'] = $params['id'];

		if($result = queryDatabase($sql,$sendParams))
		{
			// delete from 'content_terms'
			$sql = "DELETE FROM `content_terms` WHERE termid = :id ";
			if($result = queryDatabase($sql,$sendParams)) {
				sendSuccess();
			} else die("Query Failed: " . $result->errorInfo());

			// delete from 'media_terms'
			$sql = "DELETE FROM `media_terms` WHERE termid = :id ";
			if($result = queryDatabase($sql,$sendParams)) {
				sendSuccess();
			} else die("Query Failed: " . $result->errorInfo());
		} else die("Query Failed: " . $result->errorInfo());
	} else die ("No id provided.");
}

function deleteRecord($params) //+
{
	/*
		* Script will attempt to delete one record by id

		** REQUIRED PARAMS
		tablename - name of the table to delete
		id - primary key of the record to delete
		*/

	// make sure we have a content id and tablename
	if (isset($params['tablename']) && isset($params['id'])) {
		$sendParams = array();
		$sql = "DELETE FROM `".$params['tablename']."` ";
		$sql .= " WHERE id = :id";
		$sendParams['id'] = $params['id'];
	}
	else die("No tablename or id provided.");

	// get the results
	if ($result = queryDatabase($sql,$sendParams)) {
		sendSuccess();
	}
	else die("Query Failed: " . $result->errorInfo());
}

function deleteRecords($params) //+
{
	/*
		* Script will attempt to delete multiple records by idfield/idvalues (comma-delimited) and other name/value pair parameters provided
		* You will get an error if you provided invalid field names.

		** REQUIRED PARAMS
		tablename - name of the table to delete
		idfield - name of the parameter to specify records to delete
		idvalues - values of idfield; could be comma-delimited list (formatted id string (id,id,id))

		** OTHER PARAMS
		* name/value pairs to specify records to delete
		*/

	$sendParams = array();

	// gets array of fields name for 'tablename'
	$columnsArray = getTableColumns($params['tablename']);

	// make sure we have a content id and tablename
	if (isset($params['idvalues']) && isset($params['tablename']) && isset($params['idfield'])) {
		$sql = "DELETE FROM `".$params['tablename']."` ";

		if (in_array($params['idfield'], $columnsArray)) { // checks for misspelling of field name
			$sql .= " WHERE ".$params['idfield']." IN ( ";
		}
		else die("Unknown field name '".$params['idfield']."'.");

		$manyvalues = explode(",",$params['idvalues']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}

		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";

		foreach ($params as $key=>$value)
		{
			if ($key != 'action' && $key != 'tablename' && $key != 'idfield' && $key != 'idvalues') {
				if (in_array($key,$columnsArray)) {
					$sql .= " AND " . $key . " = :".$key;
					$sendParams[$key] = $value;
				} else die("Unknown field name '$key'.");
			}
		}

	} else die("No tablename or id provided.");

	// get the results
	if ($result = queryDatabase($sql,$sendParams)) {
		sendSuccess();
	} else die("Query Failed:" . $result->errorInfo());
}

function deleteMediaByPath($params) //+
{
	/*
		* Script will attempt to delete records where by 'path' parameter from table 'media'

		** REQUIRED PARAMS
		path - could be part of the 'path' field
		*/

	if (isset($params['path'])) {
		$sql = "DELETE FROM `media` ";
		$sql .= " WHERE path LIKE '%".$params['path']. "%'";
	} else die("No path provided.");

	// get the results
	if ($result = queryDatabase($sql)) {
		sendSuccess();
	} else die("Query Failed:" . $result->errorInfo());
}

function deleteContent($params) //+
{
	/*
		* Script will attempt to delete a record (by content id) from a table 'content' and all related tables (content_*)

		** REQUIRED PARAMS
		id - primary key of the record to delete
		*/

	// make sure we have a content id
	if(isset($params['id']))
	{
		// checks whether id is valid or not
		$sendParams = array();
		$sql = "SELECT * from `content` WHERE id = :id";
		$sendParams['id'] = $params['id'];

		$result = queryDatabase($sql,$sendParams);
		$row = $result->fetch(PDO::FETCH_ASSOC);

		// valid content id
		if ($row != null) {
			$sql = "DELETE content, content_media, content_users, content_content, content_terms, content_customfields
			FROM content 
			LEFT JOIN content_media   		ON content_media.contentid = content.id
			LEFT JOIN content_users			ON content_users.contentid = content.id
			LEFT JOIN content_content		ON content_content.contentid = content.id
			LEFT JOIN content_terms   		ON content_terms.contentid = content.id
			LEFT JOIN content_customfields	ON content_customfields.contentid = content.id
			WHERE content.id = :id";
		} else die("Invalid id.");
	} else die("No content id provided.");

	if ($result = queryDatabase($sql,$sendParams)) {
		sendSuccess();
	} else die("Query Failed: " . $result->errorInfo());
}

function associateTags($tablename,$id,$tags) //+
{

	// put tags into an array!
	$arrTags = explode(",",$tags);

	// clean tags. get rid of spaces on either side, make lowercase.
	foreach ($arrTags as $key=>$tag) {
		$arrTags[$key] = array("tag"=>trim($tag));
	}

	// now lets check if they are already in the DB
	foreach ($arrTags as $key=>$arrTag) {

		$sendParams = array();
		$sql = "SELECT id FROM `terms` WHERE name = :name";
		$sendParams['name'] = $arrTag['tag'];
		$result = queryDatabase($sql, $sendParams);

		if ($result->rowCount() > 0) {
			// tag does exist in 'terms'
			$row = $result->fetch(PDO::FETCH_ASSOC);

			// find the term_taxonomy row that uses it with taxonomy = tag
			$sql = "SELECT id FROM `term_taxonomy` WHERE termid = ".$row['id']." AND taxonomy = 'tag'";
			$result = queryDatabase($sql);
			if ($result->rowCount() > 0) {
				$row = $result->fetch(PDO::FETCH_ASSOC);
				// put term_taxonomy id into arrTags
				//$arrTags[$key]['termid'] = $row['id'];
				$addTags[$key]['termid'] = $row['id'];
			} else {
				// get auto increment in 'term_taxonomy'
				$autoIncrement = getAutoIncrement('term_taxonomy');

				// insert new record into term_taxonomy using insertid(auto increment) and taxonomy=tag
				$sql = "INSERT into `term_taxonomy` (id,parentid,termid,taxonomy) VALUES ('". $autoIncrement. "','". $autoIncrement. "','".$row['id']. "','tag')";
				queryDatabase($sql);

				$addTags[$key]['termid'] = $autoIncrement;
			}
		} else {
			// tag does not exist in 'terms'
			$sendParams = array();
			$name = $arrTag['tag'];
			$slug = strtolower(trim($name));
			$slug = preg_replace('/[^a-z0-9-]/', '-', $slug);
			$slug = preg_replace('/-+/', "-", $slug);
			$slug = strtolower($slug);

			// insert tag into 'terms'
			$sql = "INSERT INTO `terms` (name,slug) VALUES (:name, :slug)";
			$sendParams['name'] = $arrTag['tag'];
			$sendParams['slug'] = $slug;
			queryDatabase($sql, $sendParams, $insertid); // get insertid

			// get auto increment in 'term_taxonomy'
			$autoIncrement = getAutoIncrement('term_taxonomy');

			// insert new record into term_taxonomy using insertid(auto increment) and taxonomy=tag
			$sql = "INSERT into `term_taxonomy` (id,parentid,termid,taxonomy) VALUES ('". $autoIncrement. "','". $autoIncrement. "','". $insertid. "','tag')";
			queryDatabase($sql);

			//$arrTags[$key]['termid'] = $autoIncrement;
			$addTags[$key]['termid'] = $autoIncrement;
		}
	}

	// now lets associate the tags with the record, first delete all associated tags!
	$tagsTableName = $tablename . "_terms"; 	//'content_terms' or 'media_terms'
	$idField = $tablename . "id"; 				//'contentid' or 'mediaid'
	/*
	$sql = "DELETE FROM $tagsTableName WHERE $idField = '$id'";
	queryDatabase($sql);
	*/
	// relate to $tagsTableName using last inserted term_taxonomy id
	foreach ($addTags as $addTag) {
		$sql = "INSERT INTO $tagsTableName ($idField,termid) VALUES ('".$id."','".$addTag['termid']."')";
		queryDatabase($sql);
	}
	return true;
}

function slug($str)
{
	$str = strtolower(trim($str));
	$str = preg_replace('/[^a-z0-9-]/', '-', $str);
	$str = preg_replace('/-+/', "-", $str);
	return $str;
}

function generateSlug($phrase)
{
	$result = strtolower($phrase);
	$result = preg_replace("/[^a-z0-9\s-]/", "", $result);
	$result = trim(preg_replace("/\s+/", " ", $result));
	$result = trim(substr($result, 0, 45));
	$result = preg_replace("/\s/", "-", $result);
	return $result;
}

function processText($text)
{
	global $htmlSymbols;
	$html = '';
	if($text != 'NULL')
	{
		$list = get_html_translation_table(HTML_ENTITIES);
		unset($list['"']);
		unset($list['<']);
		unset($list['>']);
		unset($list['&']);

		$search = array_keys($list);
		$values = array_values($list);
		$search = array_map('utf8_encode', $search);
		$html = str_replace($search, $values, $text);

		$search = array_keys($htmlSymbols);
		//$search = array_map('utf8_encode', $search);
		$values = array_values($htmlSymbols);
		$html = str_replace($search, $values, $html);
		//var_dump($text, $html);
		return $html;
	}
	else if($text == 'NULL')
		return '';
	else return NULL;
}

function processSlug($text)
{
	$chars = array('Š','Œ','Ž','š','œ','ž','Ÿ','¥','µ','À','Á','Â','Ã','Ä','Å','Æ','Ç','È','É','Ê','Ë','Ì','Í','Î','Ï',
			       'Ð','Ñ','Ò','Ó','Ô','Õ','Ö','Ø','Ù','Ú','Û','Ü','Ý','ß','à','á','â','ã','ä','å','æ','ç','è','é','ê','ë',
				   'ì','í','î','ï','ð','ñ','ò','ó','ô','õ','ö','ø','ù','ú','û','ü','ý','ÿ');

	$base = array('S','O','Z','s','o','z','Y','Y','u','A','A','A','A','A','A','A','C','E','E','E','E','I','I','I','I',
										 'D','N','O','O','O','O','O','O','U','U','U','U','Y','s','a','a','a','a','a','a','a','c','e','e','e','e',
										 'i','i','i','i','o','n','o','o','o','o','o','o','u','u','u','u','y','y');				   
	$accents = array();
	$i=0;
	foreach($chars as $c)
	{
		$element = array(processText($c) => $base[$i]);
		$accents = array_merge($accents,$element);
		$i++;
	}
	return strtr(processText($text),$accents);
}
function duplicateObject($params)
{

	/*
		* Script will attempt to duplicate a record (by content id) into table 'content'

		** REQUIRED PARAMS
		id - primary key of the record to duplicate
		*/

	// make sure we have a content id
	if(isset($params['id']) && isset($params['tablename']))
	{
		$sendParams = array();
		$sql = "SELECT ". $params["tablename"] .".* from `" . $params["tablename"] . "` WHERE id = :id";
		$sendParams['id'] = $params['id'];
		$result = queryDatabase($sql,$sendParams);
		$row = $result->fetch(PDO::FETCH_ASSOC);

		// valid  id
		if ($row!=null) {

			$sendParams = array();

			$sql = "INSERT INTO `". $params["tablename"]."` ";

			// put field names into SQL
			$sql .= "(";

			foreach ($row as $key=>$value)
			{
				if($key != 'id')
				$sql .= $key . ",";
			}
			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .= ")";

			// put values into SQL
			$sql .= " VALUES (";

			foreach ($row as $key=>$value)
			{
				if($key != 'id') {
					$sql .= ":".$key.",";
					$sendParams[$key] = $value;
				}
			}
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .=")";
			if ($result = queryDatabase($sql,$sendParams,$insertid)) {
				if(isset($params["relatedTables"]) && isset($params["relatedField"]) ) {
					$relatedTables = explode(",",$params["relatedTables"]);
					foreach ($relatedTables as $key=>$value) 
						duplicateRows($value,$params["relatedField"],$params['id'],$insertid);
					sendSuccess($insertid);
				}
				else die("something is wrong");
			}
			else die("Query Failed: " . $result->errorInfo());
		}
		else die("Invalid id.");
	}
	else die("Content id is not provided.");
}
function duplicateContent($params)
{
	/*
		* Script will attempt to duplicate a record (by content id) into table 'content'

		** REQUIRED PARAMS
		id - primary key of the record to duplicate
		*/

	// make sure we have a content id
	if(isset($params['id']))
	{
		$sendParams = array();
		$sql = "SELECT content.* from `content` WHERE id = :id";
		$sendParams['id'] = $params['id'];
		$result = queryDatabase($sql,$sendParams);
		$row = $result->fetch(PDO::FETCH_ASSOC);

		// valid content id
		if ($row!=null) {

			$sendParams = array();

			$sql = "INSERT INTO `content` ";

			// put field names into SQL
			$sql .= "(";

			foreach ($row as $key=>$value)
			{
				if($key != 'id')
				$sql .= $key . ",";
			}
			// remove last comma
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .= ")";

			// put values into SQL
			$sql .= " VALUES (";

			foreach ($row as $key=>$value)
			{
				if($key != 'id') {
					$sql .= ":".$key.",";
					$sendParams[$key] = $value;
				}
			}
			$sql = substr($sql,0,strlen($sql)-1);
			$sql .=")";
			if ($result = queryDatabase($sql,$sendParams,$insertid)) {
					
				//duplicate relationships
				duplicateRows('content_media','contentid',$params['id'],$insertid);
				duplicateRows('content_content','contentid',$params['id'],$insertid);
				duplicateRows('content_users','contentid',$params['id'],$insertid);
				duplicateRows('content_terms','contentid',$params['id'],$insertid);
				duplicateRows('comments','contentid',$params['id'],$insertid);
				$params2['verbosity'] = 1;
				$params2['contentid'] = $insertid;
				$params2['action'] = 'getContent';
				$result = getContent($params2);
				return $result;
			}
		}
		else die("Invalid id.");
	}
	else die("Content id is not provided.");
}

function duplicateRows($tablename,$idField,$idValue,$insertId)
{
	$sendParams = array();
	$sql = "SELECT * from `". $tablename . "` WHERE ". $idField . "= :idvalue ";
	$sendParams['idvalue'] = $idValue;
	$result = queryDatabase($sql,$sendParams);

	while ($row = $result->fetch(PDO::FETCH_ASSOC))
	{
		$sendParams = array();

		$sql = "INSERT INTO `". $tablename . "`";
			
		// put field names into SQL
		$sql .= "(";
			
		foreach ($row as $key=>$value)
		{
			if($key != 'id')
			$sql .= $key . ",";
		}
		// remove last comma
		$sql = substr($sql,0,strlen($sql)-1);
		$sql .= ")";
			
		// put values into SQL
		$sql .= " VALUES (";
			
		foreach ($row as $key=>$value)
		{
			if($key != 'id')
			{
				if($key == $idField)
				$sql .= "'".$insertId."',";
				else {
					$sql .= ":".$key.",";
					$sendParams[$key] = $value;
				}
			}

		}
		$sql = substr($sql,0,strlen($sql)-1);
		$sql .=")";
		queryDatabase($sql,$sendParams,$insertid);
	}
}
?>