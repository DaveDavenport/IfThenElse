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
	public class ExternalToolAction: BaseAction, Base
	{
		public string cmd {get; set; default = "";}
		
		public ExternalToolAction(string cmd)
		{
			this.cmd = cmd;
		}
		
		public void Activate()
		{
			//stdout.printf("Activates: %s\n", message);
			//GLib.debug("Activates "+message);
			try{
				GLib.Process.spawn_command_line_async(cmd);
			} catch(GLib.SpawnError e) {
					GLib.error("Failed to spawn external program: %s\n",
						e.message);
			}
		}
		public void Deactivate()
		{
			//stdout.printf("Deactivates: %s\n", message);
			//GLib.debug("Deactivates "+message);
		}
	}
}

