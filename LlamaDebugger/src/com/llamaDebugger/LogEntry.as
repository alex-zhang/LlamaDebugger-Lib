package com.fireflyLib.debug
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
       * The object that printed the message to the log.
       */
      public var reporter:String = null;
      
      /**
       * The message that was printed.
       */
      public var message:String = "";
	  
	  /**
	   * The method the entry was printed from.
	   */
	  public var method:String = "";
	  
	  /**
	   * The type of the message (message, warning, or error).
	   * 
	   * @see #ERROR
	   * @see #WARNING
	   * @see #MESSAGE
	   */
	  public var type:String = null;
	  
	  /**
	   * The depth of the message.
	   * 
	   * @see Logger#Push()
	   */
	  public var depth:int = 0;
      
      /**
       * The full message, formatted to include the reporter and method if they exist.
       */
      public function get formattedMessage():String
      {
         var deep:String = "";
         for (var i:int = 0; i < depth; i++)
            deep += "   ";
         
         var reporter:String = "";
         if (reporter)
            reporter = reporter + ": ";
         
         var method:String = "";
         if (method != null && method != "")
            method = method + " - ";
         
         return deep + reporter + method + message;
      }
   }
}