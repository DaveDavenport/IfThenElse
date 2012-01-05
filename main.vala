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

/**
 * IfThenElse is a simple program used to glue small unix tools to getter
 * with the ultimate goal to automate some tedious tasks.
 *
 * The structure off an IfThenElse chain is as follow:
 * Trigger -> Check -> [Then] Action1 | [Else] Action2
 *
 * For example a chain could be:
 *
 *  * Trigger: Every minute<<BR>>
 *  * Check:   Is a Movie Playing<<BR>>
 *  * Then:    Turn off the light<<BR>>
 *  * Else:    Turn on the light<<BR>>
 *
 * This should result the light turning off when starting the movie, and on
 * when the movie is finished.
 *
 * Each IfThenElse chain is an action in itself and can be chained up.
 * 
 * ''File format''
 *
 * A chain is described in it own file using the ini format. 
 * The above example would look like:
 *
 * {{{
 * [Trigger]
 * type=TimerTrigger
 * timeout=60
 * action=Check
 * 
 * [Check]
 * type=ExternalToolCheck
 * cmd=check_movies.sh
 * true_status=1
 * false_status=0
 * compare_old_state=true
 * then_action=Then
 * else_action=Else
 * 
 * [Then]
 * type=ExternalToolAction
 * cmd=switch_off_lights.sh
 * 
 * [Else]
 * type=ExternalToolAction
 * cmd=switch_on_lights.sh 
 * }}}
 *
 * As you can see all it does is to tie external tools together.
 * If you want to use multiple triggers, or drive multiple actions you have to use the
 * {@link MultiCombine} node in between to combine the different inputs, or the {@link MultiAction} to 
 * drive multiple actions.
 * 
 * So say that we want to turn_off the lights and put gajim in offline mode:
 *
 * {{{
 * [Trigger]
 * type=TimerTrigger
 * timeout=60
 * action=Check
 * 
 * [Check]
 * type=ExternalToolCheck
 * cmd=check_movies.sh
 * true_status=1
 * false_status=0
 * compare_old_state=true
 * then_action=ThenMulti
 * else_action=Else
 *
 * [ThenMulti]
 * type=MultiAction
 * action=Then1;Then2
 * 
 * [Then1]
 * type=ExternalToolAction
 * cmd=switch_off_lights.sh
 * 
 * [Then2]
 * type=ExternalToolAction
 * cmd=gajim-remote change_status offline
 *
 * [Else]
 * type=ExternalToolAction
 * cmd=switch_on_lights.sh 
 * }}}
 *
 * This way, it is easy to make complex chains. 
 *
 * ''Using the program''  
 *
 * Run the program:
 * {{{
 * ifthenelse <list of input files>
 * }}}
 *
 *
 * If you want to generate a dot graph:
 * {{{
 * ifthenelse -d output.dot <list of intput files>
 * }}}
 *
 * If you want to background IfThenElse. 
 * {{{
 * ifthenelse -b <list of intput files>
 * }}}
 * 
 * If a directory is passed it will, recursively, scan that directory for .ife files.
 *
 * To stop the program send it a TERM/HUP/INT signal (e.g. press ctrl-c)
 *
 * To force it to reload the input files send it a USR1 signal.
 * 
 * @see MultiAction
 * @see MultiCombine
 */
namespace IfThenElse
{
	private unowned string[] g_argv;
	private Parser parser = null;
	private GLib.MainLoop  loop = null;
	private bool daemonize = false;
	string? dot_file = null;
	const GLib.OptionEntry[] entries = {
		{"dot", 	'd',	0,	GLib.OptionArg.FILENAME, 	ref dot_file,
				"Output a flowchart off the if-the-else structure", null},
		{"background",	'b', 0, GLib.OptionArg.NONE,		out daemonize,
				"Daemonize the program", null},	
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
					stdout.printf("==== Starting : %s\n", (o as Base).name);
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
		load_argument();
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
	private void load_file(string file, bool force = false)
	{
		if(force || GLib.Regex.match_simple(".*\\.ife$", file))
		{	
			stdout.printf("Load file: %s\n", file);
			try{
				parser.add_from_file(file);
			}catch(GLib.Error e) {
				GLib.error("Failed to load builder file: %s, %s\n",
						file, e.message);
			}
		}
		else
		{
			stdout.printf("Ignoring: %s\n", file);
		}
	}
	private void load_dir(string dir)
	{
		try{
			Dir d = Dir.open(dir);
			unowned string? file = null;
			while( (file = d.read_name()) != null)
			{
				var filename = GLib.Path.build_filename(dir, file);
				load(filename);
			}

		}catch(GLib.Error e) {
			GLib.error("Failed to load directory: %s, %s\n",
					dir, e.message);
		}
	}
	private void load(string file, bool force = false)
	{
		if(GLib.FileUtils.test(file, GLib.FileTest.IS_REGULAR))
		{
			load_file(file, force);
		}
		else if (GLib.FileUtils.test(file, GLib.FileTest.IS_DIR))
		{
			load_dir(file);
		}
	}
	private void load_argument()
	{
		parser = null;
		parser = new IfThenElse.Parser();
		// Load the files passed on the commandline.
		for(int i =1; i < g_argv.length; i++)
		{
			unowned string file = g_argv[i];
			load(file, true);		
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

	/**
	 * Background ifthenelse.
	 */
	static void background()
	{
		// Duplicate and exit the parent.
		var pid = Posix.fork();
		if(pid < 0){
			GLib.error("Failed to fork to the background");
		}
		if(pid > 0) {
			// Main thread.
			Posix.exit(0);
		}
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
		a = typeof(ExternalToolAction);
		a = typeof(MultiAction);

		// Triggers
		a = typeof(ExternalToolTrigger);
		a = typeof(TimerTrigger);
		a = typeof(InitTrigger);
		a = typeof(ClockTrigger);
		// other
		a = typeof(MultiCombine);


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
		load_argument();

		// Generate a dot file.
		if(dot_file != null)
		{
			generate_dot_file(parser);
			parser = null;
			// Exit succesfull
			return 0;
		}


		if(daemonize) {
			background();
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
