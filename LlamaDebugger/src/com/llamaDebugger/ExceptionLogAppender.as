package com.llamaDebugger
{
   public class ExceptionLogAppender implements ILogAppender
   {
	   public function addLogMessage(logEntry:LogEntry):void
	   {
		   if(logEntry.logType != LogType.ERROR) return;
		   
		   throw new Error(logEntry.message);
	   }
   }
}