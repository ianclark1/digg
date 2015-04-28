<cfset initArgs = structNew()>
<cfset initArgs.maxCount=10 />
<cfset initArgs.outputFormat = "query" /> <!--- can be query or rawXml--->
<cfset initArgs.applicationKey = "http://www.digg.com" /><!--- can be Any URL, they use it only for statistical purposes--->

<cfset diggObj = createObject("component","digg").init(argumentCollection=initArgs)>

<cfset args = structNew()>
<cfset args.diggUserName= "anujgakhar"> 
<cfset res = diggObj.getUser(argumentCollection=args) /> 
<cfset res1 = diggObj.getDiggsByUser(argumentCollection=args) /> 

<cfset res2 = diggObj.getTopics() /> <!--- list of all available topics--->
<cfset res3 = diggObj.getContainers() /> <!--- list of all available containers/categories--->

<cfset args = structNew()>
<cfset args.storyId = "4622681" /> <!--- can be a comma separated list of digg story Id's'--->
<cfset res4 = diggObj.getStoryById(argumentCollection=args) /> <!--- get a list of stories --->

<cfset args = structNew()>
<cfset args.storyId = "4622681" /> <!---one single storyid--->
<cfset res5 = diggObj.getCommentsByStory(argumentCollection=args) /> <!--- get comments on one story--->

<cfset args = structNew()>
<cfset args.containerName= "technology"><!--- get available containers from getContainers()--->
<cfset args.storyType = "popular"><!--- popular, hot, upcoming or top--->
<cfset res6 = diggObj.getStoriesByContainer(argumentCollection=args) /> <!--- stories inside a container/category--->

<cfset args = structNew()>
<cfset args.storyType = "popular"><!--- popular, hot, upcoming or top--->
<cfset res7 = diggObj.getStories(argumentCollection=args) /> 


<cfdump var = "#res#">
<cfdump var = "#res1#">
<cfdump var = "#res2#">
<cfdump var = "#res3#">
<cfdump var = "#res4#">
<cfdump var = "#res5#">
<cfdump var = "#res6#">
<cfdump var = "#res7#">
