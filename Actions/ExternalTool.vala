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
	public class ExternalToolAction: BaseAction, Base
	{
		public string cmd {get; set; default = "";}
		public bool kill_child {get; set; default = false;}
		
		public ExternalToolAction(string cmd)
		{
			this.cmd = cmd;
		}
				private GLib.Pid pid = 0;
		private void child_watch_called(GLib.Pid p, int status)
		{
			GLib.Process.close_pid(p);
			GLib.stdout.printf("Child watch called.\n");
			pid = 0;
		}
		private void start_application()
		{
			GLib.stdout.printf("%s: %s", this.name, "start application");
			if(kill_child)
			{
				stop_application();
				pid = 0;
			}
			if(pid == 0)
			{
				string[] argv;
				GLib.stdout.printf("Start application\n");
				try {
					GLib.Shell.parse_argv(cmd, out argv);

					foreach (var s in argv)
					{
						GLib.stdout.printf("argv: %s\n", s);
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
				GLib.stdout.printf("%s: Killing pid: %i\n",this.name, (int)pid);
				Posix.kill((pid_t)pid, 1);
			}
		}
		
		public void Activate()
		{
			start_application();
		}
		public void Deactivate()
		{
			GLib.stdout.printf("%s: Deactivate\n", this.name);
			stop_application();
		}
	}
}

