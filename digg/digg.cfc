<cfcomponent>

<cfset this.diggBaseUrl = "http://services.digg.com/" />
<cfset this.appKey = "" />
<cfset this.urltoSubmit = "" />
<cfset this.count = 1 />
<cfset this.userAgent = "Mozilla/5.0 (Windows) diggCFC">
<cfset this.outputFormat = "rawXml">

<!--- Function to Initiate the CFC Object and set global values
applicationKey can be any URL and has to be UrlEncoded to meeet API specifications
maxCount is the number of rows returned from DIgg...maximum is 100
outputFormat is the format returned...either Query or rawXml...default is rawXml
--->
<cffunction name="init" access="public" returntype="digg">
      <cfargument name="applicationKey" type="string" required="true"  />
      <cfargument name="maxCount" type="numeric" required="false" default="10" />
	  <cfargument name="outputFormat" type="string" required="false" default="rawXml" />
      <cfset this.appKey = UrlEncodedFormat(arguments.applicationKey) />
      <cfset this.count = arguments.maxCount />
	  <cfset this.outputFormat = arguments.outputFormat />
      <cfreturn this />
</cffunction>

<!--- This function handles the CFHTTP call to Digg API
makes sure the statusCode is 200 else throws an error
--->
<cffunction name="doSend" returntype="any" access="private">
	  <cftry>
     	 <cfhttp url="#this.urltoSubmit#" useragent="#this.userAgent#"></cfhttp>
	  <cfcatch type="any">
		<cfreturn errorMessage(cfcatch) />		
	  </cfcatch>
	  </cftry>	
	  <cfif cfhttp.statusCode EQ '200 OK'>	
		  <cfif this.outputFormat EQ 'rawXml'>	
		      <cfreturn cfhttp.fileContent />
		   <cfelseif this.outputFormat EQ 'query'> 
		      <cfreturn Xml2Query(cfhttp.fileContent)>
		   </cfif> 
	  <cfelse>
	  	<cfreturn errorMessage(cfhttp) />		
	  </cfif>
</cffunction>

<cffunction name="errorMessage" access="private">
	<cfset tempStruct = StructNew()>
	<cfset tempStruct.fault = "true">
	<cfset tempStruct.faultString = "#arguments[1]#">
	<cfreturn tempStruct />
</cffunction>

<!--- DIGG API functions below this line--->
<cffunction name = "getContainers" access="public" returnType="any">
      <cfset this.urltoSubmit = this.diggBaseUrl & "containers?appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<cffunction name = "getTopics" access="public" returnType="any">
      <cfset this.urltoSubmit = this.diggBaseUrl & "topics?appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<cffunction name = "getUser" access="public" returnType="any">
	  <cfargument name="diggUserName" type="string" required="true" /> 
      <cfset this.urltoSubmit = this.diggBaseUrl & "user/#arguments.diggUserName#?appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<cffunction name = "getDiggsByUser" access="public" returnType="any">
      <cfargument name="diggUserName" type="string" required="true" />  
      <cfset this.urltoSubmit = this.diggBaseUrl & "user/#arguments.diggUserName#/diggs?appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<cffunction name = "getStoryById" access="public" returnType="any">
      <cfargument name="storyId" type="string" required="true" hint="can be a list of comma separated storyId's" /> 
      <cfset this.urltoSubmit = this.diggBaseUrl & "stories/#arguments.storyId#?appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<cffunction name = "getCommentsByStory" access="public" returnType="any">
      <cfargument name="storyId" type="string" required="true" hint="one single storyId" /> 
      <cfset this.urltoSubmit = this.diggBaseUrl & "story/#arguments.storyId#/comments?appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<cffunction name = "getStoriesByContainer" access="public" returnType="any">
      <cfargument name="storyType" type="string" required="false" hint="popular,upcoming,top or hot" default="" />  
      <cfargument name="containerName" type="string" required="true" hint="name of the container" /> 
	  <cfset var typeSuffix = "" />	
	  <cfif len(Arguments.storyType) AND Find(arguments.storyType,"hot,top,popular,upcoming")>
		  <cfset typeSuffix = "/#arguments.storyType#" />
	  </cfif>    
      <cfset this.urltoSubmit = this.diggBaseUrl & "stories/container/#arguments.containerName##typeSuffix#?count=#this.count#&appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<cffunction name = "getStories" access="public" returnType="any">
      <cfargument name="storyType" type="string" required="true" hint="popular,upcoming,top or hot" />  
	  <cfset var typeSuffix = "" />	
	  <cfif len(Arguments.storyType) AND Find(arguments.storyType,"hot,top,popular,upcoming")>
		  <cfset typeSuffix = "/#arguments.storyType#" />
	  </cfif> 
      <cfset this.urltoSubmit = this.diggBaseUrl & "stories#typeSuffix#?count=#this.count#&appkey=" & this.appKey />
      <cfreturn doSend() />   
</cffunction>

<!--- function to convert XML to CF query
from http://www.throwingbeans.org/xmldb.cfc

Modified a bit to get rid of one of the errors
--->
<cffunction name = "XML2Query" access="private" returntype="query" hint="Convert an XML string into a query">
	<cfargument name="XML" type="string" required="yes" hint="XML string to be converted to query">
	<cfargument name="XPath" type="string" required="no" hint="Optional XPath statement to apply to XML before conversion">
	<cfscript>
	var xmldoc = xmlparse(arguments.XML);
	if (isdefined('arguments.XPath')) {
		topnodes = XMLSearch(xmldoc,arguments.xpath);
	} else {
		topnodes = xmldoc.XmlRoot.XmlChildren;
	}
	
	/* return empty query if there are no childnodes */
	if (arraylen(topnodes) eq 0) {
		xquery = querynew('noresults');
		return xquery;
		break;
	}
	
	currentelement = topnodes[1].XMLName;
	columns = currentelement;
	// get attribute names
	listofattributes = arraytolist(StructKeyArray(topnodes[1].XMLAttributes));
	for (j = 1; j LTE listlen(listofattributes); j = j + 1) {
		attributename = currentelement & '_' & listgetat(listofattributes,j);
		if (listfindnocase(columns,attributename) eq 0) {
			columns = listappend(columns,attributename);
		}
	}
	// get child element names
	arrayofchildren = topnodes[1].XMLChildren;
	for (k = 1; k LTE arraylen(arrayofchildren); k = k + 1) {
		childname = currentelement & '_' & arrayofchildren[k].XMLName;
		if (listfindnocase(columns,childname) eq 0) {
			columns = listappend(columns,childname);
		}
	}
	
	// add rows to the recordset 
	xquery = querynew(columns);
	for (i = 1; i LTE arraylen(topnodes); i = i + 1) {
		// first set the element value 
		queryaddrow(xquery);
		currentelement = topnodes[i].XMLName;
		currentelementvalue = topnodes[i].XMLText;
		QuerySetCell(xquery, currentelement, currentelementvalue);
		// now all the attributes 
		structofattributes = topnodes[i].XMLAttributes;
		for (j in structofattributes) {
			attributename = currentelement & '_' & j;
			if (listfindnocase(columns,attributename)) {
				QuerySetCell(xquery, attributename,structFind(structofattributes, j));
			}
		}
		// now all the child elements (probably not necessary for rationalmedia)
		arrayofchildren = topnodes[i].XMLChildren;
		for (k = 1; k LTE arraylen(arrayofchildren);k = k + 1) {
			childname = currentelement & '_' & arrayofchildren[k].XMLName;
			if (listfindnocase(columns,childname)) 
				QuerySetCell(xquery, childname,arrayofchildren[k].XMLText);
		}
	}
	</cfscript>
	<cfreturn xquery>
</cffunction>
</cfcomponent>