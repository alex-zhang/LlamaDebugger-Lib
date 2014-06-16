package com.llamaDebugger
{
	public final class LogType
	{
		private static var TRACE_NAME:String 	= "Trace";
		private static var DEBUG_NAME:String 	= "Debug";
		private static var INFO_NAME:String 	= "Info ";
		private static var WARN_NAME:String 	= "Warn ";
		private static var ERROR_NAME:String 	= "Error";
		
		//special.
		private static var CUSTOM_PRINT_NAME:String 	= "     ";
		
		private static var TRACE_COLOR:uint 	= 0xFFFFFF;
		private static var DEBUG_COLOR:uint 	= 0xDDDDDD;
		private static var INFO_COLOR:uint 	    = 0xBBBBBB;
		private static var WARN_COLOR:uint 	    = 0xFF6600;
		private static var ERROR_COLOR:uint 	= 0xFF0000;

		private static var TRACE_VERBOSITY:int  = 4;
		private static var DEBUG_VERBOSITY:int  = 3;
		private static var INFO_VERBOSITY:int 	= 2;
		private static var WARN_VERBOSITY:int 	= 1;
		private static var ERROR_VERBOSITY:int  = 0;
		
		public static const TRACE:LogType = new LogType(TRACE_NAME, TRACE_COLOR, TRACE_VERBOSITY);
		public static const DEBUG:LogType = new LogType(DEBUG_NAME, DEBUG_COLOR, DEBUG_VERBOSITY);
		public static const INFO:LogType = new LogType(INFO_NAME, INFO_COLOR, INFO_VERBOSITY);
		public static const WARNING:LogType = new LogType(WARN_NAME, WARN_COLOR, WARN_VERBOSITY);
		public static const ERROR:LogType = new LogType(ERROR_NAME, ERROR_COLOR, ERROR_VERBOSITY);
		
		public static const CUSTOM_PRINT:LogType = new LogType(CUSTOM_PRINT_NAME, 0xFFFFFF, -1);
		
		public var color:uint = 0;
		public var name:String;
		public var verbosity:int = 0;
		
		public function LogType(name:String, color:uint, verbosity:uint)
		{
			this.color = color;
			this.name = name;
		}
	}
}