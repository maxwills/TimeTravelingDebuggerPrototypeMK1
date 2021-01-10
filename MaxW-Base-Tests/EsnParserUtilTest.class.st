Class {
	#name : #EsnParserUtilTest,
	#superclass : #TestCase,
	#classVars : [
		'esnParser'
	],
	#category : #'MaxW-Base-Tests'
}

{ #category : #initialization }
EsnParserUtilTest >> initialize [
	esnParser := EsnParserUtil new
]

{ #category : #test }
EsnParserUtilTest >> testExtractClassNameFromTokenString [
|testRows|
testRows:={ {'.classname'.'classname'}.
{'*:whatever'.'*'} }.
testRows do: [ :row|
		self assert: (esnParser extractClassNameFromTokenString: (row at:1)) equals: (row at:2)
	 ].
self assert: (esnParser extractClassNameFromTokenString: 'nonValidClass') isNil
]

{ #category : #test }
EsnParserUtilTest >> testExtractMethodFromTokenString [
self assert: (esnParser extractMethodFromTokenString: '[method=methodName1]') equals: 'methodName1'.
self assert: (esnParser extractMethodFromTokenString: '.class[method=methodName2]') equals: 'methodName2'.
self assert: (esnParser extractMethodFromTokenString: '.class') isNil.
self assert: (esnParser extractMethodFromTokenString: ':something') isNil.
self assert: (esnParser extractMethodFromTokenString: '.class[method=methodName3]:nth-child(1)') equals: 'methodName3'.
]

{ #category : #test }
EsnParserUtilTest >> testExtractNthChildFromTokenString [

	self
		assert: (esnParser extractNthChildFromTokenString: ':nth-child(3)')
		equals: 3.
	self
		assert:
		(esnParser extractNthChildFromTokenString: '.class:nth-child(4)')
		equals: 4.
	self
		assert: (esnParser extractNthChildFromTokenString: '*:nth-child(1)')
		equals: 1.
	self assert:
		(esnParser extractNthChildFromTokenString: '*[method=something]')
			isNil
]

{ #category : #accessing }
EsnParserUtilTest >> testIndexOfNonNameAllowedCharacter [

	self
		assert:
		(esnParser indexOfNonNameAllowedCharacter: 'this_should_return:_19')
		equals: 19.
	self
		assert:
		(esnParser indexOfNonNameAllowedCharacter: '.this_should_return:_1')
		equals: 1.
	self
		assert:
		(esnParser indexOfNonNameAllowedCharacter: 'thi(s)_should_return:_4')
		equals: 4.
	self
		assert:
		(esnParser indexOfNonNameAllowedCharacter: 'this_"sho(uld_return:_6')
		equals: 6.
	self
		assert:
		(esnParser indexOfNonNameAllowedCharacter: 'this[_sho(uld_return:_5')
		equals: 5
]

{ #category : #test }
EsnParserUtilTest >> testIndexOfNonNameAllowedCharacterStartingAt [

	self
		assert: (esnParser
				 indexOfNonNameAllowedCharacter: '.[this_should_return:_1'
				 startingAt: 1)
		equals: 1.
	self
		assert: (esnParser
				 indexOfNonNameAllowedCharacter: '.[this_should_return:_2'
				 startingAt: 2)
		equals: 2.
	self
		assert: (esnParser
				 indexOfNonNameAllowedCharacter: '.t]his_should_return:_3'
				 startingAt: 2)
		equals: 3.
	self
		assert: (esnParser
				 indexOfNonNameAllowedCharacter: '.t]his_should_return:_21'
				 startingAt: 4)
		equals: 21
]

{ #category : #tests }
EsnParserUtilTest >> testSepareTokens [

	| tempResult |
	self assert: (esnParser separeTokens: 'gives>2') size equals: 2.
	tempResult := esnParser separeTokens: 'this>gives>3'.
	self assert: (tempResult at: 1) equals: 'this'.
	self assert: (tempResult at: 2) equals: 'gives'.
	self assert: (tempResult at: 3) equals: '3'
]
