using GLib;
/****************************************
 * DEBUG CODE. No usefull functionality
 ****************************************/
namespace IfThenElse
{
	/**
	 * This check class alternates between true/false. 
	 * This is usefull purely for testing.
	 */
	public class AlternateCheck : BaseCheck, Base
	{
		public bool state = false;
		
		/**
		 * Constructor
		 **/
		public AlternateCheck()
		{
			
		}
		/**
		 * Check function.
		 */
		public bool check()
		{
			state = !state;
			stdout.printf("state: %i\n", (int)state);
			return state;
		}
		
	}

}
