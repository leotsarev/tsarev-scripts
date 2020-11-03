<Query Kind="Program" />

void Main()
{
	// Write code to test your extensions here. Press F5 to compile and run.
}

public static class MyExtensions
{
	public static object FlattenOnce(this object o)
	{
		IDictionary<string, object> custom = new System.Dynamic.ExpandoObject();

		var props = o.GetType().GetProperties(BindingFlags.Public | BindingFlags.Instance)
		.Where(p => p.PropertyType != typeof(DateTime) && p.PropertyType != typeof(string));

		object GetProp(object doc, PropertyInfo prop)
		{
			try
			{
				return prop.GetValue(doc);
			}
			catch (Exception ex)
			{
				return ex.GetBaseException();  // Report error in output 
			}
		}

		void AddProps(PropertyInfo propToFlatten)
		{
			var childProps = propToFlatten.PropertyType.GetProperties(BindingFlags.Public | BindingFlags.Instance);

			var flat = GetProp(o, propToFlatten);

			foreach (var prop in childProps)
			{
				custom[propToFlatten.Name + "." + prop.Name] = GetProp(flat, prop);
			}
		}

		foreach (var prop in props)
		{
			AddProps(prop);
		}

		return custom;
	}
	
	public static IEnumerable<object> MaterializeFlattened<T>(this IQueryable<T> queryable) => queryable.ToList().Select(e => e.FlattenOnce());

}

// You can also define non-static classes, enums, etc.