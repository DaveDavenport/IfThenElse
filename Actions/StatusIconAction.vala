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
	public class StatusIconAction : BaseAction, Base
	{
		private bool active = false;
		private Gtk.StatusIcon status_icon = new Gtk.StatusIcon();

		/**
		 * Set icon from icon_name on status_icon.
		 */
		public string icon_name {
			set {
				status_icon.set_from_icon_name(value);
				status_icon.set_visible(active);
			}
		}

		/**
		 * Set icon from stock on status_icon.
		 */
		public string stock {
			set {
				status_icon.set_from_stock(value);
				status_icon.set_visible(active);
			}
		}

		construct{
			stdout.printf("Deactivate\n");
			status_icon.set_visible(false);
		}

		~StatusIconAction()
		{
			stdout.printf("Destroy StatusIconAction\n");
			status_icon = null;
		}

		public StatusIconAction ()
		{
		}
		

		public void Activate()
		{
			active = true;
			stdout.printf("StatusIcon: Activate\n");
			status_icon.set_visible(active);
		}

		public void Deactivate()
		{
			active = false;
			stdout.printf("StatusIcon: Deactivate\n");
			status_icon.set_visible(active);
		}
	}
}


