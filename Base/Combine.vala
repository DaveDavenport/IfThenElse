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
	 * If one or more inputs activates, it activates it child.
	 *
	 * This is basically an OR statement.
	 * This is the only nodet that can be child to multiple other nodes.
	 */
	public class MultiCombine : BaseAction, Base
	{
		private BaseAction _action = null;
		public BaseAction action { 
			get {
				return _action;
			}
			set {
				if(_action != null) GLib.error("%s: action is allready set", this.name);
				_action = value;
				(_action).parent = this;
			}
		}

		// We allow multiple parents.
		private List <unowned Base> parents;
		public override unowned Base? parent {
			set{
				parents.append(value as BaseAction);
			}
			get {
				if(parents.length() > 0) return parents.data;
				return null;
			}
		}

		/**
		 * Activate()
		 * 
		 * Propagate this to the children.
		 */
		public void Activate()
		{
			action.Activate();
		}

		/**
		 * Deactivate()
		 * 
		 * Propagate this to the children.
		 */
		public void Deactivate()
		{
			action.Deactivate();
		}
	}
}
