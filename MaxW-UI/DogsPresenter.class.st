Class {
	#name : #DogsPresenter,
	#superclass : #SpPresenter,
	#instVars : [
		'dogsList'
	],
	#category : #'MaxW-UI'
}

{ #category : #specs }
DogsPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical 
		add: #dogsList;
		yourself
]

{ #category : #adding }
DogsPresenter >> addDog [

"Do nothing"
]

{ #category : #initialization }
DogsPresenter >> initializePresenters [
	dogsList := self newTable 
		addColumn: (SpStringTableColumn title: 'Name' evaluated: #name);
		addColumn: (SpStringTableColumn title: 'Birthday' evaluated: #dob);
		addColumn: (SpStringTableColumn title: 'Race' evaluated: #race);
		yourself.
	self updatePresenter 
]

{ #category : #initialization }
DogsPresenter >> initializeWindow: aWindowPresenter [

	aWindowPresenter
		title: 'Mini DogDatabase';
		initialExtent: 600 @ 400;
		toolbar: (self newToolbar
				 addItem: (self newToolbarButton
						  label: 'Add dog';
						  icon: (self application iconNamed: #smallAdd);
						  action: [ self addDog ];
						  yourself);
				 yourself)
]

{ #category : #initialization }
DogsPresenter >> updatePresenter [
	dogsList items: Dog allDogs 
]
