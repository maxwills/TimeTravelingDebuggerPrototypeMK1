Class {
	#name : #EsnCreator,
	#superclass : #Object,
	#category : #'MaxW-Base'
}

{ #category : #copying }
EsnCreator class >> copyEsnTokenList: anEsnTokenList [
"A deep copy of the list, abusing parsing/serialization functions"
^ anEsnTokenList ifNil: [ nil ] ifNotNil:  [
	|newEns|
	newEns := self parseFromString: (anEsnTokenList asString).
	newEns esnType: anEsnTokenList esnType.
	newEns isAssignment: anEsnTokenList isAssignment . 
	newEns variableName: anEsnTokenList variableName. 
	newEns oldValue: anEsnTokenList oldValue. 
	newEns newValue: anEsnTokenList newValue. 
	newEns variableInfo: anEsnTokenList variableInfo. 
	newEns node: anEsnTokenList node. 
	newEns context: anEsnTokenList context. 
	newEns isUnwinding: anEsnTokenList isUnwinding. 
	newEns positionInRecord: anEsnTokenList positionInRecord.
	newEns realOriginalValue: anEsnTokenList realOriginalValue.
	newEns
	]
]

{ #category : #'as yet unclassified' }
EsnCreator class >> countNodePosition: anRBNode [

	anRBNode parent ifNil: [ ^ 0 ].
	anRBNode parent class == RBSequenceNode ifTrue: [ 
		| positionInParent |
		positionInParent := self indexOfNode: anRBNode inSequence:  (anRBNode parent).
		^ positionInParent + (self countNodePosition: anRBNode parent)
		].
	^ self countNodePosition: anRBNode parent
]

{ #category : #'as yet unclassified' }
EsnCreator class >> esn: anEsnTokenList isEqualTo: anotherEsnTokenList [

	| str1 str2 |
	str1 := self esnTokenListAsString: anEsnTokenList.
	str2 := self esnTokenListAsString: anotherEsnTokenList.
	^ str1 = str2
]

{ #category : #'as yet unclassified' }
EsnCreator class >> esn: anEsnTokenList isEqualToNotIncludingUnwinding: anotherEsnTokenList [

	| ens1 ens2 str1 str2 |
	(anEsnTokenList isNil and: anotherEsnTokenList isNil) ifTrue: [ ^true ].
	(anEsnTokenList isNil or: anotherEsnTokenList isNil)ifTrue: [ ^false ].
	ens1 := self copyEsnTokenList: anEsnTokenList.
	ens2 := self copyEsnTokenList: anotherEsnTokenList.
	ens1 isUnwinding: false.
	ens2 isUnwinding: false.
	str1 := self esnTokenListAsString: ens1.
	str2 := self esnTokenListAsString: ens2.
	^ str1 = str2
]

{ #category : #'as yet unclassified' }
EsnCreator class >> esnTokenListAsString: aEsnTokenOrderedCollection [

^
aEsnTokenOrderedCollection ifNil:[nil] ifNotNil: [ 
 aEsnTokenOrderedCollection asString
]
]

{ #category : #accessing }
EsnCreator class >> indexOfEsnToken: anEsnToken inList: anOrderedCollectionOfEsnToken [

	anEsnToken isNil ifTrue: [ ^ 0 ].
	anOrderedCollectionOfEsnToken isEmpty ifTrue: [ ^ 0 ].
	1 to: anOrderedCollectionOfEsnToken size do: [ :i | 
		(anEsnToken isEqualTo: (anOrderedCollectionOfEsnToken at: i)) ifTrue: [ ^ i ] ].
	^ 0
]

{ #category : #accessing }
EsnCreator class >> indexOfNode: anRBNode inSequence: aSequenceNode [
	"This is because the indexof fails if the source code of the nodes is the same. I think the prblem is that indexOf compares with hashes, and the hashes are the same for different nodes with the same source"	
	1 to: (aSequenceNode statements size) do: [ :i| 
		(anRBNode == (aSequenceNode statements at: i)) ifTrue: [ ^i]
		].
	^0
]

{ #category : #testing }
EsnCreator class >> isContext: aContext anEnsMatchFor: aEsnString [
	"returns true if the given context is a match for the expression"	
	|esnTokensList|
	esnTokensList := self parseFromString: aEsnString.
	^ true
]

{ #category : #parsing }
EsnCreator class >> parseFromString: aString [
"returns a list of EsnTokens"
	"|esnTokenAsStringOrderedCollection|
	esnTokenAsStringOrderedCollection := aString splitOn: '.'.
	esnTokenAsStringOrderedCollection remove: String empty.
	^ esnTokenAsStringOrderedCollection collect: [:each| EsnToken parseFromString: '.',each ]"
	^Esn parseFromString: aString
]
