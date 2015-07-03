/*
 * Copyright 2011-2015  Martijn Koedam <qball@gmpclient.org>
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
	 * Singles: Only Activate/Deactivate once in a row. 
	 *
	 * =Example=
	 *
	 * Action (De)Activates only once in a row. 
	 * {{{
	 * [single]
	 * type=Single
     * action=Action
	 * }}}
	 */
	public class Single : BaseAction, Base
	{
        // Set to one if fired.
		private bool prev_state = false;

		private BaseAction _action = null;
		public BaseAction action { 
			get {
				return _action;
			}
			set {
				if(_action != null) GLib.error("%s: action is already set", this.name);
				_action = value;
				(_action).parent = this;
			}
		}

		// Single
		public Single() { }

        public void Activate(Base p) {
            if(!prev_state) {
                action.Activate(this);
            }
            prev_state = true;
        }

        public void Deactivate (Base p) {
            if(prev_state) {
                action.Deactivate(this);
            }
            prev_state = false;
        }
	}
}
