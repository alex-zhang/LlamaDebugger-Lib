package com.llamaDebugger
{
	import com.fireflyLib.utils.TypeUtility;
	

    /**
     * The Logger class provides mechanisms to print and listen for errors, warnings,
     * and general messages. The built in 'trace' command will output messages to the
     * console, but this allows you to differentiate between different types of
     * messages, give more detailed information about the origin of the message, and
     * listen for log events so they can be displayed in a UI component.
     * 
     * You can use Logger for localized logging by instantiating an instance and
     * referencing it. For instance:
     * 
     * <code>protected static var logger:Logger = new Logger(MyClass);
     * logger.print("Output for MyClass.");</code>
     *  
     * @see LogEntry
     */
    public class Logger
    {
		/**
		 * type given to errors.
		 * 
		 * @see Logger#printError()
		 */
		public static const ERROR:String = "ERROR";
		
		/**
		 * type given to warnings.
		 * 
		 * @see Logger#PrintWarning()
		 */
		public static const WARNING:String = "WARNING";
		
		/**
		 * type given to debug messages.
		 * 
		 * @see Logger#PrintDebug()
		 */
		public static const DEBUG:String = "DEBUG";
		
		/**
		 * type given to warnings.
		 * 
		 * @see Logger#PrintInfo()
		 */
		public static const INFO:String = "INFO";
		
		/**
		 * type given to normal messages.
		 */
		public static const TRACE:String = "TRACE";
		
		/**
		 * type given to sys inner messages.
		 */
		public static const CMD:String = "CMD";

		protected static var listeners:Vector.<ILogAppender> = new Vector.<ILogAppender>();
		protected static var filters:Vector.<ILogFilter> = new Vector.<ILogFilter>();
		//befor start up log record.
        protected static var pendingEntries:Vector.<LogEntry> = new Vector.<LogEntry>();
		
		protected static var started:Boolean = false;
		protected static var disabled:Boolean = false;
        
        /**
         * Register a ILogAppender to be called back whenever log messages occur.
         */
        public static function registerListener(listener:ILogAppender):void
        {
            listeners.push(listener);
        }
		
		public static function registerFilter(filter:ILogFilter):void
		{
			filters.push(filter);
		}
		
		public static function createLogger(reporter:Object):Logger
		{
			return new Logger(TypeUtility.getSimpleClassName(reporter));
		}
        
        /**
         * Initialize the logging system.
         */
        public static function startup(configCallback:Function = null):void
        {
			function defaultConfig():void 
			{
				// Put default listeners into the list.
				registerListener(new TraceAppender());
				registerListener(new UIAppender());
			}
			
			configCallback ||= defaultConfig;
			
			configCallback();
            
            // Process pending messages.
            started = true;
			
			//befor startup there has log yet.
			var n:int = pendingEntries.length;
            for(var i:int = 0; i < n; i++)
			{
                processEntry(pendingEntries[i]);
			}
            
            // Free up the pending entries memory.
            pendingEntries.length = 0;
            pendingEntries = null;
        }
        
        /**
         * Call to destructively disable logging. This is useful when going
         * to production, when you want to remove all logging overhead.
         */
        public static function disable():void
        {
            pendingEntries = null;
            started = false;
            listeners = null;
            disabled = true;
        }
        
        protected static function processEntry(entry:LogEntry):void
        {
            // Early out if we are disabled.
            if(disabled) return;
            
            // If we aren't started yet, just store it up for later processing.
            if(!started)
            {
                pendingEntries.push(entry);
                return;
            }
			
			//filter the log
			var n:int = 0;
			var i:int = 0;
			
			n = filters.length;
			for(i = 0; i < n; i++)
			{
				if(!ILogFilter(filters[i]).test(entry)) return;
			}
			
            // Let all the listeners process it.
			n = listeners.length;
            for(i = 0; i< n; i++)
			{
				ILogAppender(listeners[i]).addLogMessage(entry);
			}
        }
        
		/**
		 * Prints an info message to the log. Log entries created with this method
		 * will have the INFO type.
		 * 
		 * @param reporter The object that reported the warning. This can be null.
		 * @param method The name of the method that the warning was reported from.
		 * @param message The warning to print to the log.
		 */
		public static function info(message:String, method:String = null, reporter:String = null):void
		{
            // Early out if we are disabled.
            if(disabled) return;

			processEntry(new LogEntry(INFO, message, method, reporter));
		}
		
		/**
		 * Prints a debug message to the log. Log entries created with this method
		 * will have the DEBUG type.
		 * 
		 * @param reporter The object that reported the debug message. This can be null.
		 * @param method The name of the method that the debug message was reported from.
		 * @param message The debug message to print to the log.
		 */
		public static function debug(message:String, method:String = null, reporter:String = null):void
		{
            // Early out if we are disabled.
            if(disabled) return;

			processEntry(new LogEntry(DEBUG, message, method, reporter));
		}
		
        /**
         * Prints a warning message to the log. Log entries created with this method
         * will have the WARNING type.
         * 
         * @param reporter The object that reported the warning. This can be null.
         * @param method The name of the method that the warning was reported from.
         * @param message The warning to print to the log.
         */
        public static function warn(message:String, method:String = null, reporter:String = null):void
        {
            // Early out if we are disabled.
            if(disabled) return;

            processEntry(new LogEntry(WARNING, message, method, reporter));
        }
        
        /**
         * Prints an error message to the log. Log entries created with this method
         * will have the ERROR type.
         * 
         * @param reporter The object that reported the error. This can be null.
         * @param method The name of the method that the error was reported from.
         * @param message The error to print to the log.
         */
        public static function error(message:String, method:String = null, reporter:String = null):void
        {
            // Early out if we are disabled.
            if(disabled) return;

			processEntry(new LogEntry(ERROR, message, method, reporter));
        }
		
		/**
		 * Prints a general message to the log. Log entries created with this method
		 * will have the MESSAGE type.
		 * 
		 * @param reporter The object that reported the message. This can be null.
		 * @param message The message to print to the log.
		 */
		public static function print(message:String, method:String = null, reporter:String = null):void
		{
			// Early out if we are disabled.
			if(disabled) return;
			
			processEntry(new LogEntry(TRACE, message, method, reporter));
		}
        
        /**
         * Prints a message to the log. Log enthries created with this method will have
         * the type specified in the 'type' parameter.
         * 
         * @param reporter The object that reported the message. This can be null.
         * @param method The name of the method that the error was reported from.
         * @param message The message to print to the log.
         * @param type The custom type to give the message.
         */
        public static function printCustom(logType:String, message:String, method:String = null, reporter:String = null):void
        {
            // Early out if we are disabled.
            if(disabled) return;
			
			processEntry(new LogEntry(logType, message, method, reporter));
        }
		
        /**
         * Utility function to get the current callstack. Only works in debug build.
         * Useful for noting who called what. Empty when in release build.
         */
        public static function getCallStack():String
        {
            try
            {
                var e:Error = new Error();

                return e.getStackTrace();
            }
            catch(e:Error)
            {
			}
			
            return "[no callstack available]";
        }

        public static function printHeader(report:*, message:String):void
        {
            print(report, message);
        }
        
        public static function printFooter(report:*, message:String):void
        {
            print(report, message);
        }
		
		//----------------

        protected var reporter:String;
        
        public function Logger(reporter:String)
        {
			this.reporter = reporter;
        }
		
		public function info(message:String, method:String = null):void
		{
			Logger.info(message, method, reporter);
		}
		
        public function warn(message:String, method:String = null):void
        {
            Logger.warn(message, method, reporter);
        }
		
		public function debug(message:String, method:String = null):void
		{
			Logger.debug(message, method, reporter);
		}
        
        public function error(message:String, method:String = null):void
        {
            Logger.error(message, method, reporter);
        }

        public function print(message:String, method:String = null):void
        {
            Logger.print(message, method, reporter);
        }
    }
}