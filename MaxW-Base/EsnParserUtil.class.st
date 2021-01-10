Class {
	#name : #EsnParserUtil,
	#superclass : #Object,
	#category : #'MaxW-Base'
}

{ #category : #'as yet unclassified' }
EsnParserUtil >> extractClassNameFromTokenString: aString [
	| firstCharacter |
	firstCharacter := aString at: 1.
	(firstCharacter == $*) ifTrue: [ ^ '*' ].
	(firstCharacter == $.) ifTrue: [ 
		|firstNonNameCharacterIndex|
		firstNonNameCharacterIndex := self indexOfNonNameAllowedCharacter: aString startingAt: 2.
		(firstNonNameCharacterIndex==0) ifTrue: [firstNonNameCharacterIndex :=aString size + 1].
		^aString copyFrom: 2 to: firstNonNameCharacterIndex -1
		 ].
	^nil
]

{ #category : #'as yet unclassified' }
EsnParserUtil >> extractMethodFromTokenString: aString [

	(aString includesSubstring: '[method') ifTrue: [ 
		| openingBracketIndex closingBraketIndex ensMethod |
		openingBracketIndex := aString indexOf: $[.
		closingBraketIndex := aString indexOf: $].
		ensMethod := aString
			             copyFrom: openingBracketIndex + 8
			             to: closingBraketIndex - 1.
		^ ensMethod ].
	^ nil
]

{ #category : #'as yet unclassified' }
EsnParserUtil >> extractNthChildFromTokenString: aString [

	(aString includesSubstring: ':nth-child(') ifTrue: [ 
		| openingParentesisIndex closingParentesisIndex nthChild |
		openingParentesisIndex := aString indexOf: $(.
		closingParentesisIndex := aString indexOf: $).
		nthChild := aString
			             copyFrom: openingParentesisIndex + 1
			             to: closingParentesisIndex - 1.
		^ nthChild asNumber].
	^ nil
]

{ #category : #accessing }
EsnParserUtil >> indexOfNonNameAllowedCharacter: aString [
"Returns the index of the first character that has a character notallowed for naming, starting the search at the specified index"
	| nonNameAllowerChacters |
	nonNameAllowerChacters := '.:> "[]()'.
	1 to: aString size do: [ :i | 
		nonNameAllowerChacters do: [ :each | 
			(aString at: i) == each ifTrue: [ ^ i ] ] ].
	^ 0
]

{ #category : #accessing }
EsnParserUtil >> indexOfNonNameAllowedCharacter: aString startingAt: anInteger [

	"Returns the index of the first character that has a character notallowed for naming, starting the search at the specified index"

	| nonNameAllowerChacters |
	nonNameAllowerChacters := '.:> "[]()'.
	anInteger to: aString size do: [ :i | 
		nonNameAllowerChacters do: [ :each | 
			(aString at: i) == each ifTrue: [ ^ i ] ] ].
	^ 0
]

{ #category : #'as yet unclassified' }
EsnParserUtil >> separeTokens: aString [
	^ aString splitOn: $>
]
