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
	public abstract class BaseTrigger: BaseAction, Base, FixGtk.Buildable
	{
		// Make this unowned so we don't get circular dependency.
		protected BaseAction action = null;
		
		/**
		 * GtkBuilder function.
		 */
		public void add_child (Gtk.Builder builder, GLib.Object child, string? type)
		{
			if(action != null) {
				GLib.error("You can only add one action to a trigger.\n"+
							"Use a multiaction to add more items\n");
			}
			if(child is BaseAction)
			{
				stdout.printf("Adding child to the trigger\n");
				action = child as BaseAction;
				// Set parent.
				(child as Base).parent = this;
				return;
			}
			GLib.error("Trying to add a non BaseAction to Trigger");
		}

		public abstract void enable_trigger();
		public abstract void disable_trigger();


		/**
		 * BaseAction implementation.
		 */
		public void Activate()
		{
			enable_trigger();
		}
		
		public void Deactivate()
		{
			if(action != null) {
				action.Deactivate();
			}
			disable_trigger();
		}
		/**
		 * Activate the child
		 */
		public void fire()
		{
			stdout.printf("Fire trigger: %p\n", action);
			if(action != null) {
				action.Activate();
			}
		}
		
		public virtual void output_dot(FileStream fp)
		{
			fp.printf("'%s' [label=\"%s\", shape=oval]\n", 
						this.get_name(),
						this.get_name());
			fp.printf("%s -> %s\n", this.get_name(), (action as Gtk.Buildable).get_name());
			this.action.output_dot(fp);
		}
	}
}
