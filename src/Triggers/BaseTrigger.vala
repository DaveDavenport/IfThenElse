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
     * Abstract BaseTrigger class. All triggers should inherit from this.
     */
    public abstract class BaseTrigger : BaseAction, Base {
        protected BaseAction _action = null ;
        // Make this unowned so we don't get circular dependency.
        public BaseAction action {
            get {
                return _action ;
            }
            set {
                _action = value ;
                (_action as Base).parent = this ;
            }
        }

        public abstract void enable_trigger() ;
        public abstract void disable_trigger() ;


        /**
         * BaseAction implementation.
         */
        public virtual void Activate(Base p) {
            enable_trigger () ;
            _is_active = true ;
        }

        public virtual void Deactivate(Base p) {
            GLib.message ("%s: Deactivate\n", this.name) ;
            if( _action != null ){
                _action.Deactivate (this) ;
            }
            disable_trigger () ;
            _is_active = false ;
        }

        /**
         * Activate the child
         */
        public virtual void fire() {
            GLib.message ("Fire trigger: %p\n", _action) ;
            if( _action != null ){
                _action.Activate (this) ;
            }
        }
        public virtual string get_dot_description() {
            return this.get_public_name();
        }

        public virtual Gvc.Node output_dot(Gvc.Graph graph) {
            var node = graph.create_node (this.name) ;
            node.set ("shape", "invhouse");
            node.set ("label", this.get_dot_description()) ;
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
