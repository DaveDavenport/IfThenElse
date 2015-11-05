/*
 * Copyright 2011-2015  Martijn Koedam <qball@gmpclient.org>
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

using GLib ;
using Posix ;

namespace IfThenElse{
/**
 * An OutputWatch trigger: Watches the output off a program and triggers
 * when a certain condition is met.
 *
 * This trigger fires when a program outputs a certain string.
 *
 * The timer trigger supports being started and stopped and can be placed
 * anywhere in the chain.
 *
 * =Example=
 *
 * So if you want a certain branch (MainBranch) to fire when mpc idle
 * return player.
 *
 * Add an element like:
 * {{{
 * [MpcIdleWatch]
 * type=OutputWatch
 * cmd=mpc idleloop player
 * fire_regex=.*player$
 * action=MainBranch
 * }}}
 *
 * To fire when a tool returns, e.g. inotifywatch use {@link ExternalToolTrigger}
 *
 */
    public class OutputWatch : BaseTrigger {
/**
 * The commando to execute.
 */
        public string cmd { get ; set ; default = "" ; }

/**
 * Kill the program when the node gets deactivated.
 */
        public bool kill_child { get ; set ; default = true ; }

/**
 * The regex that match  the output that triggers a fire
 */
        public string fire_regex { get ; set ; default = ".*" ; }


/**
 * Check output.
 */
        private bool output_data_cb(IOChannel source, IOCondition cond) {
            string retv ;
            size_t length, term_pos ;
            try {
                source.read_line (out retv, out length, out term_pos) ;
                GLib.message ("Read: %s\n", retv) ;
                // continue to watch.
                var regex = new GLib.Regex (fire_regex) ;
                if( regex.match (retv)){
                    GLib.message ("Fire: %s\n", retv) ;
                    this.fire () ;
                }
            } catch (GLib.Error e)
            {
                GLib.warning ("Failed to parse and check commandline output: %s",
                              e.message) ;
            }
            return true ;
        }

        private GLib.Pid pid = 0 ;
        private uint output_watch = 0 ;
        private uint pid_watch = 0 ;
        private void child_watch_called(GLib.Pid p, int status) {
            GLib.Process.close_pid (p) ;
            GLib.message ("Child watch called: %i.\n", (int) p) ;
            pid = 0 ;
            if( output_watch > 0 ){
                GLib.Source.remove (output_watch) ;
                output_watch = 0 ;
            }
            if( pid_watch > 0 ){
                GLib.Source.remove (pid_watch) ;
                pid_watch = 0 ;
            }
        }

        private void start_application() {
            if( kill_child ){
                stop_application () ;
                pid = 0 ;
            }
            if( pid == 0 ){
                string[3] argv = new string[3] ;
                GLib.message ("Start application\n") ;
                try {
                    int standard_output = -1 ;

                    argv[0] = "bash" ;
                    argv[1] = "-c" ;
                    argv[2] = cmd ;

                    foreach( var s in argv ){
                        GLib.message ("argv: %s\n", s) ;
                    }
                    GLib.Process.spawn_async_with_pipes (
                        null, argv, null,
                        SpawnFlags.SEARCH_PATH | SpawnFlags.DO_NOT_REAP_CHILD, null,
                        out pid, null, out standard_output, null) ;

                    pid_watch = GLib.ChildWatch.add (pid, child_watch_called) ;
                    // Put a watch on the output.
                    var io = new IOChannel.unix_new (standard_output) ;
                    output_watch = io.add_watch (IOCondition.IN, output_data_cb) ;
                } catch (Error e)
                {
                    GLib.warning ("Failed to start application: %s", e.message) ;
                }
            }
        }

        private void stop_application() {
            if( pid > 0 ){
                GLib.message ("%s: Killing pid: %i\n", this.name, (int) pid) ;
                Posix.kill ((pid_t) pid, 1) ;
                // Disconnect all signals.
                child_watch_called (pid, 1) ;
            }
        }

        public override void enable_trigger() {
            start_application () ;
        }

        public override void disable_trigger() {
            stop_application () ;
        }

        public override Gvc.Node output_dot(Gvc.Graph graph) {
            var str = "%s\n(%s\n==\n%s)".printf (this.get_public_name (),
                                                 cmd,
                                                 fire_regex) ;

            var node = graph.create_node (this.name) ;
            node.set ("label", str) ;
            if( this._is_active ){
                node.set ("color", "red") ;
            }
            if( this._action != null ){
                var action_node = this._action.output_dot (graph) ;
                graph.create_edge (node, action_node) ;
            }
            return node ;
        }

    }
}

