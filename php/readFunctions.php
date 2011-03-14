<?php
function validateUser($params)
{
	/*
	 -- REQUIRED --

	 username (str)
	 password (str)

	 -- OPTIONAL --

	 */

	$validParams = array("action","username","password");
	if (isset($params['username']) && isset($params['password'])) {
		$sql = "SELECT * FROM user WHERE username = '".$params['username']."' AND active='1'";
		$result = queryDatabase($sql);

		if ($row = $result->fetch(PDO::FETCH_ASSOC)) {
			if ($params['password'] == text_decrypt($row['password'])) {
				$sql = "SELECT * FROM user WHERE id = '".$row['id']."'";
				$result = queryDatabase($sql);
				return $result;
			} else sendFailed("Invalid Password!");
		} else sendFailed("User not found.");
	} else sendFailed ("Username and Password are both required!");
}
function getData ($params) {
	/*

	General read function.

	-- VALID PARAMS --
	-- REQUIRED --

	tablename (str) - what table should we read?

	-- OPTIONAL --

	id - if provided, then return a specific id or comma-delimited list
	orderby - field name to order results by, should be expressed as table.field (e.g. content.migtitle). Can also be comma-delimited list.
	orderdirection - ASC or DESC
	other name/value pair parameters to specify results

	*/

	if (isset($params['tablename'])) {


		$validParams = array("action","tablename","id","orderby","orderdirection");

		$sql = "SELECT `".$params['tablename']."`.*";
		$sql .= " FROM `".$params['tablename']."`";
		$sql .= " WHERE id <> 0 ";

		$sendParams = array(); //params to replace placeholders at queryDatabase()

		if (isset($params['id'])) { // return a specific content id, or a list thereof

			$sql .= " AND id IN ( ";

			// $params['id'] can be comma-delimited
			$manyvalues = explode(",",$params['id']);
			foreach($manyvalues as $value)
			{
				$sql .= " :singlevalue".$value.", ";
				$sendParams['singlevalue'.$value] = $value;
			}
			$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
			$sql .= " )";
		}
		foreach ($params as $key=>$value) {
			if (!in_array($key,$validParams)) {
				$sql .= " AND " . $key . " = :".$key;
				$sendParams[$key] = $value;
			}
		}
	} else {
		die("Tablename is required.");
	}

	// ORDER BY
	if (isset($params['orderby']))
	{
		if(isset($params['orderdirection']))
		{
			$sql .= " ORDER BY ".$params['tablename'].".".$params['orderby']." ".$params['orderdirection'];
		}
		else
		{
			$sql .= " ORDER BY ".$params['tablename'].".".$params['orderby'];
		}
	}
	else
	$sql .= " ORDER BY id ASC";

	// get the results
	$result = queryDatabase($sql,$sendParams);

	// return the results
	return $result;
}

function getUsers($params) {
	/*

	Return user info from 'user' table and all related tables

	-- ALL ARE OPTIONAL --

	userid (int) - specifies a specific user id to return (can be comma-delimited)
	contentid (int) - specifies a specific content id to return media results for (can be comma-delimited)

	*/

	$sendParams = array();

	$validParams = array("action","userid","contentid","include_unused");

	// define the sql query
	$sql = "SELECT user.* , GROUP_CONCAT(DISTINCT content_users.contentid) AS contentids, GROUP_CONCAT(DISTINCT user_usercategories.categoryid) AS categoryids ";

	$sql .= " FROM user
			  LEFT JOIN content_users ON content_users.userid = user.id
			  LEFT JOIN content ON (content.id = content_users.contentid  AND content.deleted = 0)
			  LEFT JOIN user_usercategories ON user_usercategories.userid = user.id
			  LEFT JOIN usercategories ON usercategories.id = user_usercategories.categoryid";

	$sql .= " WHERE user.id <> 0 ";

	if (isset($params['userid'])) { // return a specific media id, or a list thereof

		$sql .= " AND userid.id IN ( ";

		// $params['userid'] can be comma-delimited
		$manyvalues = explode(",",$params['userid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}

	if (isset($params['contentid'])) { // return media for a specific content id, or a list thereof

		$sql .= " AND content_users.contentid IN ( ";
		// $params['contentid'] can be comma-delimited
		$manyvalues = explode(",",$params['contentid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}

	// GET ANY EXTRA PARAMS AND APPLY THOSE TO THE WHERE CLAUSE

	foreach ($params as $key=>$value)
	{
		if (!in_array($key,$validParams))
		{
			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;
		}
	}

	$sql .=" GROUP BY user.id";

	// ORDER BY
	$sql .= " ORDER BY user.id ASC";

	// get the results
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}
function getRoot($params) {

	$sql = " SELECT `content`.*, childrencount.childrencount FROM `content` 
			  LEFT JOIN ( SELECT parentid, COUNT(*) AS childrencount FROM `content` WHERE `content`.`parentid` ='1' GROUP BY parentid) 
			  AS childrencount ON childrencount.parentid = content.id WHERE `content`.`id` = '1' ";
	$result = queryDatabase($sql);	
	return $result;
}
function getContent($params)
{
	/*

	Return specified rows from the table 'content'.

	-- ALL ARE OPTIONAL --

	contentid (int) - specifies a specific content id to return (can be comma-delimited)
	parentid (int) - only return content under this parent id (can be comma-delimited) - This also overrrides contentid!!!
	includechildren (0,1) - only applies when a contentid or parentid is specified, do we return children as well?
	has_tag - comma-delimited list of tags to search for.
	search_terms - search words to search for (comma-delimited). this searches title, description + custom fields.
	search_description - search words to search for in description (comma-delimited).
	search_customfields - words to search for in the custom fields (comma-delimited).
	verbosity - (1 = ids + titles only, 2 - all fields + named custom fields, 3 - all fields).
	orderby - field name to order results by, should be expressed as table.field (e.g. content.migtitle). Can also be comma-delimited list.

	customfield* OR customfieldname (as it appears in DB) will both work for returning content based on custom field data.

	*/

	global $arrVerbosity,$arrCFFlag;

	$validParams = array("action","contentid","include_children","typeid","has_tag","search_terms","thumbUsage",
	"search_description","search_title","search_customfields","verbosity","parentid","orderby","orderdirection","children_depth");


	// SELECT fields according to verbosity

	if (!isset($params['verbosity'])) // set default verbosity
	$params['verbosity'] = 0;

	if (isset($arrCFFlag[$params['verbosity']])) {

		$sql = "SELECT customfields.name, customfields.displayname
				FROM templates_customfields " .
	 			"LEFT JOIN customfields ON customfields.id = templates_customfields.customfieldid";

		$result = queryDatabase($sql);
		$customfields = array();

		if ($result->rowCount() > 0) { // make sure some custom fields exist!

			while ($row = $result->fetch(PDO::FETCH_ASSOC))
				$customfields[] = $row['name'];
		}
	}

	if (isset($params['parentid'])) {

		// for this we need to get all contentids which have a particular parentid, and then get all their children!
		$sendParams = array(); //params to replace placeholders at queryDatabase()

		$sql = "SELECT id FROM content WHERE parentid IN ( ";


		// $params['parentid'] can be comma-delimited
		$manyvalues = explode(",",$params['parentid']);
		foreach($manyvalues as $contentvalue)
		{
			$sql .= " :singlevalue".$contentvalue.", ";
			$sendParams['singlevalue'.$contentvalue] = $contentvalue;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
		$result = queryDatabase($sql,$sendParams);

		$arrContentIDs = array();

		if ($result->rowCount() > 0) {

			while ($row = $result->fetch(PDO::FETCH_ASSOC)) {

				$arrContentIDs[] = $row['id'];

				/*if (isset($params['include_children']) && ($params['include_children'] == 1))
				 {

					if(isset($params['children_depth']))
					{
					$children_depth = $params['children_depth'];
					}
					$currentChildIDs = getChildren($row['id']);
					$arrContentIDs = array_merge($arrContentIDs,$currentChildIDs);
					}*/
			}
			$params['contentid'] = implode(",", $arrContentIDs);
		}
		else
		{
			$params['contentid'] = "0";
		}
	}

	$sendParams = array(); //params to replace placeholders at queryDatabase()
	$i = 0;

	if (isset($params['include_children']) && isset($params['contentid']) && ($params['include_children'] == 1)) { // include_children

		// get childids for all contentids specified
		$contentids = explode(",",$params['contentid']);
		$childids = array();
		foreach ($contentids as $id)
		{
			$currentChildIDs = getChildren($id,$params['children_depth']);
			$childids = array_merge($childids,$currentChildIDs);

			$sql2 = "SELECT COUNT(*) as count FROM `content` WHERE parentid = " .$id;
			$result2 = queryDatabase($sql2);
			$row2 = $result2->fetch(PDO::FETCH_ASSOC);
			$childrencount[$id] = $row['count'];

		}
		if ($childids) // make sure we actually got some results
		$strChildIDs = implode(",",$childids);
	}


	// BUILD SELECT STATEMENT FROM INFO IN VERBOSITY ARRAY!

	$sql = "SELECT ";
	if (@is_array($arrVerbosity[$params['verbosity']])) {
		foreach ($arrVerbosity[$params['verbosity']] as $field)
		$sql .= $field . ",";
	} else die("Invalid verbosity level.");

	// give us back the custom fields with appropriate names!

	if (isset($arrCFFlag[$params['verbosity']])) {

		foreach ($customfields AS $key=>$value)
		$sql .= " content.".$value.",";
	}

	// remove last comma!
	$sql = substr($sql,0,strlen($sql)-1);


	//,GROUP_CONCAT(DISTINCT media.path,media.name) AS thumbtitle
	$includeThumb = true;
	if(isset($params["thumbUsage"])) {
		$thumb_usage = $params["thumbUsage"];
		$includeThumb = false;
	}
	$thumb_usage = "thumb";


	//echo $params["contentid"];

	$sql .= " FROM content
			  LEFT JOIN content_users ON content_users.contentid = content.id
			  LEFT JOIN user ON user.id = content_users.userid
			  			  
			  LEFT JOIN content_terms AS content_terms ON content_terms.contentid = content.id
			  LEFT JOIN term_taxonomy AS term_taxonomy ON term_taxonomy.id = content_terms.termid 
			  LEFT JOIN terms AS terms ON terms.id = term_taxonomy.termid
			  LEFT JOIN templates ON templates.id = content.templateid ";		  

	if(isset($params['contentid'])) {
		$sql .= " LEFT JOIN ( SELECT parentid, COUNT(*) AS childrencount FROM `content` WHERE parentid IN (". $params['contentid'] .") AND `content`.`deleted` = '0' GROUP BY parentid
				  ) AS childrencount ON childrencount.parentid = content.id";
	}

	//related content
	$sql .= "
			  LEFT JOIN (
	
				SELECT content_content.contentid,GROUP_CONCAT(content_content.contentid2 ORDER BY content_content.id) AS contentids,
				GROUP_CONCAT(related.migtitle) AS relatedcontent,content_content.desc 
				FROM content_content
				LEFT JOIN content AS related ON related.id = content_content.contentid2
				GROUP BY content_content.contentid
			
 			 ) AS content1 ON content1.contentid = content.id

			  LEFT JOIN (
	
				SELECT content_content.contentid2,GROUP_CONCAT(content_content.contentid ORDER BY content_content.id) AS contentids, 
				GROUP_CONCAT(related.migtitle) AS relatedcontent, content_content.desc FROM content_content
				LEFT JOIN content AS related ON related.id = content_content.contentid
				GROUP BY content_content.contentid2
			
 			 ) AS content2 ON content2.contentid2 = content.id
		
			  
			  LEFT JOIN (
			  	
			  		SELECT content_media.contentid,GROUP_CONCAT(content_media.mediaid ORDER BY content_media.displayorder) AS mediaids 
			  		FROM content_media";
	if($includeThumb == false) {
		$sql .= " WHERE content_media.usage_type <> '".$thumb_usage."' ";
	}

	$sql .=	" GROUP BY content_media.contentid
			  			
			   ) AS content_mediaids ON content_mediaids.contentid = content.id
			   
			  LEFT JOIN (
			  	
			  		SELECT content_media.contentid,GROUP_CONCAT(content_media.mediaid ORDER BY content_media.displayorder) AS thumbids,GROUP_CONCAT(CONCAT(media.path,media.name)) as thumbs
			  		FROM content_media
			  		LEFT JOIN media ON media.id = content_media.mediaid
			  		GROUP BY content_media.contentid
			  	
			   ) AS content_thumbids ON content_thumbids.contentid = content.id
			   LEFT JOIN media ON media.id = thumbids ";	

	// WHERE CLAUSE INFO

	$sql .= " WHERE content.id <> 1 AND is_revision <> 1";

	if (isset($params['contentid'])) { // return a specific content id, or a list thereof
		if (isset($strChildIDs)) {
			$sql .= " AND content.id IN ( ";

			// $params['contentid'] comma-delimited
			$manyvalues = explode(",",$params['contentid']);
			foreach($manyvalues as $contentvalue)
			{
				$sql .= " :singlevalue".$contentvalue.", ";
				$sendParams['singlevalue'.$contentvalue] = $contentvalue;
			}
			// $childids comma-delimited
			foreach($childids as $childvalue)
			{
				$sql .= " :singlevalue".$childvalue.", ";
				$sendParams['singlevalue'.$childvalue] = $childvalue;
			}

			$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
			$sql .= " )";
		}
		else {
			$sql .= " AND content.id IN ( ";
			$manyvalues = explode(",",$params['contentid']);
			foreach($manyvalues as $value)
			{
				$sql .= " :singlevalue".$value.", ";
				$sendParams['singlevalue'.$value] = $value;
			}
			$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
			$sql .= " )";
		}
	}

	if (isset($params['has_tag'])) { // search for tags

		$arrTags = explode(",",$params['has_tag']);

		if (is_array($arrTags)) {

			$strTags = "";

			foreach ($arrTags as $tag)
			$strTags .= "'".$tag."'";


			$sql .= " AND tags.tag IN (".$strTags.") ";
		}

	}

	if (isset($params['search_terms'])) { // general search

		$arrSearchTerms = explode(",",$params['search_terms']);

		if (is_array($arrSearchTerms)) {

			$sql .= " AND ( ";

			foreach ($arrSearchTerms as $term) {
				$i++;
				$sql .= " content.migtitle LIKE :term".$i." OR";
				$sql .= " content.containerpath LIKE :term".$i." OR";
				$sql .= " content1.desc LIKE :term".$i." OR";
				$sql .= " content2.desc LIKE :term".$i." OR";
				$sql .= " content.customfield1 LIKE :term".$i." OR";
				$sql .= " content.customfield2 LIKE :term".$i." OR";
				$sql .= " content.customfield3 LIKE :term".$i." OR";
				$sql .= " content.customfield4 LIKE :term".$i." OR";
				$sql .= " content.customfield5 LIKE :term".$i." OR";
				$sql .= " content.customfield6 LIKE :term".$i." OR";
				$sql .= " content.customfield7 LIKE :term".$i." OR";
				$sql .= " content.customfield8 LIKE :term".$i." OR";
				$sql .= " terms.name LIKE :term".$i." OR";

				$sendParams['term'.$i] = "%".$term."%";
			}
			// remove last "OR"

			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " ) ";

		}

	}

	if (isset($params['search_customfields'])) { // search customfields

		$arrSearchTerms = explode(",",$params['search_customfields']);

		if (is_array($arrSearchTerms)) {

			$sql .= " AND ( ";

			foreach ($arrSearchTerms as $term) {

				foreach ($customfields as $key=>$field) {

					$sql .= " content.customfield".$key." LIKE '%".$term."%' OR";

				}

			}
			// remove last "OR"
			$sql = substr($sql,0,strlen($sql)-2);
			$sql .= " ) ";
		}
	}

	if (isset($params['search_description'])) { // search description

		$arrSearchTerms = explode(",",$params['search_description']);

		if (is_array($arrSearchTerms)) {

			$sql .= " AND ( ";

			foreach ($arrSearchTerms as $term) {
				$i++;
				$sql .= " content1.desc LIKE :term".$i." OR";
				$sql .= " content2.desc LIKE :term".$i." OR";
				$sendParams['term'.$i] = "%".$term."%";
			}

			// remove last "OR"

			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " ) ";

		}
	}

	if (isset($params['search_title'])) { // search title

		$arrSearchTerms = explode(",",$params['search_title']);

		if (is_array($arrSearchTerms)) {

			$sql .= " AND ( ";

			foreach ($arrSearchTerms as $term) {
				$i++;
				$sql .= " content.migtitle LIKE :term".$i." OR";
				$sendParams['term'.$i] = "%".$term."%";
			}

			// remove last "OR"

			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " ) ";

		}

	}
	// GET ANY EXTRA PARAMS AND APPLY THOSE TO THE WHERE CLAUSE!


	foreach ($params as $key=>$value) {

		if (!in_array($key,$validParams)) { // this is a custom parameter

			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;

		}

	}

	// GROUP BY CLAUSE

	$sql .= " GROUP BY content.id";

	// ORDER BY

	if (isset($params['orderby']))
	{
		if(isset($params['orderdirection'])) {
			$sql .= " ORDER BY " . 'content.'. $params['orderby'] ." ". $params['orderdirection'];
		}
		else
		$sql .= " ORDER BY " . 'content.'.$params['orderby'] . " ";
	}
	else
	$sql .= " ORDER BY content.id ASC";
	//echo $sql;
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}

//$old_error_handler = set_error_handler("userErrorHandler");

function getContentMedia($params)
{
	/*
		-- VALID PARAMS --
		-- REQUIRED --

		contentid (int) - specifies a specific content id to return (can be comma-delimited)

		*/

	$validParams = array("action","tablename","id","orderby");
	$sendParams = array();

	$sql = "SELECT content_media.*, media.name, media.color, " .
			"media.path,media.playtime,media.url,media.thumb,media.video_proxy,media.mimetypeid, media.width, media.height";

	$sql .= " FROM `". 'content_media' ."`";

	$sql .= " LEFT JOIN media ON content_media.mediaid = media.id";
	$sql .= " LEFT JOIN mimetypes ON media.mimetypeid = mimetypes.id";

	//contentid ** required!
	if (isset($params['contentid']))
	{
		$sql .= " WHERE contentid IN ( ";

		$manyvalues = explode(",",$params['contentid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}
	else
	{
		die("No contentid was provided");
	}
	// ORDER BY

	$thumb = false;
	foreach ($params as $key=>$value)
	{
		if (!in_array($key,$validParams))
		{ // this is a custom parameter
			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;
			if($value == "thumb")
			$thumb = true;
		}
	}

	$sql .= " ORDER BY displayorder ASC";

	// get the results
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}

function getContentTags($params)
{
	/*
		-- VALID PARAMS --
		-- REQUIRED --

		contentid (int) - specifies a specific content id to return (can be comma-delimited)

		*/

	$sendParams = array();
	$validParams = array("action","tablename","id","orderby");

	$sql = "SELECT content_terms.id, content_terms.termid, terms.name,term_taxonomy.taxonomy";

	$sql .= " FROM `content_terms`";

	$sql .= " LEFT JOIN term_taxonomy  ON term_taxonomy.id = content_terms.termid";
	$sql .= " LEFT JOIN terms  ON terms.id = term_taxonomy.termid";

	if (isset($params['contentid']))
	{
		$sql .= " WHERE contentid IN ( ";

		$manyvalues = explode(",",$params['contentid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}
	else
	{
		die("No contentid was provided");
	}

	foreach ($params as $key=>$value)
	{
		if (!in_array($key,$validParams))
		{ // this is a custom parameter
			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;
		}
	}
	$sql .= " ORDER BY id ASC";

	// get the results
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}

function getContentUsers($params)
{
	/*
		-- VALID PARAMS --
		-- REQUIRED --

		contentid (int) - specifies a specific content id to return (can be comma-delimited)

		*/

	$sendParams = array();

	$validParams = array("action","tablename","id","orderby");

	$sql = "SELECT content_users.id, content_users.contentid,content_users.userid, user.firstname, user.lastname, user.username, user.email";

	$sql .= " FROM `content_users`";

	$sql .= " LEFT JOIN user  ON (content_users.userid = user.id)";

	if (isset($params['contentid']))
	{
		$sql .= " WHERE contentid IN ( ";

		$manyvalues = explode(",",$params['contentid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}
	else
	{
		die("No contentid was provided");
	}

	foreach ($params as $key=>$value)
	{
		if (!in_array($key,$validParams))
		{ // this is a custom parameter
			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;
		}
	}

	$sql .= " ORDER BY id ASC";

	// get the results
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}

function getContentContent($params)
{
	/*
		-- VALID PARAMS --
		-- REQUIRED --

		contentid (int) - specifies a specific content id to return (can be comma-delimited)

		*/

	$sendParams = array();
	$validParams = array("action","tablename","contentid","orderby");

	$sql = "SELECT content_content.id,content_content.contentid2,content.migtitle,content.templateid";

	$sql .= " FROM `". 'content_content' ."`";

	$sql .= " LEFT JOIN content  ON content.id = content_content.contentid2";

	//contentid ** required!
	if (isset($params['contentid']))
	{
		$sql .= " WHERE content_content.contentid IN ( ";

		$manyvalues = explode(",",$params['contentid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}
	else
	{
		die("No contentid was provided");
	}

	foreach ($params as $key=>$value)
	{
		if (!in_array($key,$validParams))
		{ // this is a custom parameter
			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;
		}
	}
	$sql .= " ORDER BY id ASC";

	// get the results

	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}
//for content
function getContentTabs($params) {
	$sql = "SELECT contenttabs.*, templates.templateids FROM contenttabs	
			
			LEFT JOIN (
				SELECT templates_contenttabs.tabid,
				GROUP_CONCAT(templates_contenttabs.templateid ORDER BY templates_contenttabs.templateid) AS templateids
				FROM templates_contenttabs
				GROUP BY templates_contenttabs.tabid
			
 			 ) AS templates ON templates.tabid = contenttabs.id";
 	if($result = queryDatabase($sql)) {
 		return $result;	
 	}
	else die("Query Failed: " . $result->errorInfo());
}
//template id + tamplatetab id + tamplatetab parameter ids as comma-delimited list
function getTemplateContenttabsParams($params) {
	if(isset($params['templateid'])) {
		$sql = "SELECT templates_contenttabs_parameters.*	FROM templates_contenttabs_parameters
				WHERE templates_contenttabs_parameters.templateid = '" . $params['templateid'] . "'";
 	
 		if($result = queryDatabase($sql)) {
 			return $result;
 		}
		else die("Query Failed: " . $result->errorInfo());
	}
	else die("Template id not provided");
}


//for managers
function getRelatedCustomFields($params) {
	$validParams = array("action","tablename");
	$sendParams = array();
	$sql  = "SELECT customfields.typeid, customfields.groupid,customfields.name, customfields.displayname, customfields.options, customfields.defaultvalue, customfields.description, ";
	$sql .= $params["tablename"] . ".* ";
	$sql .= " FROM " . $params["tablename"];
	$sql .= " LEFT JOIN customfields ON customfields.id = " . $params["tablename"] . ".customfieldid WHERE " .  $params["tablename"]. ".id <> 0 ";

	foreach ($params as $key=>$value) {
		if (!in_array($key,$validParams)) {
			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;
		}
	}
	$sql .= " ORDER BY displayorder";
 	if($result = queryDatabase($sql,$sendParams)) {
 		return $result;
 	}
	else die("Query Failed: " . $result->errorInfo());
}
function getContentTree($params)
{
	/*
		-- VALID PARAMS --
		-- REQUIRED --

		id (int) - specifies a specific id to return
		statusid (int)

		*/

	global $statusid;

	global $search; global $values;
	$list = get_html_translation_table(HTML_ENTITIES);
	//unset($list['"']);
	unset($list['<']);
	unset($list['>']);

	$search = array_keys($list);
	$values = array_values($list);
	$search = array_map('utf8_encode', $search);

	$sendParams = array();

	$statusid = -1;
	$xml = "";
	$sql = "SELECT content.id,content.parentid,content.migtitle,content.containerpath,is_fixed " .
			"FROM `content` ";

	if(isset($params['id']))
	{
		$sql .=  " WHERE content.id = :id ";
		$sendParams['id'] = $params['id'];
		if(isset($params['statusid']))
		{
			$statusid = $params['statusid'];
			$sql .= " AND content.statusid = :statusid ";
			$sendParams['statusid'] = $params['statusid'];
		}
		$sql .=	 " AND deleted = '0' ORDER BY displayorder";
	}
	else
	{
		$sql .= " WHERE parentid = 0 AND deleted = '0' ORDER BY displayorder";

	}
	$result = queryDatabase($sql, $sendParams);

	$xml .="<categoryTree>";
	//$arrContainers = array();

	while ($row = $result->fetch(PDO::FETCH_ASSOC)) {

		$xml.= "<container ".returnTagAttributes($row).">";

		if ($x = returnChildren($row['id']))
		$xml .= $x;

		$xml.= "</container>";

	}

	$xml .="</categoryTree>";

	//header('Content-type: text/xml; charset="utf-8"',true);

	$xml = trim($xml);
	serializeArray($xml);
	//echo $xml;
	die();
}

function getMedia($params) {

	/*
		-- VALID PARAMS --
		-- ALL ARE OPTIONAL --

		mediaid (int) - specifies a specific media id to return (can be comma-delimited)
		contentid (int) - specifies a specific content id to return media results for (can be comma-delimited)
		include_unused (1,0) - include media that is not tied to content - defaults to 0 (NO)
		has_tag - comma-delimited list of tags to search for.
		search_caption - search words to search for in description (comma-delimited).
		search_credits - words to search for in the custom fields (comma-delimited).
		orderby - field name to order results by, should be expressed as table.field (e.g. content.migtitle). Can also be comma-delimited list.
		mimetype

		*/
	global $mediaVerbosity;

	$columnsArray = getTableColumns('media'); // gets array of field names for table 'media'
	$validParams = array("action","mediaid","contentid","include_unused","has_tag","search_caption","search_credits","orderby","name","include_thumb","verbosity");

	$sendParams = array();
	$i = 0;

	// SELECT fields according to verbosity

	if (!isset($params['verbosity'])) // set default verbosity
	$params['verbosity'] = 0;


	// BUILD SELECT STATEMENT FROM INFO IN VERBOSITY ARRAY!

	$sql = "SELECT ";

	if (@is_array($mediaVerbosity[$params['verbosity']])) {

		foreach ($mediaVerbosity[$params['verbosity']] as $field)
		$sql .= $field . ",";

	} else {

		die("Invalid verbosity level.");

	}
	$sql = substr($sql,0,strlen($sql)-1);
	$sql .= " FROM media
			  LEFT JOIN media_terms ON media_terms.mediaid = media.id
			  LEFT JOIN term_taxonomy ON term_taxonomy.id = media_terms.termid
			  LEFT JOIN terms ON term_taxonomy.termid = terms.id
			  LEFT JOIN content_media AS content_media ON  content_media.mediaid = media.id
			  LEFT JOIN content ON (content.id = content_media.contentid AND content.deleted='0') ";
	$sql .= " LEFT JOIN mimetypes ON (media.mimetypeid = mimetypes.id)";

	// WHERE CLAUSE INFO

	$sql .= " WHERE media.id <> 0 ";

	if (isset($params['mediaid'])) { // return a specific media id, or a list thereof

		$sql .= " AND media.id IN ( ";

		// $params['mediaid'] comma-delimited
		$manyvalues = explode(",",$params['mediaid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}

	if (isset($params['contentid'])) { // return media for a specific content id, or a list thereof

		$sql .= " AND content_media.contentid IN ( ";

		// $params['contentid'] comma-delimited
		$manyvalues = explode(",",$params['contentid']);
		foreach($manyvalues as $value)
		{
			$sql .= " :singlevalue".$value.", ";
			$sendParams['singlevalue'.$value] = $value;
		}
		$sql = substr($sql,0,strlen($sql)-2); //remove last comma and space
		$sql .= " )";
	}

	if (!isset($params['include_unused']) || ($params['include_unused'] == 0) ) { // return media for a specific content id, or a list thereof
		$sql .= " AND content_media.id IS NOT NULL";
	}

	if (isset($params['has_tag'])) { // search for tags

		$arrTags = explode(",",$params['has_tag']);

		if (is_array($arrTags)) {
			$sql .= " AND ( ";
			foreach ($arrTags as $term) {
				$i++;
				$sql .= " terms.name LIKE :term".$i." OR";
				$sendParams['term'.$i] = "%".$term."%";
			}
			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " ) ";
		}
		else {
			$sql .= " AND terms.name LIKE :has_tag ";
			$sendParams['has_tag'] = "%".$params['has_tag']."%";
		}
	}

	if (isset($params['search_caption'])) { // search caption

		$arrSearchTerms = explode(",",$params['search_caption']);

		if (is_array($arrSearchTerms)) {

			$sql .= " AND ( ";

			foreach ($arrSearchTerms as $term) {
				$i++;
				$sql .= " media.caption LIKE :term".$i." OR";
				$sendParams['term'.$i] = "%".$term."%";
			}
			// remove last "OR"

			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " ) ";

		}
	}

	if (isset($params['search_credits'])) { // search credits

		$arrSearchTerms = explode(",",$params['search_credits']);

		if (is_array($arrSearchTerms)) {

			$sql .= " AND ( ";

			foreach ($arrSearchTerms as $term) {
				$i++;
				$sql .= " media.credits LIKE :term".$i." OR";
				$sendParams['term'.$i] = "%".$term."%";
			}

			// remove last "OR"

			$sql = substr($sql,0,strlen($sql)-2);

			$sql .= " ) ";

		}
	}

	// NOW, LETS GET ANY EXTRA PARAMS AND APPLY THOSE TO THE WHERE CLAUSE!

	foreach ($params as $key=>$value)
	{
		if (!in_array($key,$validParams)) // this is a custom parameter
		{
			if (in_array($key, $columnsArray)) // checks for misspelling of field name
			{
				$sql .= " AND " . $key . " = :".$key;
				$sendParams[$key] = $value;
			}
			else die("Unknown field name '$key'.");
		}
	}

	if(isset($params['include_thumb']))
	{
		if($params['include_thumb'] == '0')
		$sql .= " AND content_media.usage_type != 'list_thumbnail' AND content_media.usage_type != 'main_thumbnail' ";
	}

	$sql .=" GROUP BY media.id";


	// ORDER BY

	if (isset($params['orderby'])) {
		$sql .= " ORDER BY ".$params['orderby'];
	}
	else if (isset($params['contentid']))
	$sql .= " ORDER BY content_media.displayorder ASC";
	else
	$sql .= " ORDER BY media.id ASC";

	//	print_r($sendParams);
	//print_r($sql);

	//print_r($sql);
	// get the results
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}

function contentSearch($params)
{
	/*
		-- VALID PARAMS --
		-- REQUIRED PARAMS --

		search_terms - search words to search for (comma-delimited). this searches title, description + custom fields.

		*/

	$sendParams = array();
	$i = 0;

	if (!$params['search_terms'])
	die("search_terms is required");

	$validParams = array("action","contentid","include_children","typeid","has_tag","search_terms","search_description","search_customfields","verbosity","parentid","orderby");

	$sql = "";

	if (!isset($params['type']) || $params['type'] == 'content') {

		$sql .= " ( SELECT 'content' as type, content.id as contentid, content.parentid as parentid, 0 as mediaid, content.templateid," .
				   "content.migtitle as contenttitle, '' as mediatitle, content.createdby, content.createdate, content.modifiedby, content.modifieddate, " .
				   "templates.name AS templatetitle, templates.classname AS templateclassname, content.containerpath AS path, '' AS diskpath ";

		$sql .= " FROM content
				  LEFT JOIN content_terms ON content_terms.contentid = content.id
				  LEFT JOIN term_taxonomy ON term_taxonomy.id = content_terms.termid
				  LEFT JOIN terms ON terms.id = term_taxonomy.termid
				  LEFT JOIN templates ON templates.id = content.templateid 
				";


		// WHERE CLAUSE INFO

		$sql .= " WHERE content.search_exclude <> 1 AND deleted='0' ";

		if (isset($params['search_terms'])) { // general search

			$arrSearchTerms = explode(",",$params['search_terms']);

			if (is_array($arrSearchTerms)) {

				$sql .= " AND ( ";

				foreach ($arrSearchTerms as $term) {
					$i++;
					$sql .= " content.migtitle LIKE :term".$i." OR";

					///!!!! crucial for tag search - use like ins
					//$sql .= " tags.tag = :termtags".$i." OR";
					//$sendParams['termtags'.$i] = $term;

					$sql .= " terms.name LIKE :term".$i." OR";
					$sendParams['term'.$i] = "%".$term."%";
				}

				// remove last "OR"

				$sql = substr($sql,0,strlen($sql)-2);

				$sql .= " ) ";

				foreach ($params as $key=>$value)
				{
					if (!in_array($key,$validParams))
					{ // this is a custom parameter
						$sql .= " AND " . $key  . " = :'".$key;
						$sendParams[$key] = $value;
					}
				}
			}
		}

		// GROUP BY CLAUSE

		$sql .= " GROUP BY content.id ) ";

	}

	// ORDER BY

	$sql .= " ORDER BY contentid,mediaid,createdate DESC";


	// get the results
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}

function migSearch($params)
{
	/*
		-- VALID PARAMS --
		-- REQUIRED PARAMS --

		search_terms - search words to search for (comma-delimited). this searches title, description + custom fields.

		-- OPTIONAL PARAMS --

		type - media or content.
		*/

	$sendParams = array();
	$i = 0;

	if (!$params['search_terms'])
	die("search_terms is required");

	$validParams = array("action","contentid","include_children","typeid","has_tag","search_terms","search_description","search_customfields","verbosity","parentid","orderby");

	$sql = "";

	//type = content

	if (!isset($params['type']) || $params['type'] == 'content') {

		$sql .= " ( SELECT 'content' as type, content.id as contentid, 0 as mediaid, content.templateid,content.migtitle as contenttitle, " .
				"'' as mediatitle, content.createdby, content.createdate, content.modifiedby, content.modifieddate, templates.name AS templatetitle, " .
				"templates.classname AS templateclassname, content.containerpath AS path, '' AS diskpath ";

		$sql .= " FROM content
			  	  LEFT JOIN content_terms AS content_terms ON content_terms.contentid = content.id
			      LEFT JOIN term_taxonomy AS term_taxonomy ON term_taxonomy.id = content_terms.termid 
			      LEFT JOIN terms AS terms ON terms.id = term_taxonomy.termid
				  LEFT JOIN templates ON templates.id = content.templateid
				  
			LEFT JOIN (
	
				SELECT content_content.contentid,GROUP_CONCAT(content_content.contentid2 ORDER BY content_content.id) AS contentids, content_content.desc
				FROM content_content
				GROUP BY content_content.contentid
			
 			 ) AS content1 ON content1.contentid = content.id

			  LEFT JOIN (
	
				SELECT content_content.contentid2,GROUP_CONCAT(content_content.contentid ORDER BY content_content.id) AS contentids, content_content.desc
				FROM content_content
				GROUP BY content_content.contentid2
			
 			 ) AS content2 ON content2.contentid2 = content.id";


		// WHERE CLAUSE INFO

		$sql .= " WHERE content.search_exclude <> 1 AND deleted='0' ";

		if (isset($params['search_terms'])) { // general search

			$arrSearchTerms = explode(",",$params['search_terms']);

			if (is_array($arrSearchTerms)) {

				$sql .= " AND ( ";

				foreach ($arrSearchTerms as $term) {
					$i++;
					$sql .= " content.migtitle LIKE :term".$i." OR";
					$sql .= " content1.desc LIKE :term".$i." OR";
					$sql .= " content2.desc LIKE :term".$i." OR";
					$sql .= " content.customfield1 LIKE :term".$i." OR";
					$sql .= " content.customfield2 LIKE :term".$i." OR";
					$sql .= " content.customfield3 LIKE :term".$i." OR";
					$sql .= " content.customfield4 LIKE :term".$i." OR";
					$sql .= " content.customfield5 LIKE :term".$i." OR";
					$sql .= " content.customfield6 LIKE :term".$i." OR";
					$sql .= " content.customfield7 LIKE :term".$i." OR";
					$sql .= " content.customfield8 LIKE :term".$i." OR";

					///!!!! crucial for tag search
					//$sql .= " tags.tag = :termtags".$i." OR";
					//$sendParams['termtags'.$i] = $term;

					$sql .= " terms.name LIKE :term".$i." OR";
					$sendParams['term'.$i] = "%".$term."%";
				}

				// remove last "OR"

				$sql = substr($sql,0,strlen($sql)-2);

				$sql .= " ) ";
			}
		}

		// GROUP BY CLAUSE

		$sql .= " GROUP BY content.id ) ";

		if (!isset($params['type']))
		$sql .= " UNION ALL";
	}

	// type = media

	if (!isset($params['type']) || $params['type'] == 'media') {

		$sql .= "( SELECT 'media' as type, content.id as contentid, media.id as mediaid, 0 as templateid, content.migtitle as contenttitle, media.name as mediatitle, media.createdby, media.createdate, media.modifiedby, media.modifieddate, '' as templatetitle, '' as templateclassname, content.containerpath AS path, media.path AS diskpath";

		$sql .= " FROM media
				  LEFT JOIN media_terms ON media_terms.mediaid = media.id
				  LEFT JOIN terms ON terms.id = media_terms.termid
				  LEFT JOIN content_media ON content_media.mediaid = media.id
				  LEFT JOIN content ON content.id = content_media.contentid";

		$sql .= " WHERE media.id <> 0 ";


		if (isset($params['search_terms'])) { // search for tags

			$arrTerms = explode(",",$params['search_terms']);

			if (is_array($arrTerms)) {

				foreach ($arrTerms as $term) {
					$i++;

					///!!!! crucial for tag search
					//$sql .= " AND ( tags.tag = :termtags".$i." OR";
					//$sendParams['termtags'.$i] = $term;

					$sql .= " AND ( terms.name LIKE :term".$i." OR";
					$sql .= " content_media.caption LIKE :term".$i." OR";
					$sql .= " media.name LIKE :term".$i." OR";
					$sql .= " content_media.credits LIKE :term".$i." ";
					$sql .=" )";
					$sendParams['term'.$i] = "%".$term."%";
				}
			}
		}

		$sql .= "GROUP BY media.id, content_media.contentid ) ";

		$sql .= "
	
			UNION ALL
			
			( SELECT 'media' as type, 0 AS contentid, media.id as mediaid, 0 as templateid, '' as contenttitle, media.name as mediatitle, media.createdby, media.createdate, media.modifiedby, media.modifieddate, '' as templatetitle, '' as templateclassname, '' AS path, media.path AS diskpath";

		$sql .= " FROM media
				  LEFT JOIN media_terms ON media_terms.mediaid = media.id
				  LEFT JOIN content_media ON content_media.mediaid = media.id
				  LEFT JOIN terms ON terms.id = media_terms.termid";

		$sql .= " WHERE media.id <> 0 ";

		if (isset($params['search_terms'])) { // search for tags

			$arrTerms = explode(",",$params['search_terms']);

			if (is_array($arrTerms)) {

				foreach ($arrTerms as $term) {
					$i++;

					///!!!! crucial for tag search
					//$sql .= " AND ( tags.tag = :termtags".$i." OR";
					//$sendParams['termtags'.$i] = $term;

					$sql .= " AND ( terms.name LIKE :term".$i." OR";
					$sql .= " content_media.caption LIKE :term".$i." OR";
					$sql .= " media.name LIKE :term".$i." OR";
					$sql .= " content_media.credits LIKE :term".$i." ";
					$sql .=" )";
					$sendParams['term'.$i] = "%".$term."%";
				}
			}
		}

		$sql .= "GROUP BY media.id )";
	}

	// ORDER BY

	$sql .= " ORDER BY contentid,mediaid,createdate DESC";

	// get the results
	$result = queryDatabase($sql,$sendParams);

	// return the results
	return $result;
}

function returnTagAttributes($row)
{
	global $search; global $values;
	$keyvalues = array();
	foreach ($row as $key=>$value) {
		$value = stripslashes($value);
		$value = str_replace($search, $values, $value);
		$keyvalues[$key] = $value;
	}
	$tagAttr = "id=\"".$keyvalues['id']."\" parentid=\"".$keyvalues['parentid']."\" migtitle=\"".$keyvalues['migtitle'] ."\" containerpath=\"".$keyvalues['containerpath'] ."\" is_fixed=\"".$keyvalues['is_fixed']."\"";

	return $tagAttr;
}

function returnChildren($contentid)
{
	global $statusid;
	$sendParams = array();
	$sql = "SELECT  content.id,content.parentid,content.migtitle,content.containerpath,is_fixed FROM `content` WHERE parentid = :contentid";
	$sendParams['contentid'] = $contentid;

	if($statusid != -1) {
		$sql .=  " AND deleted='0' AND content.statusid= :statusid ORDER BY displayorder";
		$sendParams['statusid'] = $statusid;
	}
	else
	$sql .= " AND deleted = '0' ORDER BY displayorder";

	$result = queryDatabase($sql, $sendParams);

	$xml = "";
	while ($row = $result->fetch(PDO::FETCH_ASSOC)) {
		$xml.= "<container ".returnTagAttributes($row).">";

		if ($x = returnChildren($row['id']))
		$xml .= $x;
		$xml.= "</container>";
	}
	return $xml;
}

function getChildren($contentid, $depth = null)
{
	// returns array of children for a given contentid
	global $arrChildIDs;
	$arrChildIDs = array();
	if ($contentid != 0) { // this gets rid of unintentional behavior when contentid is set to 0 (which means none, not parent of all!)
		fetchChildren($contentid,$depth,0);
		return $arrChildIDs;
	}
}

function fetchChildren($contentid,$depth,$level = 0){ // this function is used by get children recursively
	global $arrChildIDs;
	// retrieve all children of $parent
	$sendParams = array();
	$sql = "SELECT content.id FROM content WHERE parentid = :contentid";
	$sendParams['contentid'] = $contentid;
	$result = queryDatabase($sql, $sendParams);
	while ($row = $result->fetch(PDO::FETCH_ASSOC))
	{
		$arrChildIDs[] = $row['id'];
		if( $depth == -1)
		{
			fetchChildren($row['id'], $level+1);
		}
		else if($level+1 < $depth)
		{
			fetchChildren($row['id'], $level+1);
		}
	}
}

function getTerms($params) {

	/*
		-- VALID PARAMS --
		-- ALL ARE OPTIONAL --	

		//tagid (int) - specifies a specific media id to return (can be comma-delimited)
		//contentids (int) - specifies a specific content id to return media results for (can be comma-delimited)
		//include_unused (1,0) - include media that is not tied to content - defaults to 0 (NO).
		*/

	$sendParams = array();
	$validParams = array("action","tagid","contentid","include_unused");


	$sql = "SELECT termtaxonomy_customfields.fieldid, customfields.name, customfields.displayname
			FROM termtaxonomy_customfields 
 			LEFT JOIN customfields ON customfields.id = termtaxonomy_customfields.customfieldid	";

	$result = queryDatabase($sql);
	$customfields = array();

	if ($result->rowCount() > 0) { // make sure some custom fields exist!

		while ($row = $result->fetch(PDO::FETCH_ASSOC))
		$customfields[$row['fieldid']] = $row['name'];

		// now cycle through all params, and translate to custom field number if we have one
		foreach ($params as $key=>$value) {

			if ($cfKey = array_search($key, $customfields)) {

				$params['customfield'.$cfKey] = $params[$key];
				unset($params[$key]);

			}
		}
	}	

	// define the sql query

	$sql = "SELECT";	 
	foreach ($customfields AS $key=>$value)
		$sql .= " term_taxonomy.customfield".$key." AS ".$value.",";


	$sql .= " terms.name,terms.slug,terms.name,terms.slug,term_taxonomy.id,term_taxonomy.parentid,term_taxonomy.termid,term_taxonomy.displayorder,term_taxonomy.taxonomy, 
			GROUP_CONCAT(DISTINCT content_terms.contentid) AS contentids,
			GROUP_CONCAT(DISTINCT content.migtitle) AS contenttitles,
		    GROUP_CONCAT(DISTINCT media.path,media.name) AS mediatitles,
		    GROUP_CONCAT(DISTINCT media.id) AS mediaids";


	$sql .= " FROM term_taxonomy
			  LEFT JOIN terms ON terms.id = term_taxonomy.termid
			  LEFT JOIN content_terms ON content_terms.termid = term_taxonomy.id
			  LEFT JOIN content ON (content.id = content_terms.contentid  AND content.deleted = 0)
			  LEFT JOIN media_terms ON media_terms.termid = terms.id
			  LEFT JOIN media ON media.id = media_terms.mediaid";
	// WHERE CLAUSE INFO

	$sql .= " WHERE term_taxonomy.id <> 0 ";

	foreach ($params as $key=>$value)
	{
		if (!in_array($key,$validParams))
		{ // this is a custom parameter
			$sql .= " AND " . $key . " = :".$key;
			$sendParams[$key] = $value;
		}
	}

	$sql .=" GROUP BY term_taxonomy.id";

	// ORDER BY
	$sql .= " ORDER BY term_taxonomy.displayorder ASC";
	$result = queryDatabase($sql, $sendParams);

	// return the results
	return $result;
}

function sendUserInformation($params) {
	if(isset($params["email"])) {
		$sendParams;
		$sql = "SELECT * from user";
		$sql .= " WHERE email=:email ";
		$sendParams['email'] = $params['email'];
		$result = queryDatabase($sql, $sendParams);

		$count = 0;
		while ($row = $result->fetch(PDO::FETCH_ASSOC))
		{
			$count++;
			$body = "Here is your requested user information.\r\n";
			$body.= "username: ". $row["username"] ."\r\n";
			$body.= "password: ". text_decrypt($row["password"])."\r\n \r\n";
			$email = $row["email"];
		}

		if($count == 1) {
			$headers = "From: mig@themapoffice.com \r\n";
			$headers.= "Content-Type: text/plain; charset=UTF-8";
			$headers.= "MIME-Version: 1.0 ";
			mail($email, "Your MiG account information", $body, $headers);
			sendSuccess();
		}
		else if($count == 0) die ("No such email");
		else die("Contact System administrator");
	}
	else
	die ("No email was provided");
}
?>