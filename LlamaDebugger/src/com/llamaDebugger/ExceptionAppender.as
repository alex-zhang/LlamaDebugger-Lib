package com.llamaDebugger
{
   public class ExceptionAppender implements ILogAppender
   {
	   public function addLogMessage(logEntry:LogEntry):void
	   {
		   if(logEntry.logType != Logger.ERROR) return;
		   
		   throw new Error(logEntry.message);
	   }
   }
}