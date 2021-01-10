Class {
	#name : #StMaxWDebuggerPresenter,
	#superclass : #SpPresenter,
	#traits : 'TStDebuggerExtension',
	#classTraits : 'TStDebuggerExtension classTrait',
	#instVars : [
		'code',
		'toolbar',
		'stDebugger',
		'stackTable',
		'stackHeader',
		'maxWDebugger'
	],
	#category : #'MaxW-Debugger'
}

{ #category : #'debugger extension' }
StMaxWDebuggerPresenter class >> defaultDisplayOrder [

	^ 4
]

{ #category : #specs }
StMaxWDebuggerPresenter class >> defaultSpec [

	^ SpBoxLayout newVertical
			add: 'Statement Steppping' expand: false fill: false padding: 5;
		  add: #toolbar expand: false fill: false padding: 0;
		  add: #code expand: true;
		"add: #stackHeader;
		add: #stackTable;"
		  yourself
]

{ #category : #'debugger extension' }
StMaxWDebuggerPresenter >> debuggerExtensionToolName [
	^ 'MaxWDebugger' 
]

{ #category : #'as yet unclassified' }
StMaxWDebuggerPresenter >> exampleCode [

	^ '"Examples"', String cr,'mwdbg stepIntoStatement.' , String cr , 'mwdbg stepBackStatement.',
	String cr , 'mwdbg stepForwardToWhenStatementSourceCodeIs: ''yourDog doBigDogStuff''.', String cr, 'mwdbg goBackToLastStatementWhenVariable: #dogName valueChangedTo: #Woof.'
]

{ #category : #initialization }
StMaxWDebuggerPresenter >> initializePresenters [
	code := self newCode.
	"Transcript open;
	show: stDebugger interactionModel asString."
	"klocal := stDebugger interactionModel."
	"maxWDebugger recordStep."
	maxWDebugger initialEsn: maxWDebugger currentEsn.
	code interactionModel: StSindarinContextInteractionModel  new.
	code syntaxHighlight: true.
	code text: self exampleCode.
	toolbar := self newToolbar
		           addItem: (self newToolbarButton
				            label: 'Into';
				            icon: (self application iconNamed: #glamorousInto);
				            action: [maxWDebugger stepIntoStatement. "self printExecutionRecord" ];
				            yourself);
				addItem: (self newToolbarButton
				            label: 'Over';
				            icon: (self application iconNamed: #glamorousOver);
				            action: [maxWDebugger stepOverStatement. "self printExecutionRecord" ];
				            yourself);
		           addItem: (self newToolbarButton
				            label: 'BackInto';
				            icon: (self application iconNamed: #glamorousUndo);
				            action: [maxWDebugger stepBackStatement. "self printExecutionRecord" ];
				            yourself);
				addItem: (self newToolbarButton
				            label: 'BackOver';
				            icon: (self application iconNamed: #back);
				            action: [maxWDebugger stepBackOverStatement. "self printExecutionRecord" ];
				            yourself);
				addItem: (self newToolbarButton
				            label: 'RestartAll';
				            icon: (self application iconNamed: #glamorousRestart);
				            action: [maxWDebugger restartAll. "self printExecutionRecord "];
				            yourself);
		           yourself .
		stackTable := self newTable.
	stackTable
		addColumn: ((SpImageTableColumn
				  title: ''
				  evaluated: [ :context |" self stackIconForContext: context" ])
				 width: 8;
				 sortFunction: nil;
				 yourself);
		addColumn: ((SpStringTableColumn
				  title: 'Class'
				  evaluated: [ :item | "self printReceiverClassInContext: item" ])
				 sortFunction: nil;
				 yourself);
		addColumn:
			((SpStringTableColumn title: 'Method' evaluated: [ :item | 
					  | method |
					  method := item method.
					  method isCompiledBlock
						  ifTrue: [ method sourceNode sourceCode ]
						  ifFalse: [ method selector ] ])
				 sortFunction: nil;
				 yourself).
	stackTable transmitDo: [ :context | 
		stackTable selection isEmpty ifFalse: [ 
			"self updateInspectorFromContext: context.
			self updateCodeFromContext: context.
			self expandStackIfLastItemIsSelected.
			self updateWindowTitle" ] ].
	stackHeader := self instantiate: StHeaderBar.
	stackHeader label: 'Stack'
]

{ #category : #accessing }
StMaxWDebuggerPresenter >> maxWDebugger [
^maxWDebugger 
]

{ #category : #printing }
StMaxWDebuggerPresenter >> printExecutionRecord [

	Transcript clear.
	maxWDebugger printExecutionRecord
]

{ #category : #'accessing model' }
StMaxWDebuggerPresenter >> setModelBeforeInitialization: aStDebugger [

	"My original model is the debugger presenter that I extend"

	"This is is were the plugin framework gives us the StDebugger to make the connection"
	stDebugger := aStDebugger.
	maxWDebugger := MaxWDebugger new.
	maxWDebugger stDebugger: aStDebugger .
	maxWDebugger sindarinDebugger: (stDebugger sindarinDebugger) 
]

{ #category : #initialization }
StMaxWDebuggerPresenter >> updatePresenter [

	"When the StDebugger does something, it call all the updatePresenter for all plugins"

	"for the moment, we will just copy the content of the main code presenter"

	"NOte: not my code for the moment, jsut a copy of Sindarin scripting"

	code interactionModel context: stDebugger currentContext.
	code interactionModel bindings
		at: #mwdbg
		put: (WorkspaceVariable key: #mwdbg value: self maxWDebugger). "Whis means that inside the code, the variaable sindarin will be bound to this object "
	self updateStackFromSession: stDebugger session.
	super updatePresenter.
]

{ #category : #stack }
StMaxWDebuggerPresenter >> updateStackFromSession: aSession [
	|stack|
	stack := aSession stack.
	stackTable items: stack.
]
