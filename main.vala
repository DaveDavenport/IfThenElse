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
using Gtk;

namespace IfThenElse
{
	
	

static int main(string[] argv)
{
		Gtk.init(ref argv);
		
		stdout.printf("Starting program\n");
		
		stdout.printf("Adding new chain\n");
		GLib.debug("Adding new chain\n");
		
		// Register the types.
		var a = typeof(ExternalToolTrigger);
		a = typeof(TrueCheck);
		a = typeof(DebugAction);
		a = typeof(Chain);
		a = typeof(ExternalToolAction);

		var builder = new Gtk.Builder();
		for(int i =1; i < argv.length; i++)
		{
			unowned string file = argv[i];
			try{
				builder.add_from_file(file);
			}catch(GLib.Error e) {
				GLib.error("Failed to load builder file: %s,%s\n",
						file, e.message);
			}
		}

		// Run program.
		Gtk.main();
		builder= null;
		return 0;
}	
}
