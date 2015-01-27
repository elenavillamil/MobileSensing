////////////////////////////////////////////////////////////////////////////////
// Module: JSON.cs
//
// Author: Jarret Shook
//
// Versions:
//
// 14-Nov-14: Version 1.0: Created
//
////////////////////////////////////////////////////////////////////////////////

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web.Script.Serialization;
using System.IO;

////////////////////////////////////////////////////////////////////////////////

namespace JS
{
   class JSON<T>
   {
      public static string ToJSONString(T obj)
      {
         JavaScriptSerializer serializer = new JavaScriptSerializer();

         return serializer.Serialize(obj);
      }

      public static T Parse(string json)
      {
         JavaScriptSerializer serializer = new JavaScriptSerializer();

         T obj_ref = serializer.Deserialize<T>(json);

         return obj_ref;
      }
   }

} // end of namespace JS

////////////////////////////////////////////////////////////////////////////////
