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
	public abstract class BaseCheck: BaseAction,Base
	{
		// Then/Else actions.
		private BaseAction?  else_stmt 	  = null;
		private BaseAction?  then_stmt 	  = null;

		public enum StateType {
			NO_CHANGE,
			TRUE,
			FALSE
		}
		public abstract StateType check();
		public abstract string get_dot_description();



		/**
		 */
		public void add_child (GLib.Object child,
								string? type)
		{
			if(type == null) return;
			stdout.printf("Adding to chain: %s\n", type);
			if (type == "else") {
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
		 * Handle activation. In this case, we call the check,
		 * see if it changed.
		 */
		public void Activate()
		{
			stdout.printf("Activate\n");
			BaseCheck.StateType state = this.check();
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
			string dot_desc = this.get_dot_description();
			fp.printf("%s [label=\"%s\\n(%s)\", shape=diamond]\n", 
					this.name,
					this.name,
								dot_desc);
			if(then_stmt != null)
			{
				fp.printf("%s -> %s [label=\"Yes\"]\n", this.name,
						then_stmt.name);
				then_stmt.output_dot(fp);
			}
			if (else_stmt != null)
			{
				fp.printf("%s -> %s [label=\"No\"]\n", this.name,
						else_stmt.name);
				else_stmt.output_dot(fp);
			}
		}
	}
}
