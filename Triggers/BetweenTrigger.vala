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
     * Between Trigger: A trigger that enables the child action when within a time-range.
     *
     * Activates the child chain based on the time.
     * Use this as parent to enable a certain if-then-else tree between a certain time.
     *
     * * Note: this fires also on activate/disable. so output is set in correct state.
     *
	 * =Example=
	 *
	 * Between 6.30 and 22.30 do every 5 seconds action1.
	 * {{{
	 * [Between]
	 * type=BetweenTrigger
	 * hour=6
	 * minute=30
     * end_hour = 22
     * end_minute = 30
	 * action=timeout
     *
     * [timeout]
     * type=TimerTrigger
     * timeout=5
     * action=action1
	 * }}}
	 */
	public class BetweenTrigger : BaseTrigger
	{
		private uint handler = 0;

		private int _hour = 8;
		private int _minute = 30;
		private int _end_hour = 22;
		private int _end_minute = 30;

		/**
		 * The hour.
		 * Valid range is 0-23.
		 */
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
		/**
		 * The minute.
		 * Valid range is 0-59.
		 */
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
		/**
		 * The end hour.
		 * Valid range is 0-23.
		 */
		public int end_hour {
			get{
				return _end_hour;
			}
			set{
				if(value >= 24 || value < 0) {
					GLib.error("Invalid end_hour given: %i", value);
				}
				_end_hour = value;
			}
		}
		/**
		 * The minute.
		 * Valid range is 0-59.
		 */
		public int end_minute {
			get{
				return _end_minute;
			}
			set{
				if(value >= 60 || value < 0) {
					GLib.error("Invalid minute given: %i", value);
				}
				_end_minute = value;
			}
		}

		~BetweenTrigger()
		{
			stop_timer();
		}

		public override void enable_trigger()
		{
            fire();
			start_timer();
		}
		public override void disable_trigger()
		{
            fire();
			stop_timer();
		}
		/**
		 *
		 */
		public override void output_dot(FileStream fp)
		{
            if(_end_hour == 0 && _end_minute == 0) {
                fp.printf("\"%s\" [label=\"%s\\nTimeout Trigger: %02i:%02i-%02i:%02i\", shape=oval]\n",
                        this.name,
                        this.get_public_name(),
                        this.hour, this.minute,
                        this.end_hour, this.end_minute
                        );

            }else{
                fp.printf("\"%s\" [label=\"%s\\nTimeout Trigger: %02i:%02i\", shape=oval]\n",
                        this.name,
                        this.get_public_name(),
                        this.hour, this.minute);
            }
			if(this.action != null) {
				fp.printf("\"%s\" -> \"%s\"\n", this.name, action.name);
				this.action.output_dot(fp);
			}
		}
		/**
		 * restart the timer.
		 */
		private void restart_timer()
		{
			stop_timer();
			start_timer();
		}

		/**
		 * stop the active timer.
		 */
		private void stop_timer()
		{
			// Remove old timeout.
			if(handler > 0){
				GLib.Source.remove(handler);
				handler = 0;
			}
		}

		/**
		 * start the timer to fire at the set time.
		 */
		private void start_timer()
		{
			if(handler > 0) {
				GLib.warning("Trying to start an allready started time");
				return;
			}
			time_t t = time_t();
			Time now = GLib.Time.local(t);


            int m_now = 60*now.hour+now.minute;
            int m_start = 60*hour+minute;
            int m_end = 60*end_hour+end_minute;

            int remaining_time = 0;

            if(m_start > m_end) {
                GLib.warning("End time should be after start time, if negate action is needed, swap then-else_action" );
                return;
            }
            if(m_now >= m_start &&  m_now < m_end) {
                remaining_time = 60*(end_hour*60+end_minute)-(now.hour*60*60+now.minute*60+now.second);
            }else{
                remaining_time = 60*(hour*60+minute)-(now.hour*60*60+now.minute*60+now.second);
            }

			// Next day? add 24 hours
			if(remaining_time <= 0) {
				// time has past, so next day.
				remaining_time+=24*60*60;
			}
			GLib.message("Remaining seconds: %i\n", remaining_time);

			handler = GLib.Timeout.add_seconds(remaining_time, timer_callback);

		}
		/**
		 * Timer callback.
		 *
		 * Fire the trigger, and
		 * restarts the timer.
		 */
		private bool timer_callback()
		{
            fire();
			restart_timer();
			return false;
		}
        public override void fire()
        {
			time_t t = time_t();
			Time now = GLib.Time.local(t);


            int m_now = 60*now.hour+now.minute;
            int m_start = 60*hour+minute;
            int m_end = 60*end_hour+end_minute;
            if( m_now >= m_start && m_now < m_end) {
                this._action.Activate(this);
            }else{
                this._action.Deactivate(this);
            }
        }
	}
}
