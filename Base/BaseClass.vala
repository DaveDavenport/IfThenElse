/*
 * Copyright 2011-2014  Martijn Koedam <qball@gmpclient.org>
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

namespace IfThenElse
{
	/**
	 * The base class used in IfThenElse. Each class should be derived from this.
	 *
	 * This class provides some basic functionality needed by everybody.
	 * E.g. name and parent property. A has_parent and is_toplevel check.
	 */
	public abstract class Base: GLib.Object
	{
		/// A pointer to the parent. This is the internal default storage.
		/// Use the parent <accessor>
		private unowned Base? _parent = null;


        /// Check if we are allready a child of node.
        /// TODO: This  might break on the combine module.
        private bool is_nested_parent(Base node)
        {
            unowned Base? iter = null;
            for(iter = node;  iter != null; iter = iter.parent)
            {
                if(iter == this) {
                    return true;
                }
            }
            return false;
        }
		/// Accessors
		/// Parent object. This accepts one and only one parent.
		/// Can be overriden if you want different behaviour
        [Description(blurb="Pointer to the parent object (automatically set)")]
		public virtual unowned Base? parent
		{
			get {
				return _parent;
			}
			set {
                GLib.assert(value != null);
				if(_parent != null) GLib.error("%s: parent is already set", this.name);
                if(is_nested_parent(value)) GLib.error("%s: is already a child of this node. Cycles are not allowed.", value.name);
				_parent = value;
			}

		}

        private string _name = "n/a";
        [Description(blurb="The name of the module")]
		public string name {
                get {
                    return _name;
                }
                set {
                   GLib.assert(value != null);
                   GLib.assert(value != "");
                    _name = value;
                }
        }

		/**
		 * Get the public name. Strip off the filename
		 */
		public string get_public_name()
		{
            var index = name.last_index_of_char(':');
            // If no colon set.
            if(index == 0) return name;
            // If last is colon.
            if(index == (name.length-1)) return name.substring(0, index);
            // Last element.
			return name.substring(name.last_index_of_char(':')+1, -1);
		}

		~Base()
		{
		}

        /**
         * Check if we have a parent.
         */
		public bool has_parent()
		{
			return (parent != null);
		}
		/**
		 * Check if it is a toplevel object.
		 */
		public bool is_toplevel()
		{
			return (parent == null);
		}
	}
}
