Class {
	#name : #EnsRepresentationNode,
	#superclass : #Object,
	#instVars : [
		'ens',
		'ensToken',
		'ensTokenAsString',
		'children',
		'node',
		'extraNotes'
	],
	#category : #'MaxW-Base'
}

{ #category : #'as yet unclassified' }
EnsRepresentationNode >> childWithEnsToken: anEnsToken [
	|index|
	index:= self indexOfChildEnsToken: anEnsToken.
	index>0 ifTrue: [ ^children at:index ].
	^nil
]

{ #category : #accessing }
EnsRepresentationNode >> children [
	^ children
]

{ #category : #accessing }
EnsRepresentationNode >> children: anObject [
	children := anObject
]

{ #category : #'as yet unclassified' }
EnsRepresentationNode >> containsChildEnsToken: anEnsToken [
^ (self indexOfChildEnsToken: anEnsToken) >0
]

{ #category : #accessing }
EnsRepresentationNode >> ens [
	^ ens
]

{ #category : #accessing }
EnsRepresentationNode >> ens: anObject [
	ens := anObject
]

{ #category : #accessing }
EnsRepresentationNode >> ensToken [
	^ ensToken
]

{ #category : #accessing }
EnsRepresentationNode >> ensToken: anObject [
	ensToken := anObject
]

{ #category : #accessing }
EnsRepresentationNode >> ensTokenAsString [
	^ ensTokenAsString
]

{ #category : #accessing }
EnsRepresentationNode >> ensTokenAsString: anObject [
	ensTokenAsString := anObject
]

{ #category : #accessing }
EnsRepresentationNode >> extraNotes [
	^ extraNotes
]

{ #category : #accessing }
EnsRepresentationNode >> extraNotes: anObject [
	extraNotes := anObject
]

{ #category : #'as yet unclassified' }
EnsRepresentationNode >> indexOfChildEnsToken: anEnsToken [
self isLeaf ifTrue: [ ^0 ].
1 to: children size do: [ :i|
	((children at:i) ensToken isEqualTo: anEnsToken) ifTrue: [ ^i ]
	 ].
^0
]

{ #category : #initialization }
EnsRepresentationNode >> initialize [ 
	children:= OrderedCollection new.
	extraNotes :=''
]

{ #category : #testing }
EnsRepresentationNode >> isLeaf [
	 ^ (children isNil) or: (children isEmpty)
]

{ #category : #accessing }
EnsRepresentationNode >> node [
	^ node
]

{ #category : #accessing }
EnsRepresentationNode >> node: anObject [
	node := anObject
]
