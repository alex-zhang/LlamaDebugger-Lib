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
	public class LogEntry
   	{
	   /**
		* The type of the message (message, warning, or error).
		* 
		* @see #Logger.ERROR
		* @see #Logger.WARNING
		* @see #Logger.MESSAGE
		*/
		public var logType:String;

      /**
       * The message that was printed.
       */
		public var message:String = null;
	  
	  /**
	   * The method the entry was printed from.
	   */
		public var method:String = null;
	  
	  /**
	   * The object that printed the message to the log.
	   */
		public var reporter:String = null;
	  
	  /**
	   * The depth of the message.
	   * 
	   * @see Logger#Push()
	   */
	  public var depth:int = 0;
	  
	  public function LogEntry(logType:String, message:String, method:String = null, reporter:String = null)
	  {
		  this.logType = logType;
		  this.message = message;
		  this.method = method;
		  this.reporter = reporter;
	  }
	  
	  public function formatMessage():String
	  {
		  return (reporter ? reporter + ": " : "") +
			  (method ? method + "- " : "") +
			  (message ? message : "");
	  }
      
      /**
       * The full message, formatted to include the reporter and method if they exist.
       */
      public function formatDeepMessage():String
      {
         var deep:String = "";
         for (var i:int = 0; i < depth; i++)
            deep += "   ";
         
         return deep + formatMessage();
      }
   }
}