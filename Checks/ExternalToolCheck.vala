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

namespace IfThenElse{
/**
 * Checks an external tool to see what branch should fire.
 *
 * =Example=
 *
 * When Action1 should be fired when test.sh returns 1, action2 should
 * fire when test.sh returns 0 and nothing should happen
 * when another status is returns.
 *
 * {{{
 * [TestSHCheck]
 * type=ExternalToolCheck
 * cmd=test.sh
 * true_status=1
 * false_status=0
 * compare_old_state=false
 * then-action=Action1
 * else-action=Action2
 * }}}
 *
 * It is also possible to check the output string, by setting the
 * output_compare property. Setting this property will disable the return
 * status check.
 */

    public class ExternalToolCheck : BaseCheck {
/**
 * Program to execute.
 */
        public string cmd { get ; set ; default = "" ; }
/**
 * Regex that when matches the output fires the if branch.
 *
 * Setting this property disables the status check.
 */
        public string ? output_compare { get ; set ; default = null ; }

/**
 * The output status that triggers the then branch
 */
        public int true_status { get ; set ; default = 1 ; }

/**
 * The output status that triggers the else branch
 */
        public int false_status { get ; set ; default = 8 ; }

/**
 * If the same status result comes in a row ignore these.
 * e.g. you have a script that returns 1 when the light is on and
 * 0 when off, you only want it to trigger when it changes.
 * enabling this option enables this.
 */
        public bool compare_old_state { get ; set ; default = false ; }
        private int old_state = -99999 ;
/**
 * Constructor
 **/
        public ExternalToolCheck () {
        }

/*
 * Check function.
 */
        public override BaseCheck.StateType check() {
            try {
                string[3] argv = new string[3] ;
                int exit_value = 1 ;
                string output = null ;

                argv[0] = "bash" ;
                argv[1] = "-c" ;
                argv[2] = cmd ;

                GLib.Process.spawn_sync (
                    null, // work dir
                    argv, // argv
                    null, // envp
                    SpawnFlags.SEARCH_PATH, // spawn flags
                    null, // setup func
                    out output, // stdout
                    null, // stderr
                    out exit_value // exit value.
                    ) ;
                exit_value = GLib.Process.exit_status (exit_value) ;
                GLib.message ("output: %i:%s vs %s %d\n", exit_value, output, output_compare,
                              exit_value) ;
                if( output_compare == null ){
                    if( compare_old_state ){
                        if( old_state == exit_value ){
                            return StateType.NO_CHANGE ;
                        }
                        old_state = exit_value ;
                    }
                    if( exit_value == true_status ){
                        return StateType.TRUE ;
                    } else if( exit_value == false_status ){
                        return StateType.FALSE ;
                    } else {
                        return StateType.NO_CHANGE ;
                    }
                } else {
                    try
                    {
                        var regex = new GLib.Regex (output_compare) ;
                        if( regex.match (output)){
                            if( compare_old_state && old_state == (int) StateType.TRUE ){
                                return StateType.NO_CHANGE ;
                            }
                            old_state = StateType.TRUE ;
                            return StateType.TRUE ;
                        } else {
                            if( compare_old_state && old_state == (int) StateType.FALSE ){
                                return StateType.NO_CHANGE ;
                            }
                            old_state = StateType.FALSE ;
                            return StateType.FALSE ;
                        }
                    }
                    catch (GLib.Error e)
                    {
                        GLib.error ("Failed to parse Regex: %s: %s", output_compare,
                                    e.message) ;
                    }
                }
            } catch (GLib.SpawnError e)
            {
                GLib.error ("Failed to spawn external program: %s\n",
                            e.message) ;
            }
            // return StateType.NO_CHANGE;
        }

/**
 * Get a description of this class that can be used in the dot
 * diagram.
 */
        public override string get_dot_description() {
            if( output_compare != null ){
                return "%s == %s".printf (cmd, output_compare) ;
            } else {
                return cmd ;
            }
        }

    }
}

