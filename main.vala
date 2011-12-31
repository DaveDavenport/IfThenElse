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
	string? dot_file = null;
	const GLib.OptionEntry[] entries = {
		{"dot", 	'd',	0,	GLib.OptionArg.FILENAME, 	ref dot_file,
				"Output a flowchart off the if-the-else structure", null},
		{null}
	};

	// This generates a dot file for the given obect structure
	// (builder).
	static void generate_dot_file(Gtk.Builder builder)
	{
		FileStream fp = FileStream.open(dot_file, "w");
		// Print header.
		fp.printf("digraph FlowChart {\n");
		// Iterates over all input files.
		// Find the root item(s) and make them generate the rest 
		// off the dot file.
		var objects = builder.get_objects();
		foreach ( GLib.Object o in objects)
		{
			if((o as Base).is_toplevel())
			{
				if(o is BaseAction)
				{
					(o as BaseAction).output_dot(fp);
				}
			}
		}
		fp.printf("}\n");
		fp = null;
	}
	
	
	static int main(string[] argv)
	{
			Gtk.init(ref argv);

			// Register the types.
			// Checks
			var a = typeof(TrueCheck);
			a = typeof(AlternateCheck);
			a = typeof(ExternalToolCheck);

			// Actions.
			a = typeof(DebugAction);
			a = typeof(ExternalToolAction);
#if ENABLE_GTK_TOOLS
			a = typeof(StatusIconAction);
#endif
			a = typeof(MultiAction);
			
			// Triggers
			a = typeof(ExternalToolTrigger);
			a = typeof(TimerTrigger);


			// Commandline options parsing.

			GLib.OptionContext og = new GLib.OptionContext("IfThenElse");
			og.add_main_entries(entries,null);
			try{
				og.parse(ref argv);
			}catch (Error e) {
				GLib.error("Failed to parse command line options: %s\n", 
							e.message);
			}

			// Load the files passed on the commandline.
			var builder = new Gtk.Builder();
			for(int i =1; i < argv.length; i++)
			{
				unowned string file = argv[i];
				stdout.printf("Load file: %s\n", file);
				try{
					builder.add_from_file(file);
				}catch(GLib.Error e) {
					GLib.error("Failed to load builder file: %s,%s\n",
							file, e.message);
				}
			}

			// Generate a dot file.
			if(dot_file != null)
			{
				generate_dot_file(builder);
				// Exit succesfull
				return 0;
			}
			
			// Iterates over all input files.
			var objects = builder.get_objects();
			foreach ( GLib.Object o in objects)
			{
				if((o as Base).is_toplevel())
				{
					// Activate the toplevel one.
					if(o is BaseAction)
					{
						(o as BaseAction).Activate();
					}
				}
			}

			// Catch Control C
			GLib.Process.signal(ProcessSignal.INT, Gtk.main_quit);

			// Run program.
			stdout.printf("Start....\n");
			Gtk.main();
			stdout.printf("\nQuit....\n");

			// Iterates over all input files.
			objects = builder.get_objects();
			foreach ( GLib.Object o in objects)
			{
				if((o as Base).is_toplevel())
				{
					// Activate the toplevel one.
					if(o is BaseAction)
					{
						(o as BaseAction).Deactivate();
					}
				}
			}
			// Destroy
			builder = null;
			return 0;
	}
}
