Class {
	#name : #MwSindarinHelper,
	#superclass : #Object,
	#category : #'MaxW-Base'
}

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> doTrueStepInto: aSindarinDebugger [
	aSindarinDebugger signalExceptionIfDebuggedExecutionHasSignalledUnhandledException.
	aSindarinDebugger signalExceptionIfDebuggedExecutionIsFinished.
aSindarinDebugger context step.
"aSindarinDebugger debugSession triggerEvent: #stepInto"
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> getInitialContext: aContext [
	^(aContext sender) ifNil: [aContext] ifNotNil: [self getInitialContext: aContext sender]
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> getPreviousEsn: aSindarinDebugger [
| currentEsn currentEsnToken targetEsn |
	currentEsn := Esn
		              createFromNode: aSindarinDebugger node
		              fromContext: aSindarinDebugger context.
	currentEsnToken := currentEsn last.
	targetEsn := EsnCreator copyEsnTokenList: currentEsn.
	currentEsnToken nthChild <= 1
		ifTrue: [ "should target the previous node in the parent context. ie, remove last esntoken" 
			targetEsn removeLast ]
		ifFalse: [ 
			"should target the previous node in same context (just decrease nthChild)"
			(targetEsn last) nthChild: (targetEsn last) nthChild - 1 ].
		^targetEsn
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> restartAll: aSindarinDebugger [
	aSindarinDebugger debugSession restart: (self getInitialContext: aSindarinDebugger context)
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> stepBackSindarin: aSindarinDebugger [

	| currentEsn currentEsnToken targetEsn |
	currentEsn := Esn
		              createFromNode: aSindarinDebugger node
		              fromContext: aSindarinDebugger context.
	currentEsnToken := currentEsn last.
	targetEsn := EsnCreator copyEsnTokenList: currentEsn.
	currentEsnToken nthChild <= 1
		ifTrue: [ "should target the previous node in the parent context. ie, remove last esntoken" 
			targetEsn removeLast ]
		ifFalse: [ 
			"should target the previous node in same context (just decrease nthChild)"
			(targetEsn last) nthChild: (targetEsn last) nthChild - 1 ].
	self
		stepBackSindarin: aSindarinDebugger
		toEsn: (EsnCreator esnTokenListAsString: targetEsn)
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> stepBackSindarin: aSindarinDebugger toEsn: aString [
self restartAll: aSindarinDebugger.
self stepSindarin: aSindarinDebugger untilEsn: aString
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> stepContext: aProcess [
"Copied from stepToSendOrReturn. Also stepToFirstInterestingBytecodeIn: uses internally the same method"
^Processor activeProcess
		evaluate: [aProcess suspendedContext: aProcess suspendedContext stepToSendOrReturn]
		onBehalfOf: aProcess
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> stepInto: aContext inDebugSession: aDebugSession [

	"Send the selected message in selectedContext, and take control in 
	the method invoked to allow further step or send."

	(aDebugSession isContextPostMortem: aContext) ifTrue: [ ^ self ].

	aDebugSession interruptedProcess step: aContext.
	"Next line needs to be changed"
	"	aDebugSession updateContextTo: (aDebugSession stepToFirstInterestingBytecodeIn: aDebugSession interruptedProcess)."
	aDebugSession updateContextTo:
		(self stepContext: aDebugSession interruptedProcess).
	aDebugSession triggerEvent: #stepInto
]

{ #category : #'as yet unclassified' }
MwSindarinHelper class >> stepSindarin: aSindarinDebugger untilEsn: aString [

aSindarinDebugger stepUntil: [ 
	|currentEsnString|
	currentEsnString := EsnCreator esnTokenListAsString: (Esn createFromNode: aSindarinDebugger node fromContext: aSindarinDebugger context).
	currentEsnString = aString
	 ]
]
