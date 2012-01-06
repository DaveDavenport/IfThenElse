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
	 * A timer trigger: Fire at a certain interval 
	 *
	 * This trigger fires at a certai interval. 
	 *
	 * The timer trigger supports being started and stopped and can be placed
	 * anywhere in the chain.
	 *
	 * =Example=
	 *
	 * So if you want a certain branch (MainBranch) to fire each 5 seconds 
	 * Add an element like:
	 * {{{
	 * [TimerTrigger]
	 * type=TimerTrigger
	 * timeout=5 
	 * action=MainBranch
	 * }}}
	 *
	 * To fire at a certain time use a {@link ClockTrigger}
	 *
	 * @see ClockTrigger
	 */
	public class TimerTrigger : BaseTrigger
	{
		private uint handler = 0;
		private uint _timeout = 5;

		/**
		 * The interval at witch this trigger should fire in seconds.
		 *
		 *@default 5
		 */
		public uint timeout {
			get{
				return _timeout;
			}
			set{
				if(value == 0) {
					GLib.error("A timeout cannot be 0"); 
				}
				_timeout = value;
				if(handler > 0) {
					GLib.Source.remove(handler);
					handler = GLib.Timeout.add_seconds(_timeout, timer_callback);
				}
			}
		}
		/**
		 * Timer callback.
		 */
		private bool timer_callback()
		{
				GLib.debug("Timer fire\n");
				this.fire();
				return true;
		}
		/**
		 * Destructor
		 */
		~TimerTrigger()
		{
			disable_trigger();
		}
		
		public override void enable_trigger()
		{
			if(handler == 0) {
				handler = GLib.Timeout.add_seconds(timeout, timer_callback);
			}
		}
		public override void disable_trigger()
		{
			if(handler > 0) {
				GLib.Source.remove(handler);
			}
			handler = 0;
		}
		/**
		 * Generate dot code for this node.
		 *
		 * {@inheritDoc}
		 */		
		public override void output_dot(FileStream fp)
		{
			fp.printf("\"%s\" [label=\"%s\\nTimeout Trigger: %.2f seconds\", shape=oval]\n", 
						this.name,
						this.name,
						this.timeout);
			fp.printf("\"%s\" -> \"%s\"\n", this.name, action.name);
			this.action.output_dot(fp);
		}
	}
}
