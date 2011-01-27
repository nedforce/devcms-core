// Formats date and time as "20-01-2000 17:00"
Date.prototype.toFormattedString = function(include_time)
{
   str = Date.padded2(this.getDate()) + "-" + Date.padded2(this.getMonth() + 1) + "-" + this.getFullYear();
   if (include_time) { str += " " + this.getHours() + ":" + this.getPaddedMinutes() }
   return str;
}