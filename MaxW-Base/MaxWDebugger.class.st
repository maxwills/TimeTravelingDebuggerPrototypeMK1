Class {
	#name : #MaxWDebugger,
	#superclass : #Object,
	#instVars : [
		'executionRecord',
		'sindarinDebugger',
		'stDebugger',
		'initialEsn',
		'enableHtmlUpdate'
	],
	#category : #'MaxW-Base'
}

{ #category : #adding }
MaxWDebugger >> addBranchFrom: anEns toEnsRepresentationNodeTree: anEnsRepresentationNodeTree [

	| currentNode |
	currentNode := anEnsRepresentationNodeTree.
	1 to: anEns size do: [ :i | 
		| currentToken currentTokenAsString |
		currentToken := anEns at: i.
		currentTokenAsString := currentToken asString.
		(currentNode containsChildEnsToken: currentToken) ifFalse: [ 
			| newNode |
			newNode := EnsRepresentationNode new.
			currentNode children add: newNode.
			newNode
				ens: anEns;
				node: anEns node;
				ensToken: currentToken;
				ensTokenAsString: currentTokenAsString.
			 ].
		currentNode := currentNode childWithEnsToken: currentToken .
				((i = anEns size)and: [anEns isAssignment ]) ifTrue: [
					"this is a patch to include assignments in the hmtl"
					|ensCopy| "Avoid modifying the original, which is still in the executionRecord"
					ensCopy := EsnCreator copyEsnTokenList: currentNode ens.
					ensCopy copyAssignmentFieldsFrom: anEns.
					 currentNode ens: ensCopy ]]
			
		
	"The patch was necessary, because, tree node of the assignment may have already been created (because of the way the tree is built) and has a non assignment ens. With the patch, we fix that"
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> createDivsWriteBlockFromEnsRepresentationNodeTree: anEnsRepresentationNodeTree xmlWriter: anXmlWriter label: aString [

	^ [ 
	  anEnsRepresentationNodeTree ifNil: [ ^ '' ].
	anEnsRepresentationNodeTree children do:[:eachNode|
		|tag tagp|
		tagp:= aString class = String ifTrue:[ anXmlWriter tag:'p' with:aString] ifFalse:[aString value].
		tag := anXmlWriter tag: 'div'.
		tag attributes: { 'class'->eachNode ensToken objectClassName . 'method'->eachNode ensToken method. 'unwinding'-> eachNode ens isUnwinding asString . 'assignment'->(eachNode ens isAssignment) asString }
		"tag attributeAt: 'class' put: eachNode ensToken objectClassName.
		  tag attributeAt: 'method' put: eachNode ensToken method".
		eachNode isLeaf ifFalse:[
			tag with:  
					  (self
						   createDivsWriteBlockFromEnsRepresentationNodeTree: eachNode
						   xmlWriter: anXmlWriter label: (self createEnsReprestationLabelHtml: eachNode writer: anXmlWriter) "(eachNode ens sourceCode)")
			] ifTrue:[tag with: (self createEnsReprestationLabelHtml: eachNode writer: anXmlWriter) "[ anXmlWriter tag: 'p' with: (eachNode ens sourceCode) ]" ]
		]]
	  "aDictionary keysDo: [ :key | 
		  | tag tagp value ensToken |
		  value := aDictionary at: key.
		  ensToken := EsnToken parseFromString: key.
		tagp:= anXmlWriter tag:'p' with:aString.
		  tag := anXmlWriter tag: 'div'.
		  tag attributeAt: 'class' put: ensToken objectClassName.
		  tag attributeAt: 'method' put: ensToken method.
		  value isNotEmpty
			  ifTrue: [ 
				  tag with:  
					  (self
						   createDivsWriteBlockFromDictionary: value
						   xmlWriter: anXmlWriter label:key)
					  ]
			  ifFalse: [ tag with: [ anXmlWriter tag: 'p' with: key ] ] ] ]" 
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> createEnsRepresentationNodeTree [
	| rootNode positionCounter|
	positionCounter:=0.
	rootNode := EnsRepresentationNode new.
	executionRecord do: [ :eachEns | 
		positionCounter := positionCounter +1.
		"eachEns isUnwinding"false ifFalse: [ "We dont add the unwinding nodes to the html, since it messes the nthChild number"
			eachEns positionInRecord: positionCounter.
			self addBranchFrom: eachEns toEnsRepresentationNodeTree: rootNode ] .
		"self addBranchFrom: eachEns toEnsRepresentationNodeTree: rootNode" ].
	
	^ rootNode
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> createEnsReprestationLabelHtml: anEnsReprestationNode writer: anXmlWriter [

	^ [ 
	  anXmlWriter tag: 'p' with: [ 
		
		  anXmlWriter tag: 'span' attributes:  { 'class'->'ens-style-class-method-span'} with: (anEnsReprestationNode ensToken objectClassName ,' » ', anEnsReprestationNode ensToken method).
		anXmlWriter tag: 'a'  attributes:  { 'class'->'ens-style-go-to'. 'href'->('?goToIndex=',anEnsReprestationNode ens positionInRecord asString,'&', ExecutionRecordViewerComponent getUrlParametersForLink)} with: anEnsReprestationNode ensToken nthChild asString,'› '.
		  anXmlWriter tag: 'span'  attributes:  { 'class'->'ens-style-source-span'}  with: (anEnsReprestationNode ens sourceCode)."
		anXmlWriter tag: 'a'  attributes:  { 'class'->'ens-style-go-to'. 'href'->('?goToIndex=',anEnsReprestationNode ens positionInRecord asString,'&', ExecutionRecordViewerComponent getUrlParametersForLink)} with: '	←'".
		anEnsReprestationNode ens isAssignment ifTrue: [ 
				anXmlWriter tag: 'span' attributes:  { 'class'->'ens-style-assignment'} with: ('#', anEnsReprestationNode ens variableName asString,' := ',anEnsReprestationNode ens oldValue asString,' → ', anEnsReprestationNode ens newValue asString) ]] ]
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> createHtml [

	"Creates an html representation of the execution"

	| writer tree|
	writer := XMLWriter new.
	tree:= self createEnsRepresentationNodeTree.
	writer
		enablePrettyPrinting;
		comment: 'Generated by MaxWDebugger';
		tag: 'div' with: (self createDivsWriteBlockFromEnsRepresentationNodeTree: tree xmlWriter: writer label:'Root').
	^writer asString
]

{ #category : #actions }
MaxWDebugger >> currentEsn [
"Builds an Esn object from the current node. This is somewhat slow, moslty because of the recursive Esn createFromNode: fromContext: method. It could be improved by remembering the parentEsn to prevent some recursions. And maybe conver that to an iterative rather than recursive"
|esn lastEnsInRecord|
lastEnsInRecord := executionRecord isEmptyOrNil ifTrue:[nil] ifFalse: [executionRecord last].
esn:=Esn createFromNode: sindarinDebugger node  fromContext: sindarinDebugger context.
esn node: sindarinDebugger node.
esn context: sindarinDebugger context.	
esn auxIsStatement: (self sindarinDebugger node statementNode = self sindarinDebugger node).
"Need to differentiate if this node is already in the record or not to know how to calculate if it is unwinding"
(EsnCreator esn: esn isEqualToNotIncludingUnwinding: lastEnsInRecord) ifTrue:[esn isUnwinding: (self isUnwindingCase: self previousEsn followedBy: esn)] ifFalse:[esn isUnwinding: (self isUnwindingCase: lastEnsInRecord followedBy: esn)].

esn isAssignment: sindarinDebugger node isAssignment .
esn isAssignment ifTrue:[
	esn variableName: sindarinDebugger assignmentVariableName.
	esn oldValue: (sindarinDebugger node variable variable readInContext: sindarinDebugger context) .
	"The new value is only available on unwinding nodes"
	"esn isUnwinding" true ifTrue:[ esn newValue: sindarinDebugger assignmentValue].
	esn esnType: 'assignment'.
	esn variableInfo: sindarinDebugger node variable variable
	].
esn isVariableNode ifTrue:[
	esn realOriginalValue: (sindarinDebugger node variable readInContext: sindarinDebugger context)
	].
^esn
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> doAndUpdateViewAtTheEnd: aBlock [
"Just a guard to prevent unnecessary UI updates. Supports nested calls"
	| oldUpdateFlag |
	oldUpdateFlag := self enableHtmlUpdate.
	self enableHtmlUpdate: false.
	aBlock value.
	self enableHtmlUpdate: oldUpdateFlag.
	oldUpdateFlag ifTrue: self updateExternalHtmlView
]

{ #category : #accessing }
MaxWDebugger >> enableHtmlUpdate [
	^ enableHtmlUpdate
]

{ #category : #accessing }
MaxWDebugger >> enableHtmlUpdate: anObject [
	enableHtmlUpdate := anObject
]

{ #category : #accessing }
MaxWDebugger >> executionRecord [
	^ executionRecord
]

{ #category : #accessing }
MaxWDebugger >> executionRecord: anObject [
	executionRecord := anObject
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> findCorrespondingOpeningOrSubstituteEnsFor: anEns startingAt: aNumber [

	"search for the corresponding 'opening ens' that produced the specified 'unwinding ens'(anEns) in the executionRecord. The search is linear. It start at the aNumber index and search backwards (decreasing positions).
aNumber is an integer that refers to an index in the executionRecord"

	| correspondingEnsCadidate |
	correspondingEnsCadidate := nil.
	(anEns isUnwinding and: anEns isAssignment) ifFalse: [ ^ nil ].
	aNumber to: 1 by:-1 do: [ :i | 
		| pointedEns |
		pointedEns := self executionRecord at: i.
		"just need to find the first ens that contains all the same tokens of anEns (no more)"
		pointedEns size >= anEns size
			ifTrue: [ 
				(anEns sameTokensAs: pointedEns from: 1 to: anEns size) ifTrue: [ 
					correspondingEnsCadidate := pointedEns ] ]
			ifFalse: [ 
			pointedEns size < anEns size ifTrue: [ ^ correspondingEnsCadidate ] ] ].
	^ correspondingEnsCadidate
]

{ #category : #accessing }
MaxWDebugger >> findFirstEnsIndexOfTheSameStatementAsEnsAt: aNumber [
	|theStatementEns statementNode lastValidIndex|
	theStatementEns := executionRecord at: aNumber.
	statementNode := theStatementEns node statementNode.
	lastValidIndex := aNumber.
	(aNumber-1) to: 1 by: -1 do: [ :i|
		|ens|
		ens := executionRecord at: i.
		(ens node statementNode = theStatementEns) ifTrue: [ lastValidIndex := i ] ifFalse: [ ^lastValidIndex ]
		 ].
	^lastValidIndex
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> findLastAssigmentEnsIndexBeforeInclusiveIndex: aNumber [

	executionRecord ifEmpty: [ ^ 0 ].

	"Find the last assignment ens"

	aNumber to: 1 by:-1 do: [ :i |  
		(executionRecord at:i) isAssignment ifTrue: [ ^i ].
		].
	^0
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> getInitialContext: aContext [
	^(aContext sender) ifNil: [aContext] ifNotNil: [self getInitialContext: aContext sender]
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> goBackToLastStatementWhenVariable: aSymbol valueChangedTo: anObjectWithAfterValue [

	| assignmentEnsIndex searchIndex targetEns |
	targetEns := nil.
	searchIndex := executionRecord size.
	[ searchIndex > 0 ] whileTrue: [ 
		assignmentEnsIndex := self 
			                      findLastAssigmentEnsIndexBeforeInclusiveIndex:
			                      searchIndex.
		assignmentEnsIndex > 0 ifTrue: [ 
			| assignmentEns |
			assignmentEns := executionRecord at: assignmentEnsIndex.
			(assignmentEns variableName = aSymbol) ifTrue: [ "found the node with the variable. Need to rescue old and new Val"
				| oldValue newValue |
				oldValue := assignmentEns oldValue.
				newValue := assignmentEns newValue.
				(anObjectWithAfterValue = newValue) ifTrue: [ "found the node where the change happened. Now find the actual node to return to"
					targetEns := self
						             findCorrespondingOpeningOrSubstituteEnsFor:
						             assignmentEns
						             startingAt: assignmentEnsIndex - 1.
					targetEns ifNil: [ 
						targetEns := assignmentEns "we dont have a choice :/ " ].
					searchIndex := 0 "to end the while" ] ] ].
		searchIndex := assignmentEnsIndex - 1 ].
	targetEns ifNotNil: [ self restartFrom: targetEns ]
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> goBackToWhenVariable: aSymbol valueWas: anObjectWithBeforeValue beforeBeing: anObjectWithAfterValue [

	| assignmentEnsIndex searchIndex targetEns |
	targetEns := nil.
	searchIndex := executionRecord size.
	[ searchIndex > 0 ] whileTrue: [ 
		assignmentEnsIndex := self 
			                      findLastAssigmentEnsIndexBeforeInclusiveIndex:
			                      searchIndex.
		assignmentEnsIndex > 0 ifTrue: [ 
			| assignmentEns |
			assignmentEns := executionRecord at: assignmentEnsIndex.
			(assignmentEns variableName = aSymbol) ifTrue: [ "found the node with the variable. Need to rescue old and new Val"
				| oldValue newValue |
				oldValue := assignmentEns oldValue.
				newValue := assignmentEns newValue.
				(anObjectWithBeforeValue = oldValue and:
					 anObjectWithAfterValue = newValue) ifTrue: [ "found the node where the change happened. Now find the actual node to return to"
					targetEns := self
						             findCorrespondingOpeningOrSubstituteEnsFor:
						             assignmentEns
						             startingAt: assignmentEnsIndex - 1.
					targetEns ifNil: [ 
						targetEns := assignmentEns "we dont have a choice :/ " ].
					searchIndex := 0 "to end the while" ] ] ].
		searchIndex := assignmentEnsIndex - 1 ].
	targetEns ifNotNil: [ self restartFrom: targetEns ]
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> goToIndex: targetPosition [

	" targetPosition: a <Number>. The debugger will restart and re-execute all until it reaches the ens with the target position"
	self enableHtmlUpdate: false.
	self restartAll.
	targetPosition > 0 ifTrue: [ 
		self stepUntilConditionIsTrue: [ 
			executionRecord size = targetPosition ] ].
	self enableHtmlUpdate: true.
	self updateExternalHtmlView
]

{ #category : #accessing }
MaxWDebugger >> indexOfEsnInExecutionRecord: anEsn [
	anEsn isNil ifTrue: [ ^ 0 ].
	executionRecord isEmpty ifTrue: [ ^ 0 ].
	1 to: 	executionRecord size do: [ :i | 
		(EsnCreator
			 esn: anEsn
			 isEqualTo: (executionRecord at: i)) ifTrue: [ ^ i ] ].
	^ 0
]

{ #category : #accessing }
MaxWDebugger >> initialEsn [
	^ initialEsn
]

{ #category : #accessing }
MaxWDebugger >> initialEsn: anObject [
	initialEsn := anObject
]

{ #category : #initialization }
MaxWDebugger >> initialize [
	executionRecord := OrderedCollection new.
	enableHtmlUpdate := true "flag to prevent redundant html updates".
]

{ #category : #testing }
MaxWDebugger >> isUnwindingCase: anEsn followedBy: followingEsn [

	"Two detected ways for this to occur. 1. The control is back to the sender node (Walked up tp the ascendant token).2. contorl is back to the parent node (meaing, having a nonNil nthchild followed by a nil)"

	self assert: followingEsn isNotNil.
	self assert: followingEsn isNotEmpty.

	^ anEsn ifNil: [ false ] ifNotNil: [ 
		  | lastEsnToken lastFollowingEsnToken |
		  anEsn isEmpty ifTrue: [ ^ false ].
		  lastEsnToken := anEsn last.
		  lastFollowingEsnToken := followingEsn last.
		  "case 2"
		  ((lastEsnToken method = lastFollowingEsnToken method and:
			    lastEsnToken objectClassName
			    = lastFollowingEsnToken objectClassName) and:
			   (lastEsnToken nthChild isNotNil and:
				    lastFollowingEsnToken nthChild isNil))
			  ifTrue: [ true ]
			  ifFalse: [ 
				 "case 1"
				  anEsn size < 2
					  ifTrue: [ false ]
					  ifFalse: [ 
						  | preLastEsnToken |
						  preLastEsnToken := anEsn at: (anEsn size - 1).
						  lastFollowingEsnToken isEqualTo: preLastEsnToken ] ] ]
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> previousEsn [

	^ self executionRecord isEmpty
		  ifTrue: [ nil ]
		  ifFalse: [ 
			  (self executionRecord size < 2)
				  ifTrue: [ nil ]
				  ifFalse: [ 
				  self executionRecord at: (executionRecord size - 1) ] ]
]

{ #category : #actions }
MaxWDebugger >> previousOverStatementEnsIndex [
|currentStatementNode startingStatementEns|
startingStatementEns := self currentEsn .
currentStatementNode :=sindarinDebugger node statementNode.
executionRecord size to: 1 by:-1 do: [:i|
	|ens|
	ens := (executionRecord at:i).
	(ens node statementNode ~= currentStatementNode and: [ens isUnwinding not]) ifTrue: [
		
				"To detect the next step for the stepOver, we just analize the length of the ens path"
				(ens size <= startingStatementEns size) ifTrue: [
					"Found a ens in the target statement, but we need the first node"
					 ^self findFirstEnsIndexOfTheSameStatementAsEnsAt: i
					].
		
		]
	].
^0
]

{ #category : #actions }
MaxWDebugger >> previousStatementEnsIndex [
|currentStatementNode|
currentStatementNode :=sindarinDebugger node statementNode.
executionRecord size to: 1 by:-1 do: [:i|
	|ens|
	ens := (executionRecord at:i).
	(ens node statementNode ~= currentStatementNode and: [ens isUnwinding not]) ifTrue: [^i ]
	].
^0
]

{ #category : #accessing }
MaxWDebugger >> printExecutionRecord [

	self executionRecord do: [ :each | 
		Transcript
			show: (EsnCreator esnTokenListAsString: each);
			cr ].
	
]

{ #category : #recording }
MaxWDebugger >> recordStep [

	"Records the step. Adds it into the record only if it is different from previous step and also if it is not an unwinding case"

	| currentEsn |
	self assert: sindarinDebugger notNil.
	self assert: stDebugger notNil.

	currentEsn := self currentEsn.
	self executionRecord isEmpty
		ifTrue: [ self executionRecord add: currentEsn ]
		ifFalse: [ 
			| previousEsn |
			previousEsn := self previousEsn .
			( false "(EsnCreator esn: currentEsn isEqualTo: previousEsn)" "or: (self isUnwindingCase: previousEsn followedBy: currentEsn)") ifFalse: [ 
				self executionRecord add: currentEsn ] ].
		self updateExternalHtmlView 
]

{ #category : #actions }
MaxWDebugger >> restartAll [
"Restart Execution to the initial Esn"
sindarinDebugger debugSession restart: (self getInitialContext: sindarinDebugger context).
"self stepUntilEsn: self initialEsn ."
self executionRecord removeAll.
self recordStep .
self stepUntilEsn: self initialEsn .
"self executionRecord add: initialEsn ."
self updateExternalHtmlView .
"stDebugger forceSessionUpdate" 
]

{ #category : #actions }
MaxWDebugger >> restartFrom: anEsn [

	self restartAll.
	self stepUntilEsn: anEsn.
	self updateExternalHtmlView
]

{ #category : #actions }
MaxWDebugger >> restartSenderContext [
	| currentEsn parentEsn parentEsnIndexInExecutionRecord targetContext |
	currentEsn := self currentEsn.
	parentEsn := currentEsn size < 2
		             ifTrue: [ nil ]
		             ifFalse: [ 
		             currentEsn copyFrom: 1 to: currentEsn size - 1 ].
	parentEsnIndexInExecutionRecord := self indexOfEsnInExecutionRecord:
		                                   parentEsn.
	targetContext := sindarinDebugger context sender
		                 ifNil: [ sindarinDebugger context ]
		                 ifNotNil: [ sindarinDebugger context sender ].
	sindarinDebugger debugSession restart:
		(self getInitialContext: sindarinDebugger context).
	"need to modify the execution record. It should end with the parentEsn"
	parentEsnIndexInExecutionRecord > 0 ifTrue: [ "stDebugger forceSessionUpdate"
		executionRecord := executionRecord
			                   copyFrom: 1
			                   to: parentEsnIndexInExecutionRecord ]
]

{ #category : #accessing }
MaxWDebugger >> sindarinDebugger [
	^ sindarinDebugger
]

{ #category : #accessing }
MaxWDebugger >> sindarinDebugger: anObject [
	sindarinDebugger := anObject
]

{ #category : #accessing }
MaxWDebugger >> stDebugger [
	^ stDebugger
]

{ #category : #accessing }
MaxWDebugger >> stDebugger: anObject [
	stDebugger := anObject
]

{ #category : #actions }
MaxWDebugger >> stepBack [

	self doAndUpdateViewAtTheEnd: [
		 "Note: there is no need to restart completetly the execution. Restarting the sender context should be enough... in that case, need to remember which esn was associated to that context (is it the immediate parent?)"
		| previousEsn |
		previousEsn := self previousEsn.
		previousEsn ifNotNil: [ 
			self restartAll.
			"self restartSenderContext" "this works, but need to manually update the execution record" ". stDebugger forceSessionUpdate "
			self stepUntilEsn: previousEsn. "stDebugger forceSessionUpdate"
			self ].
		 ]
]

{ #category : #actions }
MaxWDebugger >> stepBackOverStatement [
|targetIndex|
targetIndex := self previousOverStatementEnsIndex.
self goToIndex: targetIndex .
"	self updateExternalHtmlView ."
]

{ #category : #actions }
MaxWDebugger >> stepBackStatement [
|targetIndex|
targetIndex := self previousStatementEnsIndex.
self goToIndex: targetIndex .
"	self updateExternalHtmlView ."
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> stepForwardToWhenStatementSourceCodeIs: aString [
	self stepUntilConditionIsTrue: [ 
		|ens|
		ens := self currentEsn.
		ens node statementNode sourceCode = aString]
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> stepForwardToWhenStatementSourceIs: aString [
	self stepUntilConditionIsTrue: [ 
		|ens|
		ens := self currentEsn.
		ens node statementNode sourceCode = aString]
]

{ #category : #actions }
MaxWDebugger >> stepInto [
	"MwSindarinHelper doTrueStepInto: self sindarinDebugger "
self sindarinDebugger stepIt.
self recordStep.
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> stepIntoStatement [
|currentStatementNode|
currentStatementNode:=self sindarinDebugger node statementNode .
"self stepInto."
	self stepUntilConditionIsTrue: [ 
		(self sindarinDebugger node statementNode ~= currentStatementNode) and: [self currentEsn isUnwinding =false]
		 ]
]

{ #category : #actions }
MaxWDebugger >> stepOver [
	self sindarinDebugger stepOver.
		self recordStep.
]

{ #category : #actions }
MaxWDebugger >> stepOverStatement [

	self doAndUpdateViewAtTheEnd: [ 
		| currentStatementNode startingStatementEns |
		startingStatementEns := self currentEsn.
		currentStatementNode := self sindarinDebugger node statementNode.
		self stepUntilConditionIsTrue: [ 
			|shouldStop|
			shouldStop := false.
			(self sindarinDebugger node statementNode ~= currentStatementNode 
				 and: [ self currentEsn isUnwinding = false ]) ifTrue: [ "the debugger is in a statement"
				| ens |
				ens := self currentEsn.
				"To detect the next step for the stepOver, we just analize the length of the ens path"
				shouldStop := (ens size <= startingStatementEns size)
				].
			shouldStop ] ]
]

{ #category : #actions }
MaxWDebugger >> stepUntilConditionIsTrue: aBlock [

	"The recording mechanics is included here.. may not the best place"
	self stDebugger removeSessionHolderSubscriptions.
	aBlock whileFalse: [ 
		| conditionValue |
		conditionValue := aBlock value.
		conditionValue ifFalse: [ 
			self sindarinDebugger stepIt.
			self recordStep ].

		conditionValue ].
	self stDebugger setSessionHolderSubscriptions.
	self stDebugger forceSessionUpdate
]

{ #category : #actions }
MaxWDebugger >> stepUntilEsn: anEsn [
"The recording mechanics is included here.. may not the best place"
self stepUntilConditionIsTrue:  [EsnCreator esn: self currentEsn isEqualTo: anEsn ]
"sindarinDebugger stepUntil: [ 
	|targetReached|
		targetReached:=EsnCreator esn: self currentEsn isEqualTo: anEsn .
		self recordStep.
		targetReached
	 ]"
]

{ #category : #'as yet unclassified' }
MaxWDebugger >> updateExternalHtmlView [
self enableHtmlUpdate ifTrue:[ExecutionRecordViewerComponent displayedHtml: self createHtml].
ExecutionRecordViewerComponent currentDebugger: self.

]

{ #category : #'as yet unclassified' }
MaxWDebugger >> whatWasTheValueOf: aSymbol beforeBeing: anObjectWithAfterValue [

	| assignmentEnsIndex searchIndex |
	searchIndex := executionRecord size.
	[ searchIndex > 0 ] whileTrue: [ 
		assignmentEnsIndex := self 
			                      findLastAssigmentEnsIndexBeforeInclusiveIndex:
			                      searchIndex.
		assignmentEnsIndex > 0 ifTrue: [ 
			| assignmentEns |
			assignmentEns := executionRecord at: assignmentEnsIndex.
			(assignmentEns variableName = aSymbol) ifTrue: [ "found the node with the variable. Need to rescue old and new Val"
				| oldValue newValue |
				oldValue := assignmentEns oldValue.
				newValue := assignmentEns newValue.
				(anObjectWithAfterValue = newValue) ifTrue: [ "found the node where the change happened. just return the old value"
					^oldValue
				] ] ].
		searchIndex := assignmentEnsIndex - 1 ].
	^ ('There was no change registered for: ',aSymbol asString)
]
