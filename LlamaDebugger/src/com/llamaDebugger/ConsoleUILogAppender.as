package com.llamaDebugger
{
	import com.fireflyLib.utils.GlobalPropertyBag;
	
	import flash.events.KeyboardEvent;

	/**
	 * LogAppender for displaying log messages in a LogViewer. The LogViewer will be
     * attached and detached from the main view when the defined hot key is pressed. The tilde (~) key 
	 * is the default hot key.
	 */	
	public class ConsoleUILogAppender implements ILogAppender
	{
		protected var mConsoleUI:ConsoleUI;
	   
		public function ConsoleUILogAppender()
		{
			GlobalPropertyBag.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDownHandler);
			
			mConsoleUI = new ConsoleUI();
		}
  
		protected function onKeyDownHandler(event:KeyboardEvent):void
		{
			if(event.keyCode != Console.hotKeyCode) return;
			 
			if(mConsoleUI)
			{
				if(mConsoleUI.parent)
				{
					mConsoleUI.parent.removeChild(mConsoleUI);
					mConsoleUI.deactivate();
				}
				else
				{
					GlobalPropertyBag.stage.addChild(mConsoleUI);
					
					var char:String = String.fromCharCode(event.charCode);
					mConsoleUI.restrict = "^" + char.toUpperCase() + char.toLowerCase();	// disallow hotKey character
					mConsoleUI.activate();
				}
			}
		}
		
		public function addLogMessage(logEntry:LogEntry):void
		{
			mConsoleUI.addLogMessage(logEntry);
		}
	}
}