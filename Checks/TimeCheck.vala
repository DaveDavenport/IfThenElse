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
	 * TimeChecks: After a certain time fire one branch, before the time fire 
	 * the other branch.
	 *
	 * =Example=
	 *
	 * When Action1 should be fired after the set time, Action2 before the set time.
	 * {{{
	 * [InitTrigger]
	 * type=TimeCheck
	 * hour=6
	 * minute=30
	 * if-action=Action1
	 * else-action=Action2
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
			if((now.hour == hour && now.minute >= minute) || 
					(now.hour > hour))
			{
				if(prev_state && !init) return StateType.NO_CHANGE;
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
			return "Now >= %02u:%02u".printf(hour, minute);
		}
	}
}
