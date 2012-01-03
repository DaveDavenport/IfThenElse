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
using Posix;

namespace IfThenElse
{
	public class OutputWatch: BaseTrigger
	{
		public string cmd {get; set; default = "";}
		public bool kill_child {get; set; default = true;}
		public string fire_regex {get; set; default = ".*";}

		public OutputWatch(string cmd)
		{
			this.cmd = cmd;
		}




		/**
		 * Check output.
		 */
		private bool output_data_cb(IOChannel source, IOCondition cond)
		{
			string retv;
			size_t length, term_pos;
			try{
				source.read_line(out retv,  out length, out term_pos);
				GLib.stdout.printf("Read: %s\n", retv);
				// continue to watch.
				var regex = new GLib.Regex (fire_regex);	
				if(regex.match(retv)) {
					GLib.stdout.printf("Fire: %s\n", retv);
					this.fire();
				}
			}catch(GLib.Error e) {
				GLib.warning("Failed to parse and check commandline output: %s",
						e.message);
			}
			return true;
		}


		private GLib.Pid pid = 0;
		private uint output_watch = 0;
		private void child_watch_called(GLib.Pid p, int status)
		{
			GLib.Process.close_pid(p);
			GLib.stdout.printf("Child watch called.\n");
			pid = 0;
			if(output_watch > 0){
				GLib.Source.remove(output_watch);
				output_watch = 0;
			}
		}

		private void start_application()
		{
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
					int standard_output = -1;
					GLib.Shell.parse_argv(cmd, out argv);

					foreach (var s in argv)
					{
						GLib.stdout.printf("argv: %s\n", s);
					}
					GLib.Process.spawn_async_with_pipes(
							null, argv, null, 
							SpawnFlags.SEARCH_PATH|SpawnFlags.DO_NOT_REAP_CHILD, null, 
							out pid,null,  out standard_output, null);

					GLib.ChildWatch.add(pid, child_watch_called);
					// Put a watch on the output.
					var io = new IOChannel.unix_new(standard_output);
					io.add_watch(IOCondition.IN, output_data_cb);
				} catch (Error e) {
					GLib.warning("Failed to start application: %s", e.message);
				}
			}
		}
		private void stop_application()
		{
			if(pid > 0)
			{
				GLib.stdout.printf("Killing pid: %i\n", (int)pid);
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

