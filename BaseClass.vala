namespace IfThenElse
{
	public class Base
	{
		public string name {get; set; default="Unset";}
		/**
		 * Store the Configuration off this class in a file.
		 */
		public void Store()
		{
			GLib.debug("Store the current configuration to a file");
		}
		/**
		 * Restore the configuration of this class.
		 */
		public void Restore()
		{
			GLib.debug("Restore the current configuration to a file");
		}	
	}
}
