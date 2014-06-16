package com.llamaDebugger
{
	import com.fireflyLib.utils.StringUtil;

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
		public static var logLevel:int = int.MAX_VALUE;//default
		
		protected static var mLogAppenders:Vector.<ILogAppender> = new Vector.<ILogAppender>();
		protected static var mLogFilters:Vector.<ILogFilter> = new Vector.<ILogFilter>();
		//befor start up log record.
        protected static var mPendingLogEntries:Vector.<LogEntry> = new Vector.<LogEntry>();

		protected static var mStarted:Boolean = false;
		protected static var mDisabled:Boolean = false;
        
		public static function trace(message:String, ...args):void
		{
			if(mDisabled) return;
			if(LogType.TRACE.verbosity > logLevel) return;
			
			//this way is 3 time slower than use unshif directlt. 
			//var argsArr:Array = [message];
			//argsArr.push.apply(null, args);
			
			args.unshift(message);
			processEntry(LogEntry.create(LogType.TRACE, StringUtil.substitute.apply(null, args)));
		}
		
		public static function debug(message:String, ...args):void
		{
			if(mDisabled) return;
			if(LogType.DEBUG.verbosity > logLevel) return;
			
			args.unshift(message);
			processEntry(LogEntry.create(LogType.DEBUG, StringUtil.substitute.apply(null, args)));
		}
		
		public static function info(message:String, ...args):void
		{
			if(mDisabled) return;
			if(LogType.INFO.verbosity > logLevel) return;
			
			args.unshift(message);
			processEntry(LogEntry.create(LogType.INFO, StringUtil.substitute.apply(null, args)));
		}
		
		public static function warn(message:String, ...args):void
		{
			if(mDisabled) return;
			if(LogType.WARNING.verbosity > logLevel) return;
			
			args.unshift(message);
			processEntry(LogEntry.create(LogType.WARNING, StringUtil.substitute.apply(null, args)));
		}
		
		public static function error(message:String, ...args):void
		{
			if(mDisabled) return;
			if(LogType.ERROR.verbosity > logLevel) return;
			
			args.unshift(message);
			processEntry(LogEntry.create(LogType.ERROR, StringUtil.substitute.apply(null, args)));
		}
		
		public static function customPrint(message:String, color:uint = 0xFFFFFF, ...args):void
		{
			if(mDisabled) return;

			LogType.CUSTOM_PRINT.color = color;
			args.unshift(message);
			processEntry(LogEntry.create(LogType.CUSTOM_PRINT, StringUtil.substitute.apply(null, args)));
		}
		
        /**
         * Register a ILogAppender to be called back whenever log messages occur.
         */
        public static function registerLogAppender(listener:ILogAppender):void
        {
            mLogAppenders.push(listener);
        }
		
		public static function registerLogFilter(filter:ILogFilter):void
		{
			mLogFilters.push(filter);
		}
		
        /**
         * Initialize the logging system.
         */
        public static function startup(configCallback:Function = null):void
        {
			if(configCallback == null)
			{
				configCallback = function():void 
				{
					// Put default listeners into the list.
					registerLogAppender(new TraceLogAppender());
					registerLogAppender(new ConsoleUILogAppender());
				};
			}
			
			configCallback();
            
            // Process pending messages.
            mStarted = true;
			
			//befor startup there has log yet.
			var n:int = mPendingLogEntries.length;
            for(var i:int = 0; i < n; i++)
			{
                processEntry(mPendingLogEntries[i]);
			}
            
            // Free up the pending entries memory.
            mPendingLogEntries.length = 0;
            mPendingLogEntries = null;
        }
		
        /**
         * Call to destructively disable logging. This is useful when going
         * to production, when you want to remove all logging overhead.
         */
		public static function disable():void
        {
            mPendingLogEntries = null;
            mStarted = false;
            mLogAppenders = null;
            mDisabled = true;
        }
		
		protected static function processEntry(entry:LogEntry):void
		{
			// Early out if we are disabled.
			if(mDisabled) return;
			
			// If we aren't started yet, just store it up for later processing.
			if(!mStarted)
			{
				mPendingLogEntries.push(entry);
				return;
			}
			
			//filter the log
			var n:int = 0;
			var i:int = 0;
			
			n = mLogFilters.length;
			for(i = 0; i < n; i++)
			{
				if(!mLogFilters[i].test(entry)) return;
			}
			
			// Let all the listeners process it.
			n = mLogAppenders.length;
			for(i = 0; i< n; i++)
			{
				mLogAppenders[i].addLogMessage(entry);
			}
			
			LogEntry.recycle(entry);
		}
    }
}