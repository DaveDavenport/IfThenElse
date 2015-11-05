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
     * A timer trigger: Fire at a certain interval
     *
     * This trigger fires at a certai interval.
     *
     * The timer trigger supports being started and stopped and can be placed
     * anywhere in the chain.
     *
     * =Example=
     *
     * So if you want a certain branch (MainBranch) to fire each 5 seconds
     * Add an element like:
     * {{{
     * [TimerTrigger]
     * type=TimerTrigger
     * timeout=5
     * action=MainBranch
     * }}}
     *
     * To fire at a certain time use a {@link ClockTrigger}
     *
     * @see ClockTrigger
     */
    public class TimerTrigger : BaseTrigger {
        private uint handler = 0 ;
        private uint _timeout = 5 ;


        public bool repeat { get ; set ; default = true ; }
        /**
         * The interval at witch this trigger should fire in seconds.
         *
         ********@default 5
         */
        public uint timeout {
            get {
                return _timeout ;
            }
            set {
                if( value == 0 ){
                    GLib.error ("A timeout cannot be 0") ;
                }
                _timeout = value ;
                if( handler > 0 ){
                    GLib.Source.remove (handler) ;
                    handler = GLib.Timeout.add_seconds (_timeout, timer_callback) ;
                }
            }
        }
        /**
         * Timer callback.
         */
        private bool timer_callback() {
            GLib.message ("%s: Timer fire\n", this.name) ;
            this.fire () ;
            if( !this.repeat ){
                handler = 0 ;
            }
            return this.repeat ;
        }

        /**
         * Destructor
         */
        ~TimerTrigger () {
            disable_trigger () ;
        }

        public override void enable_trigger() {
            if( handler == 0 ){
                GLib.message ("%s: enable\n", this.name) ;
                handler = GLib.Timeout.add_seconds (timeout, timer_callback) ;
            }
        }

        public override void disable_trigger() {
            if( handler > 0 ){
                GLib.message ("%s: disable\n", this.name) ;
                GLib.Source.remove (handler) ;
            }
            handler = 0 ;
        }

        /**
         * Generate dot code for this node.
         *
         * {@inheritDoc}
         */
        public override Gvc.Node output_dot(Gvc.Graph graph) {
            var str = "%s\\nTimeout Trigger: %.2f seconds".printf (
                this.name,
                this.timeout) ;
            var node = graph.create_node (this.name) ;
            node.set ("label", str) ;
            if( this._is_active ){
                node.set ("color", "red") ;
            }
            if( this.action != null ){
                var action_node = this._action.output_dot (graph) ;
                graph.create_edge (node, action_node) ;
            }
            return node ;
        }

    }
}
