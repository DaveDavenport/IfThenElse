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
 
using GLib;
namespace IfThenElse
{
	public class MultiAction : BaseAction, Base, FixGtk.Buildable
	{
		private List <BaseAction> actions;

		/**
		 * GtkBuilder function.
		 */
		public void add_child (Gtk.Builder builder, GLib.Object child, string? type)
		{
			if(child is BaseAction)
			{
				stdout.printf("Adding child to multiaction\n");
				actions.append(child as BaseAction);
				// Set parent.
				(child as Base).parent = this;
				return;
			}
			GLib.error("Trying to add a non BaseAction to MultiAction");
		}

		/**
		 * Activate()
		 * 
		 * Propagate this to the children.
		 */
		public void Activate()
		{
			foreach(unowned BaseAction action in actions)
			{
				action.Activate();
			}
		}

		/**
		 * Deactivate()
		 * 
		 * Propagate this to the children.
		 */
		public void Deactivate()
		{
			foreach(unowned BaseAction action in actions)
			{
				action.Deactivate();
			}
		}
		
		
		public void output_dot()
		{
			stdout.printf("%s [label=\"%s\", shape=oval]\n", 
					this.get_name(),
					this.get_name());
			foreach(unowned BaseAction action in actions)
			{
				stdout.printf("%s -> %s\n", this.get_name(), 
						action.get_name());
				action.output_dot();
			}
		}
	}
}
