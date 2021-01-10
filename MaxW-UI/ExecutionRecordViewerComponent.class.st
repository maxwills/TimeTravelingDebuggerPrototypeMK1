Class {
	#name : #ExecutionRecordViewerComponent,
	#superclass : #WAComponent,
	#instVars : [
		'autoRefresh',
		'myCodeOnly',
		'goToIndex',
		'assignmentsOnly'
	],
	#classInstVars : [
		'displayedHtml',
		'currentDebugger',
		'currentComponent'
	],
	#category : #'MaxW-UI'
}

{ #category : #accessing }
ExecutionRecordViewerComponent class >> currentComponent [
	^ currentComponent
]

{ #category : #accessing }
ExecutionRecordViewerComponent class >> currentComponent: anObject [
	currentComponent := anObject
]

{ #category : #accessing }
ExecutionRecordViewerComponent class >> currentDebugger [
	^ currentDebugger
]

{ #category : #accessing }
ExecutionRecordViewerComponent class >> currentDebugger: anObject [
	currentDebugger := anObject
]

{ #category : #accessing }
ExecutionRecordViewerComponent class >> displayedHtml [
	^ displayedHtml
]

{ #category : #accessing }
ExecutionRecordViewerComponent class >> displayedHtml: anObject [
	displayedHtml := anObject
]

{ #category : #'as yet unclassified' }
ExecutionRecordViewerComponent class >> getUrlParametersForLink [
^ self currentComponent ifNil: [ 'myCodeOnly=true&autoRefresh=false'] ifNotNil:[
'myCodeOnly=',self currentComponent myCodeOnly asString, '&autoRefresh=false']
	
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> assignmentsOnly [
	^ assignmentsOnly
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> assignmentsOnly: anObject [
	assignmentsOnly := anObject
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> autoRefresh [
	^ autoRefresh
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> autoRefresh: anObject [
	autoRefresh := anObject
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> currentDebugger [
^	self class currentDebugger
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> displayedHtml [
^	(self class displayedHtml) ,'<div id="end"></div>'
]

{ #category : #'as yet unclassified' }
ExecutionRecordViewerComponent >> getStyleAssignmentsOnly [

	^ self assignmentsOnly
		  ifTrue: [ 
			  '
			div[assignment=true] p:nth-child(1) {
			    /* overflow: initial !important;
    height: 20px !important;*/
    display: block !important;
}
		div>p {
		display:none;
		    /*overflow: hidden;
		    height: 0px;*/
		    padding: 0px;
		}
		
		
		
		' ]
		  ifFalse: [ 
			  '
			p{
				display:none;
			}
			p:nth-child(1){
		display:inline-block !important;
	}
			' ]
]

{ #category : #'as yet unclassified' }
ExecutionRecordViewerComponent >> getStyleForMyCodeOnly [

	^ self myCodeOnly
		  ifTrue: [ 
			  '
			div{
				/*padding:3px;
				padding-left:5px;
				margin:3px;*/
				background-color:#00497f04;
			}
			
			div.UndefinedObject[method="DoIt"] p:nth-child(1) {
			    /* overflow: initial !important;
    height: 20px !important;*/
    display: block !important;
padding:3px;
}
		div>p {
		display:none;
		    /*overflow: hidden;
		    height: 0px;*/
		    padding: 0px;
		}
		
		
		
		' ]
		  ifFalse: [ 
			  '
			p{
				display:none;
			}
			p:nth-child(1){
		display:inline-block !important;
	}
			' ]
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> goToIndex [
	^ goToIndex
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> goToIndex: anObject [
	goToIndex := anObject
]

{ #category : #hooks }
ExecutionRecordViewerComponent >> initialRequest: aRequest [
	super initialRequest: aRequest.
	self class currentComponent: self.
	autoRefresh := aRequest at: 'autoRefresh'.
	myCodeOnly := aRequest at: 'myCodeOnly'.
	assignmentsOnly  := aRequest at: 'assignmentsOnly'.
	assignmentsOnly := assignmentsOnly = 'true'
		              ifTrue: [ true ]
		              ifFalse: [ false ].
	autoRefresh := autoRefresh = 'true'
		               ifTrue: [ true ]
		               ifFalse: [ false ].
	myCodeOnly := myCodeOnly = 'true'
		              ifTrue: [ true ]
		              ifFalse: [ false ].
		(aRequest includesKey: 'goToIndex') ifTrue:[
		goToIndex := aRequest at:'goToIndex'.
		goToIndex := goToIndex ifNil: [ nil ] ifNotNil:[ goToIndex asNumber].
		goToIndex ifNotNil:[
			self currentDebugger goToIndex: goToIndex
			]] ifFalse: [ goToIndex := nil ]
				
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> myCodeOnly [
	^ myCodeOnly
]

{ #category : #accessing }
ExecutionRecordViewerComponent >> myCodeOnly: anObject [
	myCodeOnly := anObject
]

{ #category : #rendering }
ExecutionRecordViewerComponent >> renderContentOn: html [
	html html: self displayedHtml
]

{ #category : #hooks }
ExecutionRecordViewerComponent >> script [
	"The same as #style except that it is for JavaScript. This is rarely used, consider using WAFileLibrary or exernal files instead."
	|scriptSection|
	scriptSection :=''.
	 (self autoRefresh) ifTrue: [scriptSection := scriptSection , 'setTimeout(function(){  window.location.reload(false); 
		/*window.scroll(0,30000); */
		
		
		
		}, 500);
		setTimeout(function(){  
		var offsetTop = document.querySelector("#end").offsetTop;
		  scroll({
		    top: offsetTop,
		    behavior: "smooth"
		  });
		
		}, 1);
		
		
		', String cr].

	^ scriptSection
]

{ #category : #hooks }
ExecutionRecordViewerComponent >> style [

	"Returns a CSS stylesheet associated with this component. This stylesheet will be added to <head> section of the html document so it will be global and not scoped.

	This is done for all visible components (see class comment of WAComponent for what visible means).

	Nice for demos but consider using WAFileLibrary or external files instead."

	^ '
	div {
	padding:3px;
	padding-left:15px;
		padding-top:8px;
	border-width:1px;
	border-color:#8a8a8a;
	border-radius: 5px;
	margin:3px;
	margin-left:0px;
	background-color:#00497f08; /*With the alpha value we simulate the deepening of the nodes in the tree*/
		/* border-style:solid; */
	    box-shadow: 0px 0px 5px -1px #001750aa;
		}
	p{
	 margin:0px;
	padding-top:3px;
		padding-bottom:3px;
	}
	span.ens-style-class-method-span{
		font-weight: bold;
    font-size: 12px;
    display: block;
    margin-bottom: 3px;	
	}
	
	span.ens-style-source-span{
		    display: inline-block;
		    font-size: 15px;
	}
	
	span.ens-style-assignment{
			    border-color: #3e578e;
			    display: inline-block;
			    font-size: 13px;
			    font-weight: bold;
			    background-color: #428d9e;
			    border-style: solid;
    border-width: 1px;
    border-radius: 8px;
    padding: 3px;
    padding-left: 5px;
    padding-right: 5px;
    margin: -5px;
    margin-left: 10px;
    color: #d2e5ff;
}
	
	a.ens-style-go-to{
	  font-size: 15px;
	    font-weight: bolder;
    display: inline-block;
    text-decoration: none;
    cursor: pointer;
	margin-left:5px;
	color:#115599;
	}
	a.ens-style-go-to:hover{
	 	color:#11b5f9; 
	}
	[unwinding="true"]{
display:none;
}
	body {
	font-family: Verdana, sans-serif;
	}
html {
  scroll-behavior: smooth;
}
	
	' , (self assignmentsOnly ifTrue:[self getStyleAssignmentsOnly] ifFalse: [self getStyleForMyCodeOnly])
]
