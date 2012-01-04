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

namespace IfThenElse
{

	public class ExternalToolCheck : BaseCheck
	{
		public string cmd {get; set; default = "";}
		public string? output_compare { get; set; default=null;}
		public bool state = false;
		
		public int true_status {get; set; default = 1;}
		public int false_status {get; set; default=8;}
		public bool compare_old_state {get;set;default=false;}
		private int old_state = -99999;
		/**
		 * Constructor
		 **/
		public ExternalToolCheck()
		{
		}
		
		/*
		 * Check function.
		 */
		public override BaseCheck.StateType check()
		{
			try{
				int exit_value = 1;
				string output = null;
				GLib.Process.spawn_command_line_sync(cmd,
							out output, null, out exit_value);
				exit_value = GLib.Process.exit_status(exit_value);
				stdout.printf("output: %i:%s vs %s\n", exit_value, output, output_compare);
				if(output_compare == null)
				{
					if(compare_old_state)
					{
						if(old_state == exit_value)
						{
							return StateType.NO_CHANGE;
						}
						old_state = exit_value;
					}
					if(exit_value ==  true_status){
						return StateType.TRUE;
					}else if (exit_value == false_status) {
						return StateType.FALSE;
					}else{
						return StateType.NO_CHANGE;
					}
				}else{
						if(output_compare.strip() == output.strip())
						{
							if(compare_old_state && old_state == (int)StateType.TRUE)
								return StateType.NO_CHANGE;
							old_state = StateType.TRUE;
							return StateType.TRUE;
						} else {
							if(compare_old_state && old_state == (int)StateType.FALSE)
								return StateType.NO_CHANGE;
							old_state = StateType.FALSE;
							return StateType.FALSE;
						}
				}
			} catch(GLib.SpawnError e) {
					GLib.error("Failed to spawn external program: %s\n",
						e.message);
			}
			//return StateType.NO_CHANGE;
		}
		/**
		 * Get a description of this class that can be used in the dot
		 * diagram.
		 */
		public override string get_dot_description()
		{
			if(output_compare != null)
			{
				return "%s == %s".printf(cmd, output_compare);
			}else{
				return cmd;
			}
		}
	}
}

