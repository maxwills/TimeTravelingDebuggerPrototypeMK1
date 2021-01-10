Class {
	#name : #Dog,
	#superclass : #Object,
	#instVars : [
		'dogName',
		'age',
		'isHappy'
	],
	#classInstVars : [
		'allDogs'
	],
	#category : #'MaxW-Models'
}

{ #category : #adding }
Dog class >> addDog: aDog [
self class allDogs add: aDog
]

{ #category : #'as yet unclassified' }
Dog class >> allDogs [
	^ allDogs ifNil: [ allDogs := OrderedCollection  new ]
]

{ #category : #testing }
Dog class >> isAppropriateName: aSymbol forAge: aNumber [

	aNumber = 0 ifTrue: [ ^ true ].
	aNumber <= 1 ifTrue: [ ^ aSymbol ~= #Fluffy ].
	aNumber <= 2 ifTrue: [ 
		^ aSymbol ~= #Fluffy and: [ aSymbol ~= #CoolDog ] ].
	aNumber <= 3 ifTrue: [ 
		^ (aSymbol ~= #Fluffy and: [ aSymbol ~= #CoolDog ]) and: [ 
			  aSymbol ~= #MightyDog ] ].
	^ true
]

{ #category : #accessing }
Dog >> age [
	^ age
]

{ #category : #accessing }
Dog >> age: anObject [
	age := anObject
]

{ #category : #'as yet unclassified' }
Dog >> doBigDogStuff [
"He doesn't like your names :( "
	self secretlyRenamesHimselfBecauseHeThinksHeIsAJokeToYou
]

{ #category : #'as yet unclassified' }
Dog >> doPuppyStuff [
	^nil
]

{ #category : #'as yet unclassified' }
Dog >> dogName [
^dogName
]

{ #category : #'as yet unclassified' }
Dog >> dogName: aSymbol [
dogName:= aSymbol
]

{ #category : #'as yet unclassified' }
Dog >> getsOlder [
	age := age + 2
]

{ #category : #initialization }
Dog >> initialize [ 
	dogName:= #namelessPuppy.
	age :=0
]

{ #category : #accessing }
Dog >> isHappy [
	^ isHappy
]

{ #category : #accessing }
Dog >> isHappy: anObject [
	isHappy := anObject
]

{ #category : #'as yet unclassified' }
Dog >> makeHimOlderByOneYear [
age:= age +1.
self	updateHappyness.
]

{ #category : #'as yet unclassified' }
Dog >> secretelyRenameYourself [
	self dogName: #Woof
]

{ #category : #'as yet unclassified' }
Dog >> secretlyRenamesHimselfBecauseHeThinksHeIsAJokeToYou [
	self dogName: #Woof
]

{ #category : #'as yet unclassified' }
Dog >> updateHappyness [
	self isHappy:( self class isAppropriateName: self dogName forAge: self age)
]
