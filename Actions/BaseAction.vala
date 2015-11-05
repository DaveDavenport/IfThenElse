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
 * Base interface each 'Action' class should implement.
 *
 * In the current design each class that should be part of the
 * decision tree should implement this. Or should inherit from a
 * base class that implements this interface.
 *
 * Activate() gets called when a certain branch in the decision tree
 * is activated.
 * Deactivate() gets called when a certain branch in the tree gets
 * deactivated.
 */
    public interface BaseAction : Base {
/**
 * This activates the Action.
 *
 * A class that can have children nodes should propagate this
 * to its children.
 * For Example the trigger calls this on the Action when fired.
 * Or the Chain calls this on the active branch.
 */
        public virtual void Activate(Base p) {
            GLib.error ("Activate action has not been implemented") ;
        }

/**
 * This Deactivates the Action.
 *
 * A class that can have children nodes should propagate this
 * to its children.
 * ot all actions have to be
 * deactivatable. This is called for example on an action if
 * The Chain condition changes.
 */
        public virtual void Deactivate(Base p) {
            GLib.warning ("Deactivate action has not been implemented") ;
        }

/**
 * Generate dot output for this node
 *
 * A class implementing this interface that has children nodes should propagate this
 * to its children.
 */
        public virtual Gvc.Node output_dot(Gvc.Graph graph) {
            var node = graph.create_node (this.name) ;
            node.set ("label", this.get_public_name ()) ;
            return node ;
        }

    }
}
