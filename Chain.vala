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
	public class Chain : BaseAction, Base, FixGtk.Buildable
	{
		// Default is the true check.
		private BaseCheck    if_stmt 	  = new TrueCheck();
		
		// Then/Else actions.
		private BaseAction?  else_stmt 	  = null;
		private BaseAction?  then_stmt 	  = null;

		/**
		 * GtkBuilder function.
		 */
		public void add_child (Gtk.Builder builder,
								GLib.Object child,
								string? type)
		{
			if(type == null) return;
			stdout.printf("Adding to chain: %s\n", type);
			if (type == "if") {
				if_stmt = child as BaseCheck;
				// Set parent.
				(child as Base).parent = this;
			}else if (type == "else") {
				if(else_stmt != null){
					GLib.error("Else statement is allready set");
				}
				else_stmt = child as BaseAction;
				// Set parent.
				(child as Base).parent = this;
			}else if (type == "then") {
				if(then_stmt != null){
					GLib.error("Then statement is allready set");
				}
				then_stmt = child as BaseAction;
				// Set parent.
				(child as Base).parent = this;
			}
		}

		/**
		 * Destructor
		 */
		~Chain()
		{
			stdout.printf("Destroy chain\n");
		}
		construct{
			stdout.printf("Create chain\n");
		}
		/**
		 * Construct a chain
		 */	
		public Chain (BaseCheck if_s,
					  BaseAction then_s,
					  BaseAction else_s)
		{
			if_stmt = if_s;
			else_stmt = else_s;
			then_stmt = then_s;
		}

		/**
		 * Handle activation. In this case, we call the check,
		 * see if it changed.
		 */
		public void Activate()
		{
			stdout.printf("Activate\n");
			BaseCheck.StateType state = if_stmt.check();
			// If no change, do nothing.
			if(state == BaseCheck.StateType.NO_CHANGE)
				return;
			if(state == BaseCheck.StateType.TRUE)
			{
				// Then statement.
				if(then_stmt != null)
					then_stmt.Activate();
				if(else_stmt != null)
					else_stmt.Deactivate();
			}else{
				// Else Statement.
				if(else_stmt != null)
					else_stmt.Activate();
				if(then_stmt != null)
					then_stmt.Deactivate();
			}
		}

		/**
		 * If we get deactivated, propagate this to the children.
		 */
		public void Deactivate()
		{
			// Deactivate both.
			if(then_stmt != null)
				then_stmt.Deactivate();
			if(else_stmt != null)
				else_stmt.Deactivate();
		}

		/**
		 * Generate dot file for this element.
		 * Diamond square with a yes and a no out arrow.
		 */
		public void output_dot(FileStream fp)
		{
			if(if_stmt != null)
			{
				string dot_desc = if_stmt.get_dot_description();
				fp.printf("%s [label=\"%s\\n(%s)\", shape=diamond]\n", 
								this.get_name(),
								this.get_name(),
								dot_desc);
			} else {
				fp.printf("%s [label=\"%s\", shape=diamond]\n", 
								this.get_name(),
								this.get_name());
			}
			if(then_stmt != null)
			{
				fp.printf("%s -> %s [label=\"Yes\"]\n", this.get_name(),
				(then_stmt as Gtk.Buildable).get_name());
				then_stmt.output_dot(fp);
			}
			if (else_stmt != null)
			{
				fp.printf("%s -> %s [label=\"No\"]\n", this.get_name(),
				(else_stmt as Gtk.Buildable).get_name());
				else_stmt.output_dot(fp);
			}
		}
	}

}

