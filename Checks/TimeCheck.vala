/**
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
	 * This check class alternates between true/false. 
	 * This is usefull purely for testing.
	 */
	public class TimeCheck : BaseCheck
	{
		public uint hour {get; set; default = 8;}
		public uint minute { get; set; default = 0;}
		public bool prev_state = false;
		
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
				if(prev_state) return StateType.NO_CHANGE;
				prev_state = true;
				return StateType.TRUE;
			}
			if(!prev_state) return StateType.NO_CHANGE;
			
			return StateType.FALSE;
		}

		public override string get_dot_description()
		{
			return "Now >= %02u:%02u".printf(hour, minute);
		}
	}
}
