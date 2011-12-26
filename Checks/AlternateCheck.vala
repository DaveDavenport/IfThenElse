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
/****************************************
 * DEBUG CODE. No usefull functionality
 ****************************************/
namespace IfThenElse
{
	/**
	 * This check class alternates between true/false. 
	 * This is usefull purely for testing.
	 */
	public class AlternateCheck : BaseCheck, Base
	{
		public bool state = false;
		
		/**
		 * Constructor
		 **/
		public AlternateCheck()
		{
			
		}
		/*
		 * Check function.
		 */
		public BaseCheck.StateType check()
		{
			state = !state;
			return state?BaseCheck.StateType.TRUE:BaseCheck.StateType.FALSE;
		}
		
	}

}
