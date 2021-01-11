# TimeTravelingDebuggerPrototypeMK1 - README

## What is this
This is a prototype for a "light-weight-traced-based" time-traveling debugger. It provides basic step forward and step backward functionalities for certain deterministic code scenarios. It also provides a visualization tool.

## Installation, step by step
1. Create an empty Pharo 9, 64 bits image.  
   Installed thorugh Pharo Launcher in 2021/01/11.  
   Latest image at the date of writing: [Pharo 9.0 (80)](http://files.pharo.org/image/80/latest-64.zip).  
   Ensure that the **image path**, including it's name is the **shortest** posible. (I had troubles with long paths and seaside3 baseline)
2. Install the prototype baseline. For that, run this code:
```smalltalk
Metacello new
 baseline:'MaxW';
 repository: 'github://maxwills/TimeTravelingDebuggerPrototypeMK1:main/repository';
 load
```

 3. Enable All Debugger Extensions (Might work with less, but not tested). Go to Pharo menu > Settings > Tools > Debugging > Debugging Extensions, and enable them all.  The MaxDebugger extension should appear if the previous step was successful.
 
 4. Register the Visualization tool in Seaside. 
 Run the following code:
 ```smalltalk
 WAAdmin register: ExecutionRecordViewerComponent asApplicationAt: 'ExecutionRecordViewerComponent'.
 ```
 
 5. Debug some code and open the visualization tool.  
    Quick start: Open a playground with the following Code: dog:=Dog new. and debug it. The new MaxWDebugger extension should be functional.
 To open the visualization tool, open a web browser in your host OS, and go to http://localhost:8080/ExecutionRecordViewerComponent
 For more details on utilization, see the next section.
 
 The code used in the demonstration is at the bottom of this file.
 
## How to use the debugger?

1. Debug the code in the playground. (Select it all, and right click in debug it, or use your code. It should work as long as it complies the [limitations](#limitations))
2. In the MaxWDebugger extension of the debugger, press "Restart All" to properly begin a time-traveling debugging session.
3. Use the extensions stepping tools to advance or reverse execution.
4. To see the visualization, Open a browser in your host OS and open the following url:
[http://localhost:8080/ExecutionRecordViewerComponent?autoRefresh=true&myCodeOnly=false#end](http://localhost:8080/ExecutionRecordViewerComponent?autoRefresh=true&myCodeOnly=false#end)


Note the url parameters:  
* autoRefresh=true makes the page refresh each 500ms automatically.
* myCodeOnly=true will "filter" eveything out of the DoIt method.
* assignmentsOnly=true Use this to "filter" and collapse everything that is not an assignment statement.  
**Choose only myCodeOnly=true or assignmentsOnly=true** (ie, only one filter at a time). Using both filter is not supported.

## Limitations.

* Deterministic executions only.
* Global changes not supported.
* No support for blocks (and loops in general). The recording mechanisms (specifically the identifier generation) was not developed enough to support this. Having said this, it might work in the prototype by mere coincidence.
* Remember that this extension re-executes all in the Spec debugger stack. If there is something that should not be re-executed (think of UI related events or whatever) the tool will not work. This is why for the moment we only start from the Playground and manually debug the code.


## Disclaimer

The code is garbage. It's purpose was to prove the the theory of reversing the execution this way works. This code will be discarded, and the current objective is to have a solid code base. This will happen in another project.

## Example used in demonstration.
```smalltalk
|yourDog|
yourDog := Dog new.

DogRenamer renameDog: yourDog withNewName: #Fluffy . 
Object assert: yourDog dogName = #Fluffy.

yourDog doPuppyStuff.
yourDog getsOlder.

DogRenamer renameDog: yourDog withNewName: #MightyDog .
Object assert: yourDog dogName = #MightyDog.

yourDog doBigDogStuff.
yourDog getsOlder.

Object assert: yourDog dogName = #MightyDog.
```
