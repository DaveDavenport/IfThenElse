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
     * Allow you to activate multiple branches from the same input.
     *
     * If you want to trigger Action1 and Action2 by one Trigger.
     * {{{
     * [Trigger]
     * ....
     * action=Multi
     *
     * [Multi]
     * action=Action1;Action2
     * }}}
     */
    public class MultiAction : BaseAction, Base {
        private List<BaseAction> actions ;
        public BaseAction action {
            set {
                if( actions.find (value) != null ){
                    GLib.error ("You cannot add the same action multiple times.") ;
                }
                actions.append (value as BaseAction) ;
                (value as Base).parent = this ;
            }
        }

        /**
         * Activate()
         *
         * Propagate this to the children.
         */
        public void Activate(Base p) {
            this._is_active = true;
            foreach( BaseAction action in actions ){
                action.Activate (this) ;
            }
        }

        /**
         * Deactivate()
         *
         * Propagate this to the children.
         */
        public void Deactivate(Base p) {
            this._is_active = false;
            foreach( BaseAction action in actions ){
                action.Deactivate (this) ;
            }
        }

        public override Gvc.Node output_dot(Gvc.Graph graph) {
            var node = graph.create_node (this.name) ;
            node.set ("label", this.get_dot_description()) ;
            foreach( BaseAction action in actions ){
                var an = action.output_dot(graph);
                graph.create_edge(node, an);
            }
            return node ;
        }
    }
}
