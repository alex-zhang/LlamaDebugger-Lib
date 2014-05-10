package com.llamaDebugger
{
    /**
     * Simply dump log activity via trace(). 
     */
    public class TraceAppender implements ILogAppender
    {
        public function addLogMessage(logEntry:LogEntry):void
        {
            trace("[" + logEntry.logType + " " + "]" + ": " + logEntry.formatMessage());
        }
    }
}