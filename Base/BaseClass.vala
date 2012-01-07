/*
 * Copyright 2011-2012  Martijn Koedam <qball@gmpclient.org>
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

		/// Accessors
		/// Parent object. This accepts one and only one parent.
		/// Can be overriden if you want different behaviour
		public virtual unowned Base? parent
		{
			get {
				return _parent;
			}
			set {
				if(_parent != null) GLib.error("%s: parent is allready set", this.name);
				_parent = value;
			}

		} 
		public string name {get;set;default="n/a";}

		/**
		 * Get the public name. Strip off the filename
		 */
		public string get_public_name()
		{
			return name.substring(name.last_index_of_char(':')+1, -1);
		}

		~Base()
		{
			GLib.message("Destroying: %s\n", this.name);
		}	
		/**
		 * Check if it is a toplevel object.
		 */
		public bool has_parent()
		{
			return (parent != null);
		}
		public bool is_toplevel()
		{
			return (parent == null);
		}
	}
}
