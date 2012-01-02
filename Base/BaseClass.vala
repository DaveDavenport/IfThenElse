/**
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
	public abstract class Base: GLib.Object
	{
		public string name {get;set;default="n/a";}
		public unowned Base parent = null;

		~Base()
		{
			stdout.printf("Destroying: %s\n", this.name);
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
