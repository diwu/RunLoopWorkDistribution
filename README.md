[![Build Status](https://travis-ci.org/diwu/RunLoopWorkDistribution.svg?branch=master)](https://travis-ci.org/diwu/RunLoopWorkDistribution)

![][demo]
## iOS Fast Scrolling with RunLoop Work Distribution

* Go to work when UI thread gets idle. Step aside when UI thread gets busy.
* If deployed properly, it could:
	* Delay heavy tasks on the UI thread as late as possible.
	* Preload heavy tasks as soon as the UI thread enters its idling mode.
	* Allow you to distribute a heavy task as multiple smaller tasks, thus less blocking when UI thread suddenly gets busy again.
* 100% thread safe. Always runs on the UI thread.

## What is A RunLoop?
RunLoop is a `while(YES){...}` loop that lives within your app's UI thread. It handles all kinds of events when your app is busy, while sleeps like a baby when there's nothing to do, until the next event wakes it up.

## Not All RunLoop Passes are Created Equal
A RunLoop repeats itself as individual passes. However, not all passes are created equal. High priority passes take over when your app is tracking finger movements, while low priority passes begin to run when scrolling comes to an end and the metal has spare time to work on low priority tasks such as processing networking data.

Because the high priority passes are often filled with critical time sensitive tasks. We don't want to interfere with that. So here in this project we are only working in those low priority passes. Focusing on a single type of passes also gives us one huge advantage: all tasks we submit to this type of passes are guaranteed to run on a first-in-first-out sequential basis.

## Why not Simply Multi-threading?
Too many times when we are optimizing cell drawing code in our `cellForRow:` method, we find ourselves buried under a bunch of UIKit APIs that are in no way thread safe. Even worse, some of them could easily block the main thread for one or more precious milliseconds. As facebook AsyncDisplayKit teaches us, "Your code usually has less than ten milliseconds to run before it causes a frame drop". Oops.

## Why Distributing the Work Load?
So here we are executing low priority tasks on the UI thread while the UI thread is free and is about to sleep, so why not dumping those tasks all at once. The UI thread is not busy at that specific moment anyway.

Here's why: The next RunLoop pass, be it high or low priority, will never start unless the previous one hits the finishing line. As a result, if we dump too much work into the current low priority pass, and suddenly the high priority pass needs to take over (for example, touch events detected), the high priority pass will have to wait for the low priority task to finish before any touch events could be served. And that's when you notice the glitches.

If instead we slice our one big low priority task into smaller pieces, things would look much much different. Whenever high priority passes need to take over, they won't wait for long because every low priority task is now smaller and will be finished in no time. Hence the "Step aside when UI thread gets busy." 

## Example
Along with the source code there's an contrived example illustrating the technique. In the example there's a heavy task that loads and draws 3 big JPG files into the cell's contentView whenever a new cell goes onto the screen. If we follow the convention and load and draw the images right inside the `cellForRow:` callback, glitches will ensue, since loading and drawing each image takes quite some time even in a simulator. 

So instead of doing it the old way, we slice our big task into 3 smaller ones, each loading and drawing 1 image. Then we submit the 3 tasks into the low priority tasks queue with the help of `DWURunLoopWorkDistribution`. Running the example, we can see that glitches are much less frequent now. Besides, instead of loading and drawing images for every indexPath that comes and goes during scrolling, only certain indexPaths now get to do the work, making the whole scrolling process more efficient.

## Installation

Simply copy and paste `DWURunLoopWorkDistribution.{h,m}` into your project. Or, if you prefer, add the following line into your Podfile.

`pod 'DWURunLoopWorkDistribution'` 

## Usage

You can submit tasks by calling `addTask:withKey:`. In the case of `cellForRow:`, the key will be the `NSIndexPath` instance of that specific cell.

Since cells are regularly reused within a given tableView, be sure to set the `currentIndexPath` property of your cell and check its value against the indexPath captured by the task block to make sure you are not executing a task that should be abandoned. Cannot find the `currentIndexPath` property anywhere in the document? No worry, it's not there because it's not from Apple. It's a dynamic property injected into every UITableViewCell instance during runtime by `DWURunLoopWorkDistribution`.

[demo]: https://raw.githubusercontent.com/diwu/ui-markdown-store/master/DWURunLoopWorkDistribution_demo.gif
