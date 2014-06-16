package com.llamaDebugger
{
    import flash.external.ExternalInterface;
    
    /**
     * Simple listener to dump log events out to javascript. You might want
     * to customize the name of the function it calls.
     * 
     * Note that this can be an expensive listener to have active. We have
     * observed that it can take as much as 6ms to log one output line. So,
     * you may only want to use this listener when necessary.
     */
    public class JavascriptLogAppender implements ILogAppender
    {
        public function addLogMessage(logEntry:LogEntry):void
        {
			switch(logEntry.logType)
			{
				case LogType.TRACE:
					ExternalInterface.call("console.trace", logEntry.message);
					break;
				
				case LogType.DEBUG:
					ExternalInterface.call("console.debug", logEntry.message);
					break;
				
				case LogType.INFO:
					ExternalInterface.call("console.info", logEntry.message);
					break;
				
				case LogType.WARNING:
					ExternalInterface.call("console.warn", logEntry.message);
					break;
				
				case LogType.ERROR:
					ExternalInterface.call("console.error", logEntry.message);
					break;
			}
        }
    }
}