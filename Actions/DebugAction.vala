using GLib;
/****************************************
 * DEBUG CODE. No usefull functionality
 ****************************************/
namespace IfThenElse
{
	public class DebugAction: BaseAction, Base
	{
		public string message = "";
		
		public DebugAction(string message)
		{
			this.message = message;
		}
		
		public void Activate()
		{
			stdout.printf("Activates: %s\n", message);
			GLib.debug("Activates "+message);
		}
		public void Deactivate()
		{
			stdout.printf("Deactivates: %s\n", message);
			GLib.debug("Deactivates "+message);
		}
	}
}
