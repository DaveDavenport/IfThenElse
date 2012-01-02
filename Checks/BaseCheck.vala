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
		private BaseAction? _else_action = null;
		private BaseAction? _then_action = null;
		public BaseAction?  else_action { 
				get { 
					return _else_action;
				}
				set {
					_else_action = value;
					(_else_action as Base).parent = this;
				}
		}
		public BaseAction?  then_action {
				get { 
					return _then_action;
				}
				set {
					_then_action = value;
					(_then_action as Base).parent = this;
				}
		}

		public enum StateType {
			NO_CHANGE,
			TRUE,
			FALSE
		}
		public abstract StateType check();
		public abstract string get_dot_description();




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
				if(_then_action != null)
					_then_action.Activate();
				if(_else_action != null)
					_else_action.Deactivate();
			}else{
				// Else Statement.
				if(_else_action != null)
					_else_action.Activate();
				if(_then_action != null)
					_then_action.Deactivate();
			}
		}

		/**
		 * If we get deactivated, propagate this to the children.
		 */
		public void Deactivate()
		{
			// Deactivate both.
			if(_then_action != null)
				_then_action.Deactivate();
			if(_else_action != null)
				_else_action.Deactivate();
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
			if(_then_action != null)
			{
				fp.printf("%s -> %s [label=\"Yes\"]\n", this.name,
						_then_action.name);
				_then_action.output_dot(fp);
			}
			if (_else_action != null)
			{
				fp.printf("%s -> %s [label=\"No\"]\n", this.name,
						_else_action.name);
				_else_action.output_dot(fp);
			}
		}
	}
}
