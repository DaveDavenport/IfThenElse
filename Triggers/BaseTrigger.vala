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
 
namespace IfThenElse
{
	/**
	 * Abstract BaseTrigger class. All triggers should inherit from this.
	 */
	public abstract class BaseTrigger: BaseAction, Base
	{
		private BaseAction _action = null;
		// Make this unowned so we don't get circular dependency.
		public BaseAction action {
			get {
				return _action;
			}
			set {
				_action = value;
				(_action as Base).parent = this;
			}
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
			stdout.printf("%s: Deactivate\n", this.name);
			if(_action != null) {
				_action.Deactivate();
			}
			disable_trigger();
		}
		/**
		 * Activate the child
		 */
		public void fire()
		{
			stdout.printf("Fire trigger: %p\n", _action);
			if(_action != null) {
				_action.Activate();
			}
		}
		
		public virtual void output_dot(FileStream fp)
		{
			fp.printf("\"%s\" [label=\"%s\", shape=oval]\n", 
						this.name,
						this.name);
			fp.printf("\"%s\" -> \"%s\"\n", this.name, _action.name);
			this._action.output_dot(fp);
		}
	}
}
