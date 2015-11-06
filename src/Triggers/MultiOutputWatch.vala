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
     * An MultiOutputWatch trigger: Watches the output off a program and triggers
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
     * type=MultiOutputWatch
     * cmd=mpc idleloop player
     * fire_regex=regex1;regex2;regex3
     * action=action1;action2;action3
     * }}}
     *
     * To fire when a tool returns, e.g. inotifywatch use {@link ExternalToolTrigger}
     *
     */
    public class MultiOutputWatch : BaseTrigger {
        /**
         * The commando to execute.
         */
        public string cmd { get ; set ; default = "" ; }

        /**
         * Kill the program when the node gets deactivated.
         */
        public bool kill_child { get ; set ; default = true ; }


        private const uint max_num_regexes = 8 ;
        private uint num_fire_regexes = 0 ;
        private string fire_regexes[8] ;

        private uint num_actions = 0 ;
        private BaseAction actions[8] ;
        /**
         * The regex that match  the output that triggers a fire
         */
        public string[] fire_regex {
            set {
                for( uint i = 0 ; i < value.length ; i++ ){
                    if( num_fire_regexes >= max_num_regexes ){
                        GLib.error ("Maximum number of regexes reached.") ;
                    }
                    fire_regexes[num_fire_regexes] = value[i] ;
                    num_fire_regexes++ ;
                }
            }
        }
        public new BaseAction action {
            set {
                GLib.stdout.printf ("Set: %u %p\n", num_actions, value) ;
                actions[num_actions] = value ;
                (actions[num_actions] as Base).parent = this ;
                num_actions++ ;
            }
        }

        /**
         * Check output.
         */
        private bool output_data_cb(IOChannel source, IOCondition cond) {
            string retv ;
            size_t length, term_pos ;
            try {
                source.read_line (out retv, out length, out term_pos) ;
                GLib.message ("Read: %s\n", retv) ;
                for( uint i = 0 ; i < num_fire_regexes ; i++ ){
                    printf ("match: %u: %s %s\n", i, fire_regexes[i], retv) ;
                    // continue to watch.
                    var regex = new GLib.Regex (fire_regexes[i]) ;
                    if( regex.match (retv)){
                        GLib.message ("Fire: %s\n", retv) ;
                        if( num_actions >= i ){
                            this.actions[i].Activate (this) ;
                        } else {
                            GLib.error ("Action for this match does not exist") ;
                        }
                    } else {
                        if( num_actions >= i ){
                            this.actions[i].Deactivate (this) ;
                        }
                    }
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

        public override string get_dot_description() {
            return "%s\n(%s)".printf (this.get_public_name (), cmd) ;
        }

        public override void Deactivate(Base p) {
            GLib.message ("%s: Deactivate\n", this.name) ;
            for( uint i = 0 ; i < num_actions ; i++ ){
                actions[i].Deactivate (this) ;
            }
            disable_trigger () ;
        }

        public override Gvc.Node output_dot(Gvc.Graph graph) {
            var node = graph.create_node (this.name) ;
            node.set ("label", this.get_dot_description ()) ;
            if( this._is_active ){
                node.set ("color", "red") ;
            }
            for( uint i = 0 ; i < num_actions ; i++ ){
                var an = this.actions[i].output_dot (graph) ;
                graph.create_edge (node, an) ;
            }
            return node ;
        }

    }
}

