"
A MaxWDebuggerTest is a test class for testing the behavior of MaxWDebugger
"
Class {
	#name : #MaxWDebuggerTest,
	#superclass : #TestCase,
	#category : #'MaxW-Base-Tests'
}

{ #category : #test }
MaxWDebuggerTest >> testIsUnwindingCaseFollowedBy [
|dbg|
	dbg:=MaxWDebugger new.
	"case1"
	self assert: (dbg isUnwindingCase: (EsnCreator parseFromString: '.UndefinedObject[method=DoIt]:nth-child(1)>.DogEntry class[method=new]:nth-child(1)') followedBy: (EsnCreator parseFromString:'.UndefinedObject[method=DoIt]:nth-child(1)')).
	"case2"
	self assert: (dbg isUnwindingCase: (EsnCreator parseFromString: '.UndefinedObject[method=DoIt]:nth-child(1)>.DogEntry class[method=new]:nth-child(1)') followedBy: (EsnCreator parseFromString:'.UndefinedObject[method=DoIt]:nth-child(1)>.DogEntry class[method=new]')).
	self assert: (dbg isUnwindingCase: (EsnCreator parseFromString: '.DogEntry class[method=new]:nth-child(1)') followedBy: (EsnCreator parseFromString:'.DogEntry class[method=new]')).
	"non unwinding cases"
		self deny: (dbg isUnwindingCase: (EsnCreator parseFromString: '.DogEntry class[method=new]:nth-child(1)') followedBy: (EsnCreator parseFromString:'.DogEntry class[method=new]:nth-child(2)')).
		self deny: (dbg isUnwindingCase: (EsnCreator parseFromString: '.DogEntry class[method=new]:nth-child(1)') followedBy: (EsnCreator parseFromString:'.DogEntry class[method=new]:nth-child(2).Other')).
		"other case"
	self assert: (dbg isUnwindingCase: (EsnCreator parseFromString: '.FullBlockClosure[method=newProcess]:nth-child(2)>.SpCodeDebugItCommand[method=debug:receiver:in:]:nth-child(1)>.CompiledMethod[method=valueWithReceiver:arguments:]:nth-child(1)>.UndefinedObject[method=DoIt]:nth-child(4)>.DogEntry class[method=new]:nth-child(1)+u') followedBy: (EsnCreator parseFromString:'.FullBlockClosure[method=newProcess]:nth-child(2)>.SpCodeDebugItCommand[method=debug:receiver:in:]:nth-child(1)>.CompiledMethod[method=valueWithReceiver:arguments:]:nth-child(1)>.UndefinedObject[method=DoIt]:nth-child(4)')).

]
