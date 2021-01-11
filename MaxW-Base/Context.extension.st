Extension { #name : #Context }

{ #category : #'*MaxW-Base' }
Context >> currentNode [
	^ self method sourceNodeForPC: self pc
]
