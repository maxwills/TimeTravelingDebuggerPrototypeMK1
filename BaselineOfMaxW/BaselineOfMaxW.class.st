Class {
	#name : #BaselineOfMaxW,
	#superclass : #BaselineOf,
	#category : #BaselineOfMaxW
}

{ #category : #baselines }
BaselineOfMaxW >> baseline: spec [

	<baseline>
	spec for: #common do: [ 
		spec
			baseline: 'XMLWriter'
			with: [ 
			spec repository: 'github://pharo-contributions/XML-XMLWriter' ].

		spec
			package: 'MaxW-Base' 
			with: [ spec requires: #( 'XMLWriter') ];
			package: 'MaxW-Base-Tests' with: [ spec requires: #( 'MaxW-Base') ];
			package: 'MaxW-Debugger' with: [ spec requires: #( 'MaxW-Base') ];
			package: 'MaxW-Model' with: [ spec requires: #( 'MaxW-Base') ];
			package: 'MaxW-UI' with: [ spec requires: #( 'MaxW-Base') ];
			group: 'default' with: #( 'MaxW-Base'  MaxW-Base-Tests
				   'MaxW-Debugger' 'MaxW-Model' 'MaxW-UI') ].
]
