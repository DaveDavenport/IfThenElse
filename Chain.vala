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
		private BaseTrigger? trigger_stmtm = null;
		
		// Default is the true check.
		private BaseCheck    if_stmt 	  = new TrueCheck();
		
		// Then/Else actions.
		private BaseAction?  else_stmt 	  = null;
		private BaseAction?  then_stmt 	  = null;
		
		/**
		 * GtkBuilder function.
		 */
		public void add_child (Gtk.Builder builder, GLib.Object child, string? type)
		{
			if(type == null) return;
			stdout.printf("Adding to chain: %s\n", type);
			if(type == "trigger") {
				trigger_stmtm = child as BaseTrigger;
				trigger_stmtm.action = this;
			}else if (type == "if") {
				if_stmt = child as BaseCheck;
			}else if (type == "else") {
				else_stmt = child as BaseAction;
			}else if (type == "then") {
				then_stmt = child as BaseAction;
			}
		}
		/**
		 * Construct a chain
		 */	
		public Chain (BaseTrigger? trigger,
					  BaseCheck if_s,
					  BaseAction then_s,
					  BaseAction else_s)
		{
			trigger_stmtm = trigger;
			if_stmt = if_s;
			else_stmt = else_s;
			then_stmt = then_s;
			if(trigger != null) {
				trigger.action = this;
			}
		}
		
		/**
		 * Handle activation. In this case, we call the check,
		 * see if it changed.
		 */
		public void Activate()
		{
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
		 *  Not used here 
		 */
		public void Deactivate()
		{
			// Deactivate both.
			if(then_stmt != null)
				then_stmt.Deactivate();
			if(else_stmt != null)
				else_stmt.Deactivate();
		}
	}
}
	
