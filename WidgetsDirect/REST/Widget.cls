/// REST Endpoint for Widgets
Class REST.Widget Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.widgetsdirect.com/urlmap" ]
{
<Routes>
		<Route Url="/version" 	Method="GET" 	Call="version" 			Cors="false" />
		<Route Url="/" 			Method="GET" 	Call="GetAllWidgets" 	Cors="false" />
		<Route Url="/" 			Method="POST" 	Call="AddNewWidget" 	Cors="false" />	
		<Route Url="/:widgetid" Method="GET" 	Call="GetWidgetById" 	Cors="false" />
		<Route Url="/:widgetid" Method="PUT" 	Call="UpdateWidgetById" Cors="false" />
		<Route Url="/:widgetid"	Method="DELETE" Call="DeleteWidgetById" Cors="false" />		
		</Routes>
}

ClassMethod version() As %Status
{
	Set %response.ContentType="application/json"
	
	SET retObj = {}
	SET retMessage = $zv
	SET retObj.Message = retMessage

	
	WRITE retObj.%ToJSON()
	QUIT $$$OK
}

ClassMethod GetAllWidgets() As %Status
{
	Set %response.ContentType="application/json"
	
	SET retObj = {}
	SET widgetAry = []
	&SQL(DECLARE WidgetCurs CURSOR FOR 
    					    	   SELECT 
								   %Id
								   INTO :Id
								   FROM SQLUser.Widget	
								   where Deleted <> 1 or Deleted is null		
 					)	 
			
    &SQL(OPEN WidgetCurs)
    
    For { &SQL(FETCH WidgetCurs)
    	  Quit:SQLCODE
    	  set widgetObj = ##class(User.Widget).%OpenId(Id)
    	  do widgetAry.%Push(widgetObj.toJSON(1))
	    }
    &SQL(CLOSE WidgetCurs)
	
	// let's get the WWWidgets	
	&SQL(DECLARE WWWidgetCurs CURSOR FOR 
    					    	   SELECT 
								   %Id
								   INTO :Id
								   FROM SQLUser.WWWidget	
				)	 
			
    &SQL(OPEN WWWidgetCurs)
    
    For { &SQL(FETCH WWWidgetCurs)
    	  Quit:SQLCODE
    	  set widgetObj = ##class(User.WWWidget).%OpenId(Id)
    	  do widgetAry.%Push(widgetObj.toJSON(1))
	    }
    &SQL(CLOSE WWWidgetCurs)
	SET retObj.Widgets = widgetAry
	
	WRITE retObj.%ToJSON()
	QUIT $$$OK
}

ClassMethod GetWidgetById(WidgetId As %Integer) As %Status
{
	Set %response.ContentType="application/json"
	
	set tSC = $$$OK
	SET retObj = {}
	SET widgetAry = []
	
    // Safely retrieve object 
    Kill %objlasterror
        set widgetObj = ##class(User.Widget).%OpenId(WidgetId)
        If '$IsObject(widgetObj) {
            // Object with this ID does not exist
            If $Data(%objlasterror) { Set tSC=%objlasterror }
        }
        If $$$ISERR(tSC) { Quit tSC }
    // Set output to JSON representation of object    	  
	SET retObj.Widget = widgetObj.toJSON(1)
	
	WRITE retObj.%ToJSON()
	QUIT tSC
}

ClassMethod AddNewWidget() As %Status
{
	Set %response.ContentType="application/json"
	
	SET retObj = {}
	
	Kill %objlasterror
    set widgetObj = ##class(User.Widget).%New()
    If '$IsObject(widgetObj) {
    	// Object with this ID does not exist
        If $Data(%objlasterror) { Set tSC=%objlasterror }
        }
    Set updateJSON = %request.Content.Read()
    
    Set tSC = widgetObj.fromJSON(updateJSON)
   
        
    If $$$ISERR(tSC) { Quit tSC }
	
	WRITE widgetObj.toJSON().%ToJSON()
	QUIT $$$OK
}

ClassMethod UpdateWidgetById(widgetid As %Integer) As %Status
{
	Set %response.ContentType="application/json"
	
	SET retObj = {}
	
	Kill %objlasterror
	if ($e(widgetid)="W"){
		set widgetObj = ##class(User.WWWidget).%OpenId($e(widgetid,2,*))
		}
	else{
    set widgetObj = ##class(User.Widget).%OpenId(widgetid)
	}
    If '$IsObject(widgetObj) {
    	// Object with this ID does not exist
        If $Data(%objlasterror) { Set tSC=%objlasterror }
        }
    Set updateJSON = %request.Content.Read()
    
    Set tSC = widgetObj.fromJSON(updateJSON)
   
        
    If $$$ISERR(tSC) { Quit tSC }
	
	WRITE widgetObj.toJSON().%ToJSON()
	QUIT $$$OK
}

ClassMethod DeleteWidgetById(widgetid As %Integer) As %Status
{
	Set %response.ContentType="application/json"
	
	SET retObj = {}
	
	Kill %objlasterror
    set widgetObj = ##class(User.Widget).%OpenId(widgetid)
    If '$IsObject(widgetObj) {
    	// Object with this ID does not exist
        If $Data(%objlasterror) { Set tSC=%objlasterror }
        }
   
    
    set widgetObj.Deleted=1
   	set tSC = widgetObj.%Save()
        
    If $$$ISERR(tSC) { Quit tSC }
	
	WRITE widgetObj.toJSON().%ToJSON()
	QUIT $$$OK
}

}
