package com.llamaDebugger
{
    /**
     * Simply dump log activity via trace(). 
     */
    public class TraceLogAppender implements ILogAppender
    {
        public function addLogMessage(logEntry:LogEntry):void
        {
			if(logEntry.logType !== LogType.CUSTOM_PRINT)
			{
	            trace("[" + logEntry.logType.name + "]" + ": " + logEntry.message);
			}
        }
    }
}