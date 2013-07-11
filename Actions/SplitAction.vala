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
	 * Split the activate and Deactivate signal into 2 branches.
	 *
     * So then_action = input.
     * else_action = !input.
     *
     * basic if/then block.
     *
     * =Example=
     *
     * Invert the input,  call Action1 when Split is deactivated.
	 * {{{
	 * [Split]
     * type=SplitAction
	 * else_action=Action1
	 * }}}
	 */
	public class SplitAction : BaseAction, Base
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

		/**
		 * Activate()
		 *
		 * Propagate this to the children.
		 */
		public void Activate(Base p)
		{
            if(_then_action != null) {
               _then_action.Activate(this);
            }
            if(_else_action != null) {
               _else_action.Deactivate(this);
            }
		}

		/**
		 * Deactivate()
		 *
		 * Propagate this to the children.
		 */
		public void Deactivate(Base p)
		{
            if(_then_action != null) {
               _then_action.Deactivate(this);
            }
            if(_else_action != null) {
               _else_action.Activate(this);
            }
		}


		public void output_dot(FileStream fp)
		{
			fp.printf("\"%s\" [label=\"%s\", shape=diamond]\n",
					this.name,
					this.get_public_name());
			if(_else_action != null)
            {
                fp.printf("\"%s\" -> \"%s\"\n", this.name,
						_else_action.name);
				_else_action.output_dot(fp);
			}
			if(_then_action != null)
            {
                fp.printf("\"%s\" -> \"%s\"\n", this.name,
						_then_action.name);
				_then_action.output_dot(fp);
			}
		}
	}
}
