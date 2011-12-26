using GLib;

namespace IfThenElse
{
	
	

static int main(string[] argv)
{
		stdout.printf("Starting program\n");
		GLib.MainLoop loop = new GLib.MainLoop();
		stdout.printf("Adding new chain\n");
		GLib.debug("Adding new chain\n");

		Chain c2 = new Chain(null, 
							new AlternateCheck(),
							new DebugAction("Then statement2"),
							new DebugAction("Else statement2")
						);
		Chain c = new Chain(new TimerTrigger(1), 
							new AlternateCheck(),
							new DebugAction("Then statement1"),
							c2
							);
		// Run program.
		loop.run();
		c = null;
		return 0;
}	
}
