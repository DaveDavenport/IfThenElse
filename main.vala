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
	private unowned string[] g_argv;
	private Parser parser = null;
	private GLib.MainLoop  loop = null;
	string? dot_file = null;
	const GLib.OptionEntry[] entries = {
		{"dot", 	'd',	0,	GLib.OptionArg.FILENAME, 	ref dot_file,
				"Output a flowchart off the if-the-else structure", null},
		{null}
	};

	private void quit_program()
	{
		if(loop != null) loop.quit();
	}


	private void start()
	{
		if(parser == null) return;

		// Iterates over all input files.
		var objects = parser.get_objects();
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
		stdout.printf("================ Started all ================\n");
	}
	private void stop()
	{
		if(parser == null) return;

		// Iterates over all input files.
		var objects = parser.get_objects();
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
		stdout.printf("================ Stopped all ================\n");
	}

	private void reload_files()
	{
		stdout.printf("================ Reload all  ================\n");
		stop();
		load();
		start();
	}

	/**
	 * This handles sigaction.
	 * USR1 == RELOAD
	 * TERM/INT == QUIT
	 * Other == Give message
	 */
	static void signal_handler (int signo) 
	{
		if(signo == Posix.SIGUSR1) {
			reload_files();
			return;
		}

		switch (signo) {
			case Posix.SIGTERM:
			case Posix.SIGINT:
				quit_program();

				if (strsignal (signo) != null) {
					print ("\n");
					print ("Received signal:%d->'%s'\n", signo, strsignal (signo));
				}
				break;
			default:
				if (strsignal (signo) != null) {
					print ("\n");
					print ("Received signal:%d->'%s'\n", signo, strsignal (signo));
				}
				break;
		}


	}
	/**
	 * Construct the parser, load all files.
	 */
	private void load()
	{
		parser = null;
		parser = new IfThenElse.Parser();
		// Load the files passed on the commandline.
		for(int i =1; i < g_argv.length; i++)
		{
			unowned string file = g_argv[i];
			stdout.printf("Load file: %s\n", file);
			try{
				parser.add_from_file(file);
			}catch(GLib.Error e) {
				GLib.error("Failed to load builder file: %s, %s\n",
						file, e.message);
			}
		}
	}

	// This generates a dot file for the given obect structure
	// (builder).
	static void generate_dot_file(Parser builder)
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

			// Register the types.
			// Checks
			var a = typeof(TrueCheck);
			a = typeof(AlternateCheck);
			a = typeof(ExternalToolCheck);
			a = typeof(TimeCheck);
			a = typeof(OutputWatch);

			// Actions.
			a = typeof(DebugAction);
			a = typeof(ExternalToolAction);
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
			g_argv = argv;

			// Load the setup file.
			load();

			// Generate a dot file.
			if(dot_file != null)
			{
				generate_dot_file(parser);
				// Exit succesfull
				return 0;
			}
			
			// Create main loop.
			loop = new GLib.MainLoop();

			/**
			 * Handle signals
			 */
			var empty_mask = Posix.sigset_t ();
			Posix.sigemptyset (empty_mask);

			var act = Posix.sigaction_t ();
			act.sa_handler = signal_handler;
			act.sa_mask = empty_mask;
			act.sa_flags = 0;

			Posix.sigaction (Posix.SIGTERM, act, null);
			Posix.sigaction (Posix.SIGINT, act, null);
			Posix.sigaction (Posix.SIGHUP, act, null);
			Posix.sigaction (Posix.SIGUSR1, act, null);


			// Run program.
			stdout.printf("Start....\n");
			start();
			stdout.printf("Run loop...\n");
			loop.run();
			stdout.printf("\nQuit....\n");

			stop();
			// Destroy
			parser = null;
			return 0;
	}
}
