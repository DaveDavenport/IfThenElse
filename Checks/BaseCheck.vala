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

namespace IfThenElse{
    /**
     * Abstract class for Checks: Each check should inherit from.
     */
    public abstract class BaseCheck : BaseAction, Base {
        // Then/Else actions.
        private BaseAction ? _else_action = null ;
        private BaseAction ? _then_action = null ;
        public BaseAction ? else_action {
            get {
                return _else_action ;
            }
            set {
                _else_action = value ;
                (_else_action as Base).parent = this ;
            }
        }
        public BaseAction ? then_action {
            get {
                return _then_action ;
            }
            set {
                _then_action = value ;
                (_then_action as Base).parent = this ;
            }
        }

        public enum StateType {
            NO_CHANGE,
            TRUE,
            FALSE
        }
        public abstract StateType check() ;
        public abstract string get_dot_description() ;




        /**
         * Handle activation. In this case, we call the check,
         * see if it changed.
         */
        public void Activate(Base p) {
            BaseCheck.StateType state = this.check () ;
            GLib.message ("%s Activate: %i\n", this.name, (int) state) ;
            // If no change, do nothing.
            if( state == BaseCheck.StateType.NO_CHANGE ){
                return ;
            }
            if( state == BaseCheck.StateType.TRUE ){
                // Then statement.
                if( _then_action != null ){
                    _then_action.Activate (this) ;
                }
                if( _else_action != null ){
                    _else_action.Deactivate (this) ;
                }
            } else {
                // Else Statement.
                if( _else_action != null ){
                    _else_action.Activate (this) ;
                }
                if( _then_action != null ){
                    _then_action.Deactivate (this) ;
                }
            }
            this._is_active = true ;
        }

        /**
         * If we get deactivated, propagate this to the children.
         */
        public void Deactivate(Base p) {
            GLib.message ("%s Deactivate\n", this.name) ;
            // Deactivate both.
            if( _then_action != null ){
                _then_action.Deactivate (this) ;
            }
            if( _else_action != null ){
                _else_action.Deactivate (this) ;
            }
            this._is_active = false ;
        }

        /**
         * Generate dot file for this element.
         * Diamond square with a yes and a no out arrow.
         */
        public Gvc.Node output_dot(Gvc.Graph graph) {
            string dot_desc = this.get_dot_description () ;
            var node = graph.create_node (this.name) ;
            node.set ("shape", "invhouse") ;
            node.set ("label", "%s\\n%s".printf (this.get_public_name (), dot_desc)) ;
            if( this._is_active ){
                node.set ("color", "red") ;
            }
            if( _then_action != null ){
                var then_node = _then_action.output_dot (graph) ;
                var edge = graph.create_edge (node, then_node) ;
                edge.set ("label", "Yes") ;
            }
            if( _else_action != null ){
                var else_node = _else_action.output_dot (graph) ;
                var edge = graph.create_edge (node, else_node) ;
                edge.set ("label", "No") ;
            }
            return node ;
        }

    }
}
