package com.llamaDebugger
{
	public class LogFilter implements ILogFilter
	{
		public function test(value:LogEntry):Boolean
		{
			return true;
		}
	}
}