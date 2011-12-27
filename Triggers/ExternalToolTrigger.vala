/**
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
		
		private bool main_thread_callback()
		{
			this.fire();
			return false;
		}
		
		private void *thread_func()
		{
			while(true)
			{
				// Wait till a cmd is set (needed for gtkbuilder)
				while(cmd == null)
				{
					GLib.Thread.usleep((ulong)1000000);
				}
				try{
					int exit_status = 0;
					GLib.Process.spawn_command_line_sync(cmd,null, null, out exit_status);
					if(exit_status == 0) {
						GLib.Idle.add(main_thread_callback);
					}
				}catch(GLib.SpawnError e)
				{
					GLib.error("Failed to spawn child process: %s",
								e.message);
				}
			}
		}
		construct{
			try{
				Thread.create<void *>(thread_func, false);
			}catch(GLib.Error e){
				GLib.error("Failed to create thread: %s", e.message);
			}
		}
		
		/**
		 * Constructor
		 */
		public ExternalToolTrigger(string command_line)
		{
			cmd = command_line;
		}

		/**
		 * ToDo: Impement this so we can start/stop this trigger.
		 */
		 public override void enable_trigger()
		 {
			 
		 }
		 public override void disable_trigger()
		 {
			 
		 }
	}
}
