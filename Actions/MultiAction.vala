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
 
using GLib;
namespace IfThenElse
{
	/**
	 * Allow you to activate multiple branches from the same input.
	 *
	 * If you want to trigger Action1 and Action2 by one Trigger.
	 * {{{
	 * [Trigger]
	 * ....
	 * action=Multi
	 *
	 * [Multi]
	 * action=Action1;Action2
	 * }}}
	 */
	public class MultiAction : BaseAction, Base
	{
		private List <BaseAction> actions;
		public BaseAction action {
			set{
				actions.append(value as BaseAction);
				(value as Base).parent = this;
			}
		}

		/**
		 * Activate()
		 * 
		 * Propagate this to the children.
		 */
		public void Activate()
		{
			foreach(BaseAction action in actions)
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
			stdout.printf("%s: Deactivate\n", this.name);
			foreach(BaseAction action in actions)
			{
				action.Deactivate();
			}
		}
		
		
		public void output_dot(FileStream fp)
		{
			fp.printf("\"%s\" [label=\"%s\", shape=oval]\n", 
					this.name,
					this.name);
			foreach(unowned BaseAction action in actions)
			{
				fp.printf("\"%s\" -> \"%s\"\n", this.name, 
						action.name);
				action.output_dot(fp);
			}
		}
	}
}
