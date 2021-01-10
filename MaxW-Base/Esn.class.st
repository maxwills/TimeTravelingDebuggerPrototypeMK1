Class {
	#name : #Esn,
	#superclass : #OrderedCollection,
	#instVars : [
		'esnType',
		'isAssignment',
		'variableName',
		'realOriginalValue',
		'oldValue',
		'newValue',
		'variableInfo',
		'node',
		'context',
		'isUnwinding',
		'positionInRecord',
		'auxIsStatement'
	],
	#category : #'MaxW-Base-Main'
}

{ #category : #'as yet unclassified' }
Esn class >> createFromNode: aRBNode fromContext: aContext [

	"Returns a list of ESNToken with the fullpath"

	| esn |
	"First create the path of EsnTokens"
	esn := self recursivelyCreateFromNode: aRBNode fromContext: aContext.
	"TODO: remove the rcursive method and iclude it here"
	^ esn
]

{ #category : #parsing }
Esn class >> parseFromString: aString [
"returns a list of EsnTokens"
	|esnTokenAsStringOrderedCollection esn|
	esnTokenAsStringOrderedCollection := aString splitOn: '.'.
	esnTokenAsStringOrderedCollection remove: String empty.
	esn := self new.
	(esnTokenAsStringOrderedCollection collect: [:each| EsnToken parseFromString: '.',each ]) do: [ :each| esn add: each ].
esn isUnwinding: (aString includes:'+u').
	^esn
]

{ #category : #'as yet unclassified' }
Esn class >> recursivelyCreateFromNode: aRBNode fromContext: aContext [

	"Returns a list of ESNToken witht the full ESN. This is the notation of each ESNToken.
	 (class, selector) and they convert to the following string '.class[method=selector]'"

	| currentEsnToken nodePosition aTokenList |
	aContext ifNil: [ ^ self new ].
	currentEsnToken := EsnToken new.
	"Need to be aware of blocks. For the moment, we asume there are no blocks"
	"There is always a sequence ascendant (I think), and its parent could be a block. In this case, we could have a fake class !block or something like that and also need to account for the argument(s) i, and include them somehow in the notation"
	"This means, that for counting the position, first I need to know if the relevant sequence is from a block or not. If it is, I create that fake class node and do the recursion starting on the block node and same context. If it is not, just count the position as usual "
	nodePosition := EsnCreator countNodePosition: aRBNode.
	
	currentEsnToken
		objectClassName: aContext receiver class asString;
		method: aContext selector asString;
		nthChild: (nodePosition == 0
				 ifTrue: nil
				 ifFalse: [ nodePosition ]).
	"recursively creates a list"
	aTokenList := aContext sender
		              ifNil: [ self new ]
		              ifNotNil: [ 
			              self
				              createFromNode: aContext sender currentNode
				              fromContext: aContext sender ].
	^ aTokenList
		  add: currentEsnToken;
		  yourself
]

{ #category : #converting }
Esn >> asString [
|str|
str:=
 $> join: (self collect: [ :aEsnToken| aEsnToken asString ]).
self isUnwinding isNotNil and: [self isUnwinding ifTrue: [ str:= str,'+u' ]].
^str

]

{ #category : #accessing }
Esn >> auxIsStatement [
	^ auxIsStatement
]

{ #category : #accessing }
Esn >> auxIsStatement: anObject [
	auxIsStatement := anObject
]

{ #category : #accessing }
Esn >> context [
	^ context
]

{ #category : #accessing }
Esn >> context: anObject [
	context := anObject
]

{ #category : #copying }
Esn >> copyAssignmentFieldsFrom: anEns [
	self isAssignment: anEns isAssignment .
	self variableName: anEns variableName.
	self oldValue: anEns oldValue.
	self newValue: anEns newValue.
]

{ #category : #accessing }
Esn >> esnType [
	^ esnType
]

{ #category : #accessing }
Esn >> esnType: anObject [
	esnType := anObject
]

{ #category : #accessing }
Esn >> isAssignment [
	^ isAssignment
]

{ #category : #accessing }
Esn >> isAssignment: anObject [
	isAssignment := anObject
]

{ #category : #accessing }
Esn >> isUnwinding [
	^ isUnwinding
]

{ #category : #accessing }
Esn >> isUnwinding: anObject [
	isUnwinding := anObject
]

{ #category : #testing }
Esn >> isVariableNode [
	^self node isVariable
]

{ #category : #accessing }
Esn >> newValue [
	^ newValue
]

{ #category : #accessing }
Esn >> newValue: anObject [
	newValue := anObject
]

{ #category : #accessing }
Esn >> node [
	^ node
]

{ #category : #accessing }
Esn >> node: anObject [
	node := anObject
]

{ #category : #accessing }
Esn >> oldValue [
	^ oldValue
]

{ #category : #accessing }
Esn >> oldValue: anObject [
	oldValue := anObject
]

{ #category : #accessing }
Esn >> positionInRecord [
"for the moment this is only used for html generation and it is recalculated each time it is needed. Don't rely on this value!"
	^ positionInRecord
]

{ #category : #accessing }
Esn >> positionInRecord: anObject [
"for the moment this is only used for html generation and it is recalculated each time it is needed. Don't rely on this value!"
	positionInRecord := anObject
]

{ #category : #accessing }
Esn >> realOriginalValue [
	^ realOriginalValue
]

{ #category : #accessing }
Esn >> realOriginalValue: anObject [
	realOriginalValue := anObject
]

{ #category : #'as yet unclassified' }
Esn >> sameTokensAs: anEns from: aNumber to: anotherNumber [
	"Search in both Ens (self, and anEns) comparing all tokens from the index(position) aNumber to anotherNumber included. Returns true if all the tokens within those indices are equals"
	((self size < anotherNumber) or: ( anEns size < anotherNumber ) ) ifTrue: [^false].
	aNumber to: anotherNumber do: [: i| ((self at:i ) isEqualTo: (anEns at:i)) ifFalse: [^false]].
	^true
]

{ #category : #accessing }
Esn >> sourceCode [
self node ifNil:[^self context asString,'*' ].
^self node statementNode ifNil: [ 'no statement found'] ifNotNil: [ self node statementNode sourceCode ]
]

{ #category : #accessing }
Esn >> variableInfo [
	^ variableInfo
]

{ #category : #accessing }
Esn >> variableInfo: anObject [
	variableInfo := anObject
]

{ #category : #accessing }
Esn >> variableName [
	^ variableName
]

{ #category : #accessing }
Esn >> variableName: anObject [
	variableName := anObject
]
