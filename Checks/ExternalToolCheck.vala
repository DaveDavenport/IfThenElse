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

	public class ExternalToolCheck : BaseCheck, Base
	{
		public string cmd {get; set; default = "";}
		public bool state = false;
		
		/**
		 * Constructor
		 **/
		public ExternalToolCheck()
		{
			
		}
		/*
		 * Check function.
		 */
		public BaseCheck.StateType check()
		{
			try{
				int exit_value = 1;
				GLib.Process.spawn_command_line_sync(cmd,
							null, null, out exit_value);
				if(exit_value == 0){
					return StateType.TRUE;
				}
			} catch(GLib.SpawnError e) {
					GLib.error("Failed to spawn external program: %s\n",
						e.message);
			}
			return StateType.NO_CHANGE;
		}
		
	}

}

