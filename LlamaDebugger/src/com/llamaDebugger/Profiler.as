package com.llamaDebugger
{
   import com.fireflyLib.utils.sprintf;
   
   import flash.utils.getTimer;

   /**
    * Simple, static hierarchical block profiler.
    *
    * Currently it is hardwired to start measuring when you press P, and dump
    * results to the log when you let go of P. Eventually something more
    * intelligent will be appropriate.
    *
    * Use it by calling Profiler.enter("CodeSectionName"); before the code you
    * wish to measure, and Profiler.exit("CodeSectionName"); afterwards. Note
    * that Enter/Exit calls must be matched - and if there are any branches, like
    * an early return; statement, you will need to add a call to Profiler.exit()
    * before the return.
    *
    * Min/Max/Average times are reported in milliseconds, while total and non-sub
    * times (times including children and excluding children respectively) are
    * reported in percentages of total observed time.
    */
	public class Profiler
    {
		public static var enabled:Boolean = false;
		public static var nameFieldWidth:int = 50;
		public static var indentAmount:int = 3;
  
	  /**
	   * Because we have to keep the stack balanced, we can only enabled/disable
	   * when we return to the root node. So we keep an internal flag.
	   */
		private static var mReallyEnabled:Boolean = true;
		private static var mWantReport:Boolean = false;
		private static var mWantWipe:Boolean = false;
		private static var mStackDepth:int = 0;
		  
		private static var mRootNode:ProfileInfo;
		private static var mCurrentNode:ProfileInfo;

      /**
       * Indicate we are entering a named execution block.
       */
      	public static function enter(blockName:String):void
      	{
			if(!mCurrentNode)
         	{
	            mRootNode = new ProfileInfo("Root")
	            mCurrentNode = mRootNode;
         	}
         
         	// If we're at the root then we can update our internal enabled state.
         	if(mStackDepth == 0)
         	{
            // Hack - if they press, then release insert, start/stop and dump
            // the profiler.
//            if(PBE.isKeyDown(InputKey.P))
//            {
//               if(!enabled)
//               {
//                  _wantWipe = true;
//                  enabled = true;
//               }
//            }
//            else
//            {
				if(enabled)
                {
					mWantReport = true;
                  	enabled = false;
               	}
//            }
            
				mReallyEnabled = enabled;
            
            	if(mWantWipe) doWipe();
            	if(mWantReport) doReport();
			}
         
         	// Update stack depth and early out.
         	mStackDepth++;
         	if(!mReallyEnabled) return;
            
         	// Look for child; create if absent.
         	var newNode:ProfileInfo = mCurrentNode.children[blockName];
         	if(!newNode)
         	{
            	newNode = new ProfileInfo(blockName, mCurrentNode);
            	mCurrentNode.children[blockName] = newNode;
         	}
         
	        // Push onto stack.
			mCurrentNode = newNode;
	         
	        // Start timing the child node. Too bad you can't QPC from Flash. ;)
			mCurrentNode.startTime = flash.utils.getTimer();
		}
      
      	/**
       	* Indicate we are exiting a named exection block.
       	*/
		public static function exit(blockName:String):void
      	{
			// Update stack depth and early out.
 			mStackDepth--;
 			if(!mReallyEnabled) return;
 
 			if(blockName != mCurrentNode.name)
				throw new Error("Mismatched Profiler.enter/Profiler.exit calls, got '" + 
					mCurrentNode.name + "' but was expecting '" + blockName + "'");
 
			// Update stats for this node.
			var elapsedTime:int = flash.utils.getTimer() - mCurrentNode.startTime;
			mCurrentNode.activations++;
			mCurrentNode.totalTime += elapsedTime;
			if(elapsedTime > mCurrentNode.maxTime) mCurrentNode.maxTime = elapsedTime;
			if(elapsedTime < mCurrentNode.minTime) mCurrentNode.minTime = elapsedTime;
			
			// Pop the stack.
			mCurrentNode = mCurrentNode.parent;
		}
      
      	/**
       	* Dumps statistics to the log next time we reach bottom of stack.
       	*/
		public static function report():void
		{
			if(mStackDepth)
         	{
            	mWantReport = true;
            	return;
         	}
         
         	doReport();
      	}
      
      	/**
       	* Reset all statistics to zero.
       	*/
		public static function wipe():void
      	{
         	if(mStackDepth)
         	{
            	mWantWipe = true;
            	return;
			}

         	doWipe();
      	}

	  	/**
	   	* Call this outside of all Enter/Exit calls to make sure that things
	   	* have not gotten unbalanced. If all enter'ed blocks haven't been
	   	* exit'ed when this function has been called, it will give an error.
	   	*
	   	* Useful for ensuring that profiler statements aren't mismatched.
	   	*/
      	public static function ensureAtRoot():void
      	{
         	if(mStackDepth)
            	throw new Error("Not at root!");
      	}
      
      	private static function doReport():void
      	{
         	mWantReport = false;
         
         	var header:String = sprintf( "%-" + nameFieldWidth + "s%-8s%-8s%-8s%-8s%-8s%-8s", "name", "Calls", "Total%", "NonSub%", "AvgMs", "MinMs", "MaxMs" );
         	Logger.trace(header);
			
         	report_R(mRootNode, 0);
      	}
      
		private static function report_R(pi:ProfileInfo, indent:int):void
      	{
         	// Figure our display values.
         	var selfTime:Number = pi.totalTime;

         	var hasKids:Boolean = false;
         	var totalTime:Number = 0;
         	for each(var childPi:ProfileInfo in pi.children)
         	{
            	hasKids = true;
            	selfTime -= childPi.totalTime;
            	totalTime += childPi.totalTime;
         	}
         
         	// Fake it if we're root.
         	if(pi.name == "Root")
            	pi.totalTime = totalTime;
         
         	var displayTime:Number = -1;
         	if(pi.parent)
            	displayTime = Number(pi.totalTime) / Number(mRootNode.totalTime) * 100;
            
         	var displayNonSubTime:Number = -1;
         	if(pi.parent)
            	displayNonSubTime = selfTime / Number(mRootNode.totalTime) * 100;
         
         	// Print us.
         	var entry:String = null;
         	if(indent == 0)
         	{
             	entry = "+Root";
         	}
         	else
         	{
             	entry = sprintf( "%-" + (indent * indentAmount) + "s%-" + (nameFieldWidth - indent * indentAmount) + "s%-8s%-8s%-8s%-8s%-8s%-8s", "",
                 	(hasKids ? "+" : "-") + pi.name, pi.activations, displayTime.toFixed(2), displayNonSubTime.toFixed(2), (Number(pi.totalTime) / Number(pi.activations)).toFixed(1), pi.minTime, pi.maxTime);             
         	}
         	
			Logger.trace(entry, null, "Profiler");
         
         	// Sort and draw our kids.
         	var tmpArray:Array = new Array();
         	for each(childPi in pi.children)
            	tmpArray.push(childPi);
         	
			tmpArray.sortOn("totalTime", Array.NUMERIC | Array.DESCENDING);
         	
			for each(childPi in tmpArray)
			{
            	report_R(childPi, indent + 1);
			}
		}

		private static function doWipe(pi:ProfileInfo = null):void
      	{
         	mWantWipe = false;
         
			if(!pi)
         	{
            	doWipe(mRootNode);
            	return;
         	}
         
         	pi.wipe();
			
         	for each(var childPi:ProfileInfo in pi.children)
			{
            	doWipe(childPi);
			}
		}
	}
}

final class ProfileInfo
{
	public var name:String;
   	public var children:Object = {};
   	public var parent:ProfileInfo;
   
   	public var startTime:int, totalTime:int, activations:int;
   	public var maxTime:int = int.MIN_VALUE;
   	public var minTime:int = int.MAX_VALUE;
   
   	public function ProfileInfo(n:String, p:ProfileInfo = null)
   	{
      	name = n;
      	parent = p;
   	}
   
   	public function wipe():void
   	{
		startTime = totalTime = activations = 0;
      	maxTime = int.MIN_VALUE;
      	minTime = int.MAX_VALUE;
   	}
}