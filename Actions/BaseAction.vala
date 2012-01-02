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
	public interface BaseAction : Base
	{

		/**
		 * Activate()
		 * This activates the Action.
		 * For Example the trigger calls this on the Action when fired.
		 * Or the Chain calls this on the active branch.
		 */
		public virtual void Activate()
		{
			GLib.error("Activate action has not been implemented");
		}

		/**
		 * Deactivate()
		 * 
		 * This Deactivates the Action. Not all actions have to be 
		 * deactivatable. This is called for example on an action if 
		 * The Chain condition changes.
		 */
		public virtual void Deactivate()
		{
			GLib.warning("Deactivate action has not been implemented");
		}
		/**
		 * Generate dot output for this node
		 */
		public virtual void output_dot(FileStream fp)
		{
			fp.printf("%s [label=\"%s\", shape=oval]\n", 
						this.name,
						this.name);
		}
	}
}
