using GLib;

namespace IfThenElse
{
	public class TimerTrigger : BaseTrigger
	{
		private uint handler = 0;
		
		public bool timer_callback()
		{
				this.fire();
				return true;
		}
		
		public TimerTrigger(uint timeout)
		{
				handler = GLib.Timeout.add_seconds(timeout, timer_callback);
		}
		~TimerTrigger()
		{
			if(handler > 0){
				GLib.Source.remove(handler);
				handler = 0;
			}
		}
	}
}
