Extension { #name : #Process }

{ #category : #'*MaxW-Base' }
Process >> stepItToSendOrReturn [
self flag:'mwcode'.
	^Processor activeProcess
		evaluate: [suspendedContext := suspendedContext stepItToSendOrReturn]
		onBehalfOf: self
]
