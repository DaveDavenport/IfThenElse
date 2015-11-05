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
 * A init trigger: Fires onces at startup.
 *
 * This trigger fires at startup.;
 *
 * The timer trigger supports being started and stopped and can be placed
 * anywhere in the chain.
 *
 * =Example=
 *
 * So if you want a certain branch (MainBranch) to fire at startup.
 * Add an element like:
 * {{{
 * [InitTrigger]
 * type=InitTrigger
 * action=MainBranch
 * }}}
 *
 * It is also to trigger each time the object gets activated.
 * This is done by setting the always_trigger property true.
 *
 * @see ClockTrigger
 */
    public class InitTrigger : BaseTrigger {
        private bool init = true ;
/**
 * When this property is true, fire when this action gets
 * activated.
 */
        public bool always_trigger { get ; set ; default = false ; }

        public override void enable_trigger() {
            if( init || always_trigger ){
                this.fire () ;
            }
            init = false ;
        }

        public override void disable_trigger() {
        }

        public override Gvc.Node output_dot(Gvc.Graph graph) {
            var node = graph.create_node (this.name) ;
            node.set ("label", "Init Trigger\n%s".printf (this.get_public_name ())) ;
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
