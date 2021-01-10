Class {
	#name : #DogRenamer,
	#superclass : #Object,
	#category : #'MaxW-Base'
}

{ #category : #'as yet unclassified' }
DogRenamer class >> popANewName [
	^'Pup'
]

{ #category : #'as yet unclassified' }
DogRenamer class >> renameDog: aDogEntry withNewName: aString [
	aDogEntry dogName: aString
]
