/*
 * Copyright 2011-2012  Martijn Koedam <qball@gmpclient.org>
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of 
 * the License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
 
using GLib;
using Posix;

namespace IfThenElse
{
	/**
	 * This trigger calls an external program. 
	 * When the program returns, the trigger is called.
	 */
	public class ExternalToolTrigger : BaseTrigger
	{
		private string _cmd = null;
		public string ?cmd {
			get {
				return _cmd;
			} 
			set {
				_cmd = value;
			}
		}
		
		~ExternalToolTrigger()
		{
			stop_application();
		}
		
		/**
		 * Constructor
		 */
		public ExternalToolTrigger(string command_line)
		{
			
			cmd = command_line;
		}


		private GLib.Pid pid = 0;
		private void child_watch_called(GLib.Pid p, int status)
		{
			GLib.Process.close_pid(pid);
			GLib.debug("Child watch called.\n");
			pid = 0;
			if(status == 0)
			{
				fire();
				start_application();
			}
		}
		private void start_application()
		{
			if(pid == 0)
			{
				string[] argv;
				GLib.debug("Start application\n");
				try {
					GLib.Shell.parse_argv(cmd, out argv);

					foreach (var s in argv)
					{
						GLib.debug("argv: %s\n", s);
					}
					GLib.Process.spawn_async(null, argv, null, SpawnFlags.SEARCH_PATH|SpawnFlags.DO_NOT_REAP_CHILD, null, out pid);

					GLib.ChildWatch.add(pid, child_watch_called);
				} catch (Error e) {
					GLib.warning("Failed to start application: %s", e.message);
				}
			}
		}
		private void stop_application()
		{
			if(pid > 0)
			{
				GLib.debug("%s: Killing pid: %i\n",this.name, (int)pid);
				Posix.kill((pid_t)pid, 1);
			}
		}

		 public override void enable_trigger()
		 {
			 start_application();
		 }
		 public override void disable_trigger()
		 {
			stop_application();
		 }
	}
}
