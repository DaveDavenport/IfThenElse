using GLib;

namespace IfThenElse
{

	errordomain ParserError {
		NODE_CREATION,
			NODE_SET_PROPERTY
	}
	class Parser : GLib.Object
	{
		private GLib.HashTable<string, GLib.Object> objects = new HashTable<string, GLib.Object>(str_hash,str_equal);
		/**
		 * Constructor
		 */
		public Parser()
		{

		}
		/**
		 * Load classes from key file
		 */
		private void load_classes(string prefix, GLib.KeyFile kf) throws GLib.KeyFileError, ParserError
		{
			// Create all instances.
			foreach(string group in kf.get_groups())
			{
				var str_tp = kf.get_string(group, "type");
				stdout.printf("Creating object: %s\n", group);
				GLib.Type tp = GLib.Type.from_name("IfThenElse"+str_tp);
				if(tp == 0) {
					GLib.error("Failed to lookup type: %s for %s\n",str_tp, group);
				}
				if(objects.lookup(prefix+group) != null) {
					// Should never trigger on one file as groups are merged.
					throw new ParserError.NODE_CREATION("Node %s allready exists.", group);
				}
				GLib.Object object = GLib.Object.new(tp,null);
				object.set("name", prefix+group);
				objects.insert(prefix+group, object);
			}

			foreach(string group in kf.get_groups())
			{
				GLib.Object object = objects[prefix+group];
				string[] keys = null;
				try{
					keys = kf.get_keys(group);
				}catch(GLib.KeyFileError e) {
					GLib.error("Failed to parse keyfile: %s", e.message);
				}
				stdout.printf("=== %s ===\n", group);
				foreach(var prop in keys)
				{
					// Skip the "Type" field.
					if(prop == "type") continue;

					stdout.printf("Setting property: %s\n", prop);
					// Special type
					if(prop.length >= 5 && prop.substring(0,5) == "child")
					{
						string? key = null;
						if(prop.length > 5) {
							key = prop.substring(5, (long)prop.length-5);
						}
						string entry = kf.get_string(group, prop);
						stdout.printf("\tAdd child %s\n", entry);
						GLib.Object child_obj = objects[prefix+entry];
						if(child_obj == null) {
							throw new ParserError.NODE_SET_PROPERTY("Unknown node: %s", entry);
						}
						(object as BaseAction).add_child(child_obj, key);

						continue;
					}

					// Load property
					unowned ParamSpec? ps = object.get_class().find_property(prop);
					if(ps == null){
						throw new ParserError.NODE_SET_PROPERTY("Unknown property on object: %s::%s", 
								group,prop);
					} 
					// Property type is a string.
					if(ps.value_type == typeof(string)) {
						string temp = kf.get_string(group,prop);
						object.set(prop, temp);
					}
					// type is uint.
					else if(ps.value_type == typeof(uint)) {
						uint temp = (uint)kf.get_integer(group,prop);
						object.set(prop, temp);
					}
					// Type is int.
					else if(ps.value_type == typeof(int)) {
						int temp = kf.get_integer(group,prop);
						object.set(prop, temp);
					}
					// Type is boolean
					else if (ps.value_type == typeof(bool)) {
						bool temp = kf.get_boolean(group,prop);
						object.set(prop, temp);
					}else {
						throw new ParserError.NODE_SET_PROPERTY("Unknown property type: %s::%s(%s)", group,
								prop, ps.value_type.name());
					}
				}
			}
		}

		public bool add_from_file(string filename)  throws GLib.KeyFileError, GLib.FileError, ParserError
		{
			GLib.KeyFile kf = new GLib.KeyFile();
			if(kf.load_from_file(filename, GLib.KeyFileFlags.NONE))
			{
				string prefix = GLib.Path.get_basename(filename); 
				// Use filename as prefix.
				load_classes(prefix+"::",kf);
			}
			return true;
		}
		public List<unowned GLib.Object> get_objects()
		{
			return objects.get_values();
		}	

	}
}
