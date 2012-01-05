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
	public class ClockTrigger : BaseTrigger
	{
		private uint handler = 0;
		private int _hour = 8;
		private int _minute = 30;

		/// Accessor to hour.  Valid range is 0-23.
		public int hour {
			get{
				return _hour;
			}
			set{
				if(value >= 24 || value < 0) {
					GLib.error("Invalid hour given: %i", value);
				}
				_hour = value;
			}
		}
		/// Accessor to minute.  Valid range is 0-59.
		public int minute {
			get{
				return _minute;
			}
			set{
				if(value >= 60 || value < 0) {
					GLib.error("Invalid minute given: %i", value);
				}
				_minute = value;
			}
		}
		
		~ClockTrigger()
		{
			stop_timer();
		}
		
		public override void enable_trigger()
		{
			start_timer();
		}
		public override void disable_trigger()
		{
			stop_timer();
		}

		public override void output_dot(FileStream fp)
		{
			fp.printf("\"%s\" [label=\"%s\\nTimeout Trigger: %02i:%02i\", shape=oval]\n", 
						this.name,
						this.name,
						this.hour, this.minute);
			if(this.action != null) {
				fp.printf("\"%s\" -> \"%s\"\n", this.name, action.name);
				this.action.output_dot(fp);
			}
		}
		// TIMER CODE
		private void restart_timer()
		{
			stop_timer();
			start_timer();
		}
		private void stop_timer()
		{
			// Remove old timeout.
			if(handler > 0){
				GLib.Source.remove(handler);
				handler = 0;
			}
		}
		private void start_timer()
		{
			if(handler > 0) {
				GLib.warning("Trying to start an allready started time");
				return;
			}
			time_t t = time_t();
			Time now = GLib.Time.local(t);
	
			int remaining_time = 60*(hour*60+minute)-(now.hour*60*60+now.minute*60+now.second);

			// Next day? add 24 hours
			if(remaining_time <= 0) {
				// time has past, so next day.
				remaining_time+=24*60*60;
			}
			stdout.printf("Remaining seconds: %i\n", remaining_time);

			handler = GLib.Timeout.add_seconds(remaining_time, timer_callback);

		}
		/**
		 * Timer callbacks. 
		 * Restarts the timer once done.
		 */
		private bool timer_callback()
		{
			this.fire();
			restart_timer();
			return false;
		}
	}
}
