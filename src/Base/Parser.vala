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
using GLib ;

namespace IfThenElse{
    errordomain ParserError {
        // Errors that occured during creation off a node.
        NODE_CREATION,
        // Errors that occured during the setting of a property.
        NODE_SET_PROPERTY
    }

    class Parser {
        // List with key, object. This to 'emulate' gtkbuilder.
        private GLib.HashTable<string, GLib.Object> objects =
            new HashTable<string, GLib.Object>(str_hash, str_equal) ;
        /**
         * Constructor
         */
        public Parser () {
        }

        /**
         * Deconstructor
         */
        ~Parser () {
            GLib.message ("Destroying parser") ;
        }

        /**
         * Load classes from key file
         */
        private void load_classes(string prefix, GLib.KeyFile kf)
        throws GLib.KeyFileError, ParserError {
            if( kf.has_group ("disable")){
                GLib.message ("Not loading file, disabled") ;
                return ;
            }
            // Create all instances.
            foreach( string group in kf.get_groups ()){
                var str_tp = kf.get_string (group, "type") ;
                GLib.message ("Creating object: %s", group) ;
                GLib.Type tp = GLib.Type.from_name ("IfThenElse" + str_tp) ;
                if( tp == 0 ){
                    GLib.error ("Failed to lookup type: %s for %s", str_tp, group) ;
                }
                if( objects.lookup (prefix + group) != null ){
                    // Should never trigger on one file as groups are merged.
                    throw new ParserError.NODE_CREATION ("Node %s allready exists.", group) ;
                }

                // Create the object.
                GLib.Object object = GLib.Object.new (tp, null) ;
                object.set ("name", prefix + group) ;
                objects.insert (prefix + group, object) ;
            }

            // Loading properties.
            foreach( string group in kf.get_groups ()){
                GLib.Object object = objects[prefix + group] ;
                string[]    keys = null ;
                try {
                    keys = kf.get_keys (group) ;
                } catch (GLib.KeyFileError e)
                {
                    GLib.error ("Failed to parse keyfile: %s", e.message) ;
                }
                GLib.message ("=== %s ===", group) ;
                foreach( var prop in keys ){
                    // Skip the "Type" field.
                    if( prop == "type" ){
                        continue ;
                    }

                    GLib.message ("Setting property: %s", prop) ;

                    // Load property
                    unowned ParamSpec ? ps = object.get_class ().find_property (prop) ;
                    if( ps == null ){
                        throw new ParserError.NODE_SET_PROPERTY ("Unknown property on object: %s::%s",
                                                                 group, prop) ;
                    }
                    // Property type is a string.
                    if( ps.value_type == typeof (string)){
                        string temp = kf.get_string (group, prop) ;
                        object.set (prop, temp) ;
                    }
                    // type is uint.
                    else if( ps.value_type == typeof (uint)){
                        uint temp = (uint) kf.get_integer (group, prop) ;
                        object.set (prop, temp) ;
                    }
                    // Type is int.
                    else if( ps.value_type == typeof (int)){
                        int temp = kf.get_integer (group, prop) ;
                        object.set (prop, temp) ;
                    }
                    // Type is boolean
                    else if( ps.value_type == typeof (bool)){
                        bool temp = kf.get_boolean (group, prop) ;
                        object.set (prop, temp) ;
                    } else if( ps.value_type == typeof (string[])){
                        string[] names = kf.get_string_list (group, prop) ;
                        object.set (prop, names) ;
                    }
                    // Type is BaseAction
                    else if( ps.value_type == typeof (BaseAction)){
                        string[] names = kf.get_string_list (group, prop) ;
                        foreach( string name in names ){
                            GLib.Object child_obj = objects[prefix + name] ;
                            if( child_obj == null ){
                                throw new ParserError.NODE_SET_PROPERTY ("Unknown node: %s", name) ;
                            }
                            object.set (prop, child_obj) ;
                        }
                    }
                    // Unknown type.
                    else {
                        throw new ParserError.NODE_SET_PROPERTY ("Unknown property type: %s::%s(%s)", group,
                                                                 prop, ps.value_type.name ()) ;
                    }
                }
            }
        }

        public bool add_from_file(string filename)  throws GLib.KeyFileError, GLib.FileError, ParserError {
            GLib.KeyFile kf = new GLib.KeyFile () ;
            if( kf.load_from_file (filename, GLib.KeyFileFlags.NONE)){
                string prefix = GLib.Path.get_basename (filename) ;
                // Use filename as prefix.
                load_classes (prefix + "::", kf) ;
            }
            return true ;
        }

        public List<unowned GLib.Object> get_objects() {
            return objects.get_values () ;
        }

    }
}
