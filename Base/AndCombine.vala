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
     * If all its inputs are activates, it activates it child.
     *
     * This is basically an AND statement.
     * This is and {@link MultiCombine} are only nodes that can be child to multiple other nodes.
     *
     * =Example:=
     *
     * {{{
     *  [CombineInputs]
     *  type=AndCombine
     *  action=CombinedAndAction
     * }}}
     * @see MultiCombine
     */
    public class AndCombine : BaseAction, Base {
        private BaseAction _action = null ;
        public BaseAction action {
            get {
                return _action ;
            }
            set {
                if( _action != null ){
                    GLib.error ("%s: action is allready set", this.name) ;
                }
                _action = value ;
                (_action).parent = this ;
            }
        }

        // We allow multiple parents.
        private List<unowned Base> parents ;
        public override unowned Base ? parent {
            set {
                parents.append (value as BaseAction) ;
            }
            get {
                if( parents.length () > 0 ){
                    return parents.data ;
                }
                return null ;
            }
        }

        /**
         * Generate dot output for this node
         *
         * A class implementing this interface that has children nodes should propagate this
         * to its children.
         */
        public Gvc.Node output_dot(Gvc.Graph graph) {
            var node = graph.find_node (this.name) ;
            if( node != null ){
                return node ;
            }
            node = graph.create_node (this.name) ;
            node.set ("label", this.get_public_name ()) ;
            node.set ("shape", "box") ;
            if( this._is_active ){
                node.set ("color", "red") ;
            }
            if( this._action != null ){
                var action_node = this._action.output_dot (graph) ;
                graph.create_edge (node, action_node) ;
            }
            return node ;
        }

        /**
         * Activate()
         *
         * Propagate this to the children.
         */
        private List<unowned Base> active ;
        private List<unowned Base> inactive ;

        public void Activate(Base b) {
            this._is_active = true;
            unowned List<unowned Base> item = inactive.find (b) ;
            if( item != null ){
                inactive.remove (b) ;
            }
            item = active.find (b) ;
            if( item == null ){
                active.prepend (b) ;
            }
            if( active.length () == parents.length ()){
                action.Activate (this) ;
            }
        }

        /**
         * Deactivate()
         *
         * Propagate this to the children.
         */
        public void Deactivate(Base b) {
            this._is_active = false;
            // current number of activated items.
            uint cur_activated = active.length () ;
            unowned List<unowned Base> item = active.find (b) ;
            if( item != null ){
                active.remove (b) ;
            }
            item = inactive.find (b) ;
            if( item == null ){
                inactive.prepend (b) ;
            }
            // If in previous state everybody was activated,
            // Deactivated.
            if( cur_activated == parents.length ()){
                action.Deactivate (this) ;
            }
        }

    }
}
