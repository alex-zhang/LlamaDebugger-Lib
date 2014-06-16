package com.llamaDebugger
{
   /**
    * Log entries are automatically created by the various methods on the Logger
    * class to store information related to an entry in the log. They are also
    * dispatched in the LogEvent when the entry is added to the log to pass
    * information about the entry to the listener.
    * 
    * @see Logger
    */
	public final class LogEntry
   	{
		private static var mLogEntriesPool:Vector.<LogEntry> = new Vector.<LogEntry>();

		public static function create(logType:LogType, message:String):LogEntry
		{
			var logEntry:LogEntry;
			
			if(mLogEntriesPool.length > 0)
			{
				logEntry = mLogEntriesPool.pop();
			}
			else
			{
				logEntry = new LogEntry();
			}
			
			logEntry.logType = logType;
			logEntry.message = message;
			
			return logEntry;
		}
		
		public static function recycle(logEntry:LogEntry):void
		{
			mLogEntriesPool.push(logEntry);
		}
		
		
	   /**
		* The type of the message (message, warning, or error).
		* 
		* @see #Logger.ERROR
		* @see #Logger.WARNING
		* @see #Logger.MESSAGE
		*/
		public var logType:LogType;

	  /**
	   * The message that was printed.
	   */
		public var message:String = null;
   }
}