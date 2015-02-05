using System;

namespace StockApp
{
   public class StockInfo
   {
      public string id { get; set; }
      public string t { get; set; }
      public string e { get; set; }
      public string l { get; set; }
      public string l_fix { get; set; }
      public string l_cur { get; set; }
      public string s { get; set; }
      public string ltt { get; set; }
      public string lt { get; set; }
      public string lt_dts { get; set; }
      public string c { get; set; }
      public string c_fix { get; set; }
      public string cp { get; set; }
      public string cp_fix { get; set; }
      public string ccol { get; set; }
      public string pcls_fix { get; set; }

      public StockInfo() { }

      /*
      public StockInfo (string id, string name, string ul1, string lastPrice, string ul2, string ul3, string ul4,
         string ul5, string ul6, string ul7, string change, string ul8, string changePercentage, string ul9, string ul10, string ul11)
      {
         _name = name;
         _lastPrice = lastPrice;
         _change = change;
         _changePercentage = changePercentage;
      }
*/
      public string EncodeToSend()
      {
         string to_return = "";
         to_return += (char)t.Length;
         to_return += t;
         to_return += (char)l.Length;
         to_return += l;
         to_return += (char)c.Length;
         to_return += c;
         to_return += (char)cp.Length;
         to_return += cp;

         return to_return;
      }
   }
}

