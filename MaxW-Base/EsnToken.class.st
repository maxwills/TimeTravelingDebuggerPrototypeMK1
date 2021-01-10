Class {
	#name : #EsnToken,
	#superclass : #Object,
	#instVars : [
		'objectClassName',
		'method',
		'nthChild',
		'node'
	],
	#category : #'MaxW-Base'
}

{ #category : #parsing }
EsnToken class >> parseFromString: aString [

	| esnParser esnToken |
	esnParser := EsnParserUtil new.
	esnToken := self new.
	esnToken objectClassName:
		(esnParser extractClassNameFromTokenString: aString).
	esnToken method: (esnParser extractMethodFromTokenString: aString).
	esnToken nthChild:
		(esnParser extractNthChildFromTokenString: aString).
	^ esnToken
]

{ #category : #converting }
EsnToken >> asString [

	| classString methodString nthChildString |
	classString := self objectClassName
		               ifNil: [ '' ]
		               ifNotNil: [ '.' , self objectClassName ].
	methodString := self method
		ifNil: [ '' ]
		ifNotNil: [ '[method=' , self method , ']' ].
	nthChildString := self nthChild
		ifNil: [ '' ]
		ifNotNil: [ ':nth-child(' , self nthChild asString, ')' ].
	^ classString , methodString , nthChildString
]

{ #category : #testing }
EsnToken >> isEqualTo: anEsnToken [
	^((self method = anEsnToken method) and:	(self nthChild  = anEsnToken nthChild )) and: 	(self objectClassName  = anEsnToken objectClassName )
]

{ #category : #accessing }
EsnToken >> method [
	^ method
]

{ #category : #accessing }
EsnToken >> method: anObject [
	method := anObject
]

{ #category : #accessing }
EsnToken >> nthChild [
	^ nthChild
]

{ #category : #accessing }
EsnToken >> nthChild: anObject [
	nthChild := anObject
]

{ #category : #accessing }
EsnToken >> objectClassName [
	^ objectClassName
]

{ #category : #accessing }
EsnToken >> objectClassName: anObject [
	objectClassName := anObject
]

{ #category : #printing }
EsnToken >> printString [
	^ self asString
]
