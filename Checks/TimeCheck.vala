/*
 * Copyright 2011-2014  Martijn Koedam <qball@gmpclient.org>
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
	 * TimeChecks: After a certain time fire one branch, before the time fire
	 * the other branch.
     * A range can be specified.
	 *
	 * =Example=
	 *
	 * Action1 fires after the set time before end time, Action2 elsewhere.
	 * {{{
	 * [Between]
	 * type=TimeCheck
	 * hour=6
	 * minute=30
     * end_hour = 22
     * end_minute = 30
	 * then_action=Action1
	 * else_action=Action2
	 * }}}
	 */
	public class TimeCheck : BaseCheck
	{
		/**
		 * The hour, of the time.
		 */
		public uint hour		{get; set; default = 8;}
		/**
		 * The minute, of the time.
		 */
		public uint minute		{get; set; default = 0;}

		/**
		 * The hour, of the end time.
		 */
        public uint end_hour    {get; set; default = 0;}
		/**
		 * The minute, of the end time.
		 */
        public uint end_minute {get; set; default = 0;}
        /**
         * Repeat. (fire output on each trigger)
         */
        public bool repeat {get;set; default=false;}


		private bool prev_state = false;
		private bool init = true;

		// TimeCheck
		public TimeCheck()
		{
		}

		// Check timer.
		public override BaseCheck.StateType check()
		{
			time_t t = time_t();
			Time now = GLib.Time.local(t);

            uint m_now = now.hour*60+now.minute;
            uint m_start = hour*60+minute;
            uint m_end = end_hour*60+end_minute;

            if(m_now >= m_start && (m_end == 0 || m_now < m_end)) {
				if(prev_state && !(init || repeat)) return StateType.NO_CHANGE;
				init = false;
				prev_state = true;
				return StateType.TRUE;
			}
			if(!prev_state && !init) return StateType.NO_CHANGE;
			init = false;
			prev_state = false;
			return StateType.FALSE;
		}

		public override string get_dot_description()
		{
			return "%02u:%02u <=  now <= %02u:%02u".printf(hour, minute, end_hour, end_minute);
		}
	}
}
