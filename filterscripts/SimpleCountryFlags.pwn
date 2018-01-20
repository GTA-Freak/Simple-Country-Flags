/*
	[FilterScript] Simple Country Flags
	
	Author:		GTA-Freak
	URL:		https://github.com/GTA-Freak/Simple-Country-Flags
	Desc:		Shows the flag of a country to all players
	Version:	Version 5
	License:	Creative Commons BY-SA, see https://creativecommons.org/licenses/by-sa/3.0/
	
	Credits:
	* SA-MP Team
	* Creater of zcmd - Zeex (http://forum.sa-mp.com/showthread.php?t=91354)
*/

// Includes
#include <a_samp>
#include <zcmd>

// Defines
/*
	This is the ID of the dialog where admins can choose country from.
	Make sure this dialog id is available. Otherwise change the id here.
*/
#define COUNTRY_FLAGS_DIALOG_ID		7337
#define COUNTRY_FLAGS_DISPLAY_TIME	1000 * 5	// Flag will be shown for 5 seconds
/*
	If you want to play a sound when showing the flag, please specify your desired sound-id
	here and comment out this line. Otheriwse, skip this part.
*/
//#define COUNTRY_FLAGS_SOUND_ID	1058

// Global variables
new Text:TDFlag, Country_Flags_Shown = 0, Country_Flags_Timer;

enum FDCountry
{
	Name[25],
	String[256]
}
new CountryNames[][FDCountry] =
{
	{"Afghanistan","~l~]]]~r~]]]~g~]]]~n~~l~]]]~r~]]]~g~]]]~n~~l~]]]~r~]]]~g~]]]~n~~l~]]]~r~]]]~g~]]]~n~~l~]]]~r~]]]~g~]]]~n~~l~]]]~r~]]]~g~]]]"},
	{"Algeria","~g~]]]]~w~]]]]~n~~g~]]]]~w~]]]]~n~~g~]]]]~w~]]]]~n~~g~]]]]~w~]]]]~n~~g~]]]]~w~]]]]~n~~g~]]]]~w~]]]]"},
	{"Andorra","~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]"},
	{"Angola","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~l~]]]]]]]]]~n~~l~]]]]]]]]]~n~~l~]]]]]]]]]"},
	{"Argentina","~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]"},
	{"Armenia","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]"},
	{"Aruba","~b~~h~~h~~h~]~r~~h~]~b~~h~~h~~h~]]]]]]]~n~~r~~h~]]]~b~~h~~h~~h~]]]]]]~n~~b~~h~~h~~h~]~r~~h~]~b~~h~~h~~h~]]]]]]]~n~~y~~h~]]]]]]]]]~n~~b~~h~~h~~h~]]]]]]]]]~n~~y~~h~]]]]]]]]]"},
	{"Austria","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Azerbaijan","~b~~h~]]]]]]]]]~n~~b~~h~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~g~~h~]]]]]]]]]~n~~g~~h~]]]]]]]]]"},
	{"Bahamas","~l~]~b~~h~~h~]]]]]]]]~n~~l~]]~b~~h~~h~]]]]]]]~n~~l~]]]~y~]]]]]]~n~~l~]]]~y~]]]]]]~n~~l~]]~b~~h~~h~]]]]]]]~n~~l~]~b~~h~~h~]]]]]]]]"},
	{"Bahrain","~w~]]]]~r~]]]]]~n~~w~]]]~r~]]]]]]~n~~w~]]]]~r~]]]]]~n~~w~]]]~r~]]]]]]~n~~w~]]]]~r~]]]]]~n~~w~]]]~r~]]]]]]~n~~w~]]]]~r~]]]]]"},
	{"Barbados","~b~]]]~y~]]]~b~]]]~n~~b~]]]~y~]]]~b~]]]~n~~b~]]]~y~]]]~b~]]]~n~~b~]]]~y~]]]~b~]]]~n~~b~]]]~y~]]]~b~]]]~n~~b~]]]~y~]]]~b~]]]"},
	{"Belarus","~r~~h~]~w~]~r~]]]]]]]~n~~w~]~r~~h~]~r~]]]]]]]~n~~r~~h~]~w~]~r~]]]]]]]~n~~w~]~r~~h~]~r~]]]]]]~r~]~n~~r~~h~]~w~]~g~]]]]]]]~n~~w~]~r~~h~]~g~]]]]]]]"},
	{"Belgium","~l~]]]~y~]]]~r~]]]~n~~l~]]]~y~]]]~r~]]]~n~~l~]]]~y~]]]~r~]]]~n~~l~]]]~y~]]]~r~]]]~n~~l~]]]~y~]]]~r~]]]"},
	{"Benin","~g~]]]]~y~]]]]]~n~~g~]]]]~y~]]]]]~n~~g~]]]]~y~]]]]]~n~~g~]]]]~r~]]]]]~n~~g~]]]]~r~]]]]]~n~~g~]]]]~r~]]]]]"},
	{"Bolivia","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"Bosnia and Herzegovina","~b~]]~w~]~y~]]]]~b~]]~n~~b~]]]~w~]~y~]]]~b~]]~n~~b~]]]]~w~]~y~]]~b~]]~n~~b~]]]]]~w~]~y~]~b~]]"},
	{"Botswana","~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~l~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]"},
	{"Brazil","~g~~h~]]]]~y~~h~]~g~~h~]]]]~n~~g~~h~]]]~y~~h~]~b~]~y~~h~]~g~~h~]]]~n~~g~~h~]]~y~~h~]~w~]~w~]~b~]~y~~h~]~g~~h~]]~n~~g~~h~]]~y~~h~]~b~]~b~]~w~]~y~~h~]~g~~h~]]~n~~g~~h~]]]~y~~h~]~b~]~y~~h~]~g~~h~]]]~n~~g~~h~]]]]~y~~h~]~g~~h~]]]]"},
	{"Bulgaria","~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Cameroon","~g~]]]~r~]]]~y~]]]~n~~g~]]]~r~]]]~y~]]]~n~~g~]]]~r~]~y~]~r~]~y~]]]~n~~g~]]]~r~]~y~]~r~]~y~]]]~n~~g~]]]~r~]]]~y~]]]~n~~g~]]]~r~]]]~y~]]]"},
	{"Cameroon","~g~~h~]]]~r~~h~]]]~y~~h~]]]~n~~g~~h~]]]~r~~h~]]]~y~~h~]]]~n~~g~~h~]]]~r~~h~]~y~~h~]~r~~h~]~y~~h~]]]~n~~g~~h~]]]~y~~h~]]]]]]~n~~g~~h~]]]~r~~h~]~y~~h~]~r~~h~]~y~~h~]]]~n~~g~~h~]]]~r~~h~]]]~y~~h~]]]"},
	{"Canada","~r~]]]~w~]]]]]~r~]]]~n~~r~]]]~w~]]~r~]~w~]]~r~]]]~n~~r~]]]~w~]~r~]]]~w~]~r~]]]~n~~r~]]]~w~]]~r~]~w~]]~r~]]]~n~~r~]]]~w~]]~r~]~w~]]~r~]]]~n~~r~]]]~w~]]]]]~r~]]]"},
	{"Chad","~b~]]]~y~]]]~r~~h~]]]~n~~b~]]]~y~]]]~r~~h~]]]~n~~b~]]]~y~]]]~r~~h~]]]~n~~b~]]]~y~]]]~r~~h~]]]~n~~b~]]]~y~]]]~r~~h~]]]~n~~b~]]]~y~]]]~r~~h~]]]"},
	{"China","~r~~h~]]]~y~~h~]~r~~h~]]]]]~n~~r~~h~]~y~~h~]~r~~h~]]~y~~h~]~r~~h~]]]]~n~~y~~h~]]]~r~~h~]]]]]]~n~~r~~h~]~y~~h~]~r~~h~]]~y~~h~]~r~~h~]]]]~n~~r~~h~]]]~y~~h~]~r~~h~]]]]]~n~~r~~h~]]]]]]]]]"},
	{"Congo","~b~~h~~h~]~y~~h~]~b~~h~~h~]]]~y~]~r~]]~y~]~n~~y~~h~]]]~b~~h~~h~]~y~]~r~]]~y~]~b~~h~~h~]~n~~b~~h~~h~]~y~~h~]~b~~h~~h~]~y~]~r~]]~y~]~b~~h~~h~]]~n~~b~~h~~h~]]~y~]~r~]]~y~]~b~~h~~h~]]]~n~~b~~h~~h~]~y~]~r~]]~y~]~b~~h~~h~]]]]~n~~y~]~r~]]~y~]~b~~h~~h~]]]]]"},
	{"Costa Rica","~b~]]]]]]]]]~n~~w~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]"},
	{"Croatia","~r~~h~~h~]]]]]]]]]~n~~r~~h~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]"},
	{"Cuba","~r~]]~b~]]]]]]]~n~~r~]]]~w~]]]]]]~n~~r~]~w~]~r~]]~b~]]]]]~n~~r~]]]]~w~]]]]]~n~~r~]]]~b~]]]]]]~n~~r~]]~w~]]]]]]]"},
	{"Czech","~b~]~w~]]]]]]]]~n~~b~]]~w~]]]]]]]~n~~b~]]]~w~]]]]]]~n~~b~]]]~r~]]]]]]~n~~b~]]~r~]]]]]]]~n~~b~]~r~]]]]]]]]"},
	{"Denmark","~r~]]]~w~]]~r~]]]]]~n~~r~]]]~w~]]~r~]]]]]~n~~w~]]]]]]]]]]~n~~r~]]]~w~]]~r~]]]]]~n~~r~]]]~w~]]~r~]]]]]"},
	{"Egypt","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~l~]]]]]]]]]~n~~l~]]]]]]]]]"},
	{"England","~w~]]]]~r~]~w~]]]]~n~~w~]]]]~r~]~w~]]]]~n~~r~]]]]]]]]]~n~~w~]]]]~r~]~w~]]]]~n~~w~]]]]~r~]~w~]]]]"},
	{"Equatorial Guinea","~b~~h~]~g~~h~]]]]]]]]~n~~b~~h~]]~g~~h~]]]]]]]~n~~b~~h~]]]~w~]]]]]]~n~~b~~h~]]]~w~]]]]]]~n~~b~~h~]]~r~]]]]]]]~n~~b~~h~]~r~]]]]]]]]"},
	{"Estonia","~b~~h~]]]]]]]]]~n~~b~~h~]]]]]]]]]~n~~l~]]]]]]]]]~n~~l~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]"},
	{"Ethiopia","~g~]]]]]]]]]~n~~g~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Finland","~w~]]]~b~]]~w~]]]]]~n~~w~]]]~b~]]~w~]]]]]~n~~b~]]]]]]]]]]~n~~w~]]]~b~]]~w~]]]]]~n~~w~]]]~b~]]~w~]]]]]"},
	{"France","~b~]]]~w~]]]~r~]]]~n~~b~]]]~w~]]]~r~]]]~n~~b~]]]~w~]]]~r~]]]~n~~b~]]]~w~]]]~r~]]]~n~~b~]]]~w~]]]~r~]]]"},
	{"Gabon","~g~]]]]]]]]]~n~~g~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~b~~h~]]]]]]]]]~n~~b~~h~]]]]]]]]]"},
	{"Georgia","~w~]~r~]~w~]]~r~]~w~]]~r~]~w~]~n~~w~]]]]~r~]~w~]]]]~n~~r~]]]]]]]]]~n~~w~]]]]~r~]~w~]]]]~n~~w~]~r~]~w~]]~r~]~w~]]~r~]~w~]"},
	{"Germany","~l~]]]]]]]]]~n~~l~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]"},
	{"Greece","~b~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]"},
	{"Guinea","~r~]]]~y~]]]~g~]]]~n~~r~]]]~y~]]]~g~]]]~n~~r~]]]~y~]]]~g~]]]~n~~r~]]]~y~]]]~g~]]]~n~~r~]]]~y~]]]~g~]]]"},
	{"Honduras","~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]"},
	{"Hungary","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"India","~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"Indonesia","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]"},
	{"Iran","~g~~h~]]]]]]]]]~n~~g~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~r~~h~]]]]]]]]]~n~~r~~h~]]]]]]]]]"},
	{"Iraq","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~l~]]]]]]]]]~n~~l~]]]]]]]]]"},
	{"Ireland","~g~]]]~w~]]]~y~]]]~n~~g~]]]~w~]]]~y~]]]~n~~g~]]]~w~]]]~y~]]]~n~~g~]]]~w~]]]~y~]]]~n~~g~]]]~w~]]]~y~]]]"},
	{"Israel","~b~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]~b~]~w~]]]]~n~~w~]]]~b~]]]~w~]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]"},
	{"Italy","~g~~h~]]]~w~]]]~r~]]]~n~~g~~h~]]]~w~]]]~r~]]]~n~~g~~h~]]]~w~]]]~r~]]]~n~~g~~h~]]]~w~]]]~r~]]]~n~~g~~h~]]]~w~]]]~r~]]]~n~~g~~h~]]]~w~]]]~r~]]]"},
	{"Japan","~w~]]]]]]]]]~n~~w~]]]~r~]]]~w~]]]~n~~w~]]~r~]]]]]~w~]]~n~~w~]]~r~]]]]]~w~]]~n~~w~]]]~r~]]]~w~]]]~n~~w~]]]]]]]]]"},
	{"Jordan","~r~]]~l~]]]]]]]~n~~r~]]]~l~]]]]]]~n~~r~]~w~]~r~]]~w~]]]]]~n~~r~]]]]~w~]]]]]~n~~r~]]]~g~]]]]]]~n~~r~]]~g~]]]]]]]"},
	{"Kuwait","~l~]~g~]]]]]]]]~n~~l~]]~g~]]]]]]]~n~~l~]]]~w~]]]]]]~n~~l~]]]~w~]]]]]]~n~~l~]]~r~]]]]]]]~n~~l~]~r~]]]]]]]]"},
	{"Latvia","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Lebanon","~r~]]]]]]]]]~n~~w~]]]]~g~]~w~]]]]~n~~w~]]]~g~]]]~w~]]]~n~~w~]]]]~g~]~w~]]]]~n~~w~]]]~g~]]]~w~]]]~n~~r~]]]]]]]]]"},
	{"Lesotho","~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~w~]]]]~l~]~w~]]]]~n~~w~]]]]~l~]~w~]]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"Libya","~r~~h~]]]]]]]]]~n~~l~]]]]~w~]~l~]]]]~n~~l~]]]~w~]~l~]]]]]~n~~l~]]]~w~]~l~]]~w~]~l~]]~n~~l~]]]]~w~]~l~]]]]~n~~g~~h~]]]]]]]]]"},
	{"Liechtenstein","~b~]]]]]]]]]~n~~b~]~y~]~b~]]]]]]]~n~~b~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Lithuania","~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Luxembourg","~r~~h~]]]]]]]]]~n~~r~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~~h~]]]]]]]]]~n~~b~~h~]]]]]]]]]"},
	{"Madagascar","~w~]]]~r~~h~]]]]]]~n~~w~]]]~r~~h~]]]]]]~n~~w~]]]~r~~h~]]]]]]~n~~w~]]]~g~~h~]]]]]]~n~~w~]]]~g~~h~]]]]]]~n~~w~]]]~g~~h~]]]]]]"},
	{"Malawi","~l~]]]~r~~h~]]]~l~]]]~n~~l~]]~r~~h~]~l~]]~l~]]~l~]]~n~~r~~h~]]]]]]]]]~n~~r~~h~]]]]]]]]]~n~~g~~h~]]]]]]]]]~n~~g~~h~]]]]]]]]]"},
	{"Malaysia","~b~]~y~]~b~]]]~r~]]]]~n~~y~]~b~]]~y~]~b~]~w~]]]]~n~~y~]~b~]]]]~r~]]]]~n~~b~]~y~]~b~]]]~w~]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]"},
	{"Mali","~g~~h~]]]~y~]]]~r~]]]~n~~g~~h~]]]~y~]]]~r~]]]~n~~g~~h~]]]~y~]]]~r~]]]~n~~g~~h~]]]~y~]]]~r~]]]~n~~g~~h~]]]~y~]]]~r~]]]"},
	{"Malta","~w~]]]]~r~]]]]~n~~w~]]]]~r~]]]]~n~~w~]]]]~r~]]]]~n~~w~]]]]~r~]]]]"},
	{"Mauritania","~g~]]]]]]]]]~n~~g~]]]]~y~]~g~]]]]~n~~g~]]~y~]~g~]]]~y~]~g~]]~n~~g~]]]~y~]~y~]~y~]~g~]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"Mauritania","~g~]]]]]]]]]~n~~g~]]~y~]~g~]~y~]~g~]~y~]~g~]]~n~~g~]]~y~]~g~]]]~y~]~g~]]~n~~g~]]]~y~]]]~g~]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"Mauritius","~r~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~g~~h~]]]]]]]]]"},
	{"Mexico","~g~]]]~w~]]]~r~]]]~n~~g~]]]~w~]]]~r~]]]~n~~g~]]]~w~]]]~r~]]]~n~~g~]]]~w~]]]~r~]]]~n~~g~]]]~w~]]]~r~]]]~n~~g~]]]~w~]]]~r~]]]"},
	{"Monaco","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~"},
	{"Mongolia","~r~~h~~h~]]]~b~~h~]]]~r~~h~~h~]]]~n~~r~~h~~h~]~y~]~r~~h~~h~]~b~~h~]]]~r~~h~~h~]]]~n~~r~~h~~h~]~y~]~r~~h~~h~]~b~~h~]]]~r~~h~~h~]]]~n~~y~]]]~b~~h~]]]~r~~h~~h~]]]~n~~y~]]]~b~~h~]]]~r~~h~~h~]]]~n~~r~~h~~h~]]]~b~~h~]]]~r~~h~~h~]]]"},
	{"Morocco","~r~]]]]]]]]]~n~~r~]]]]~g~]~r~]]]]~n~~r~]]]~g~]]]~r~]]]~n~~r~]]]~g~]]]~r~]]]~n~~r~]]]]~g~]~r~]]]]~n~~r~]]]]]]]]]"},
	{"Namibia","~b~]~y~]~b~]]]~w~]~r~]]~w~]~n~~y~]]]~b~]~w~]~r~]]~w~]~g~]~n~~b~]~y~]~b~]~w~]~r~]]~w~]~g~]]~n~~b~]]~w~]~r~]]~w~]~g~]]]~n~~b~]~w~]~r~]]~w~]~g~]]]]~n~~w~]~r~]]~w~]~g~]]]]]"},
	{"Netherlands","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]"},
	{"Nicaragua","~b~~h~~h~~h~]]]]]]]]]~n~~b~~h~~h~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~~h~~h~~h~]]]]]]]]]~n~~b~~h~~h~~h~]]]]]]]]]"},
	{"Niger","~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~g~~h~]]]]]]]]]~n~~g~~h~]]]]]]]]]"},
	{"Nigeria","~g~]]]~w~]]]~g~]]]~n~~g~]]]~w~]]]~g~]]]~n~~g~]]]~w~]]]~g~]]]~n~~g~]]]~w~]]]~g~]]]~n~~g~]]]~w~]]]~g~]]]~n~~g~]]]~w~]]]~g~]]]"},
	{"Norway","~r~~h~]]]~b~]~r~~h~]]]]]~n~~r~~h~]]]~b~]~r~~h~]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~r~~h~]]]~b~]~r~~h~]]]]]~n~~r~~h~]]]~b~]~r~~h~]]]]]~n~~r~~h~]]]~b~]~r~~h~]]]]]"},
	{"Pakistan","~w~]]~g~]]]]]]]~n~~w~]]~g~]]~w~]~g~]~w~]~g~]]~n~~w~]]~g~]~w~]~g~]]]]]~n~~w~]]~g~]~w~]~g~]]~w~]~g~]]~n~~w~]]~g~]]~w~]]~g~]]~n~~w~]]~g~]]]]]]]"},
	{"Palau","~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]~y~~h~]~b~~h~~h~]]]]]~n~~b~~h~~h~]]~y~~h~]]]~b~~h~~h~]]]]~n~~b~~h~~h~]]~y~~h~]]]~b~~h~~h~]]]]~n~~b~~h~~h~]]]~y~~h~]~b~~h~~h~]]]]]~n~~b~~h~~h~]]]]]]]]]"},
	{"Philippines","~w~]~b~]]]]]]]]~n~~w~]]~b~]]]]]]]~n~~w~]]~r~]]]]]]]~n~~w~]~r~]]]]]]]]"},
	{"Poland","~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Portugal","~g~]]]~r~]]]]]~n~~g~]]]~r~]]]]]~n~~g~]]]~r~]]]]]~n~~g~]]]~r~]]]]]"},
	{"Romania","~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]~n~~b~]]]~y~]]]~r~]]]"},
	{"Russia","~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Rwanda","~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]~y~~h~]~b~~h~~h~]~n~~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~y~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"San Marino","~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~"},
	{"Senegal","~g~]]]~y~]]]~r~]]]~n~~g~]]]~y~]]]~r~]]]~n~~g~]]]~y~]~g~]~y~]~r~]]]~n~~g~]]]~y~]~g~]~y~]~r~]]]~n~~g~]]]~y~]]]~r~]]]~n~~g~]]]~y~]]]~r~]]]"},
	{"Serbia","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]"},
	{"Sierra Leone","~g~~h~]]]]]]]]]~n~~g~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~~h~]]]]]]]]]~n~~b~~h~]]]]]]]]]"},
	{"Slovakia","~w~]]]]]]]]]~n~~w~]~r~~h~]]]~w~]]]]]~n~~b~]~r~~h~]~w~]~r~~h~]~b~]]]]]~n~~b~]]~w~]~b~]]]]]]~n~~r~]]~b~]~r~]]]]]]~n~~r~]]]]]]]]]"},
	{"Slovenia","~w~]]]]]]]]]~n~~w~]]~b~]~b~]~w~]]]]]~n~~b~]]~w~]]~b~]]]]]~n~~b~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Somalia","~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]~w~]~b~~h~~h~]]]]~n~~b~~h~~h~]]]~w~]~w~]~w~]~b~~h~~h~]]]~n~~b~~h~~h~]]]~w~]~w~]~w~]~b~~h~~h~]]]~n~~b~~h~~h~]]]]~w~]~b~~h~~h~]]]]~n~~b~~h~~h~]]]]]]]]]"},
	{"Spain","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Sudan","~g~]~r~]]]]]]]]~n~~g~]]~r~]]]]]]]~n~~g~]]]~w~]]]]]]~n~~g~]]]~w~]]]]]]~n~~g~]]~l~]]]]]]]~n~~g~]~l~]]]]]]]]"},
	{"Sweden","~b~]]]~y~]]~b~]]]]]~n~~b~]]]~y~]]~b~]]]]]~n~~y~]]]]]]]]]]~n~~b~]]]~y~]]~b~]]]]]~n~~b~]]]~y~]]~b~]]]]]"},
	{"Switzerland","~r~]]]]]~n~~r~]]~w~]~r~]]~n~~r~]~w~]]]~r~]~n~~r~]]~w~]~r~]]~n~~r~]]]]]~n~"},
	{"Syria","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]~g~]~w~]]]~g~]~w~]]~n~~w~]]]]]]]]]~n~~l~]]]]]]]]]~n~~l~]]]]]]]]]"},
	{"Taiwan","~b~]]]]~r~]]]]]~n~~b~]~w~]]~b~]~r~]]]]]~n~~b~]~w~]]~b~]~r~]]]]]~n~~b~]]]]~r~]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Tanzania","~g~~h~]]]]]~y~]~l~]]~y~]~n~~g~~h~]]]]~y~]~l~]]~y~]~b~~h~~h~]~n~~g~~h~]]]~y~]~l~]]~y~]~b~~h~~h~]]~n~~g~~h~]]~y~]~l~]]~y~]~b~~h~~h~]]]~n~~g~~h~]~y~]~l~]]~y~]~b~~h~~h~]]]]~n~~y~]~l~]]~y~]~b~~h~~h~]]]]]"},
	{"Thailand","~r~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~w~]]]]]]]]]~n~~r~~h~]]]]]]]]]"},
	{"Togo","~r~]]]~g~]]]]]]~n~~r~]~w~]~r~]~g~]]]]]]~n~~r~]]]~y~]]]]]]~n~~y~]]]]]]]]]~n~~g~]]]]]]]]]~n~~g~]]]]]]]]]"},
	{"Tonga","~w~]~r~]~w~]]~r~]]]]]~n~~r~]]]~w~]~r~]]]]]~n~~w~]]]]~r~]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Tunisia","~r~]]]~w~]]]~r~]]]~n~~r~]]~w~]]~r~]~w~]]~r~]]~n~~r~]~w~]]~r~]~w~]]~r~]~w~]~r~]~n~~r~]~w~]]~r~]~w~]]]]~r~]~n~~r~]]~w~]]~r~]~w~]]~r~]]~n~~r~]]]~w~]]]~r~]]]"},
	{"Turkey", "~r~]]]]]]]]~n~~r~]]~w~]]~r~]]]]~n~~r~]~w~]~r~]]]~w~]~r~]]~n~~r~]]~w~]]~r~]]]]~n~~r~]]]]]]]]"},
	{"U.S.","~b~]]]~r~]]]]]]~n~~b~]]]~w~]]]]]]~n~~b~]]]~r~]]]]]]~n~~w~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Ukraine","~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~b~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~y~]]]]]]]]]"},
	{"Uzbekistan","~b~~h~~h~]]]]]]]]]~n~~b~~h~~h~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~g~~h~]]]]]]]]]~n~~g~~h~]]]]]]]]]"},
	{"Vatican City","~y~]]]]~w~]]]]~n~~y~]]]]~w~]]]]~n~~y~]]]]~w~]]]]~n~~y~]]]]~w~]]]]~n~~y~]]]]~w~]]]]~n~~y~]]]]~w~]]]]~n~~y~]]]]~w~]]]]~n~~y~]]]]~w~]]]]"},
	{"Venezuela","~y~]]]]]]]]]~n~~y~]]]]]]]]]~n~~b~]]]~w~]]]~b~]]]~n~~b~]]~w~]~b~]]]~w~]~b~]]~n~~r~]]]]]]]]]~n~~r~]]]]]]]]]"},
	{"Vietnam","~r~]]]]]]]]]~n~~r~]]]]~y~~h~]~r~]]]]~n~~r~]]]~y~~h~]]]~r~]]]~n~~r~]]]~y~~h~]]]~r~]]]~n~~r~]]]]~y~~h~]~r~]]]]~n~~r~]]]]]]]]]"},
	{"Yemen","~r~]]]]]]]]]~n~~r~]]]]]]]]]~n~~w~]]]]]]]]]~n~~w~]]]]]]]]]~n~~l~]]]]]]]]]~n~~l~]]]]]]]]]"},
	{"Zimbabwe","~w~]]~g~]]]]]]]~n~~w~]~r~]~w~]~y~]]]]]]~n~~r~]~y~]~r~]~w~]~r~]]]]]~n~~y~]]]~w~]~l~]]]]]~n~~w~]]]~y~]]]]]]~n~~w~]]~g~]]]]]]]"}
};

public OnFilterScriptInit()
{
	print("\n-- Loading Simple Country Flags by GTA-Freak --\n");
	
	// Create textdraw and reserve it for later usage
	// Take care if you modify settings here
	// See http://wiki.sa-mp.com/wiki/Textdraw
	TDFlag = TextDrawCreate(265.000000, 165.000000, "_");
	TextDrawBackgroundColor(TDFlag, 255);
	TextDrawFont(TDFlag, 2);
	TextDrawLetterSize(TDFlag, 0.350000, 1.299999);
	TextDrawColor(TDFlag, -1);
	TextDrawSetOutline(TDFlag, 1);
	TextDrawSetProportional(TDFlag, 1);
}

public OnFilterScriptExit()
{
	print("\n-- Unloading Simple Country Flags by GTA-Freak --\n");
	
	// Unload and remove textdraw for flags	
	TextDrawHideForAll(TDFlag);
	TextDrawDestroy(TDFlag);
}

/* This command only works for rcon-admins. Feel free to combine it with your own admin system. */
COMMAND:flags(playerid,params[])
{
	new CountryList[2000];
	
	if (!IsPlayerAdmin(playerid))
		return 0;

	for (new i = 0; i < sizeof(CountryNames); i++) {
		format(CountryList, sizeof(CountryList),"%s%s\n",CountryList,CountryNames[i][Name]);
	}

	ShowPlayerDialog(playerid,COUNTRY_FLAGS_DIALOG_ID,DIALOG_STYLE_LIST,"Select Country:",CountryList,"Select","Close");
		
	return 1;
}

/* Clears the flag textdraw, useful if you want to make the flag disappear by yourself */
COMMAND:flagsclear(playerid,params[])
{
	if (!IsPlayerAdmin(playerid))
		return 0;

	if (Country_Flags_Shown == 1)
	{
		KillTimer(Country_Flags_Timer);
		DestroyTDFlag();
	} else
		SendClientMessage(playerid,0xDCDCDCFF, "Nothing to clear!");
		
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if (dialogid == COUNTRY_FLAGS_DIALOG_ID)
	{
		if(!response)
			return 1;
		
		new FLAGS_DISPLAY_TEXT[256];
		
		if (strlen(CountryNames[listitem][Name]) > 3 && strlen(CountryNames[listitem][String]) > 5)
		{
			format(FLAGS_DISPLAY_TEXT, sizeof(FLAGS_DISPLAY_TEXT), "%s~n~~n~~w~%s",CountryNames[listitem][String],CountryNames[listitem][Name]);
			TextDrawSetString(TDFlag,FLAGS_DISPLAY_TEXT);
			TextDrawShowForAll(TDFlag);
			#if defined COUNTRY_FLAGS_SOUND_ID
				for (new i=0; i<MAX_PLAYERS; i++) {
					PlayerPlaySound(i,COUNTRY_FLAGS_SOUND_ID,0,0,0);
				}
			#endif
			
			Country_Flags_Shown = 1;
			
			if (Country_Flags_Shown == 1)
				KillTimer(Country_Flags_Timer);
				
			Country_Flags_Timer = SetTimer("DestroyTDFlag",COUNTRY_FLAGS_DISPLAY_TIME,false);
		} else {
			SendClientMessage(playerid,0xDCDCDCFF, "Invalid selection");
		}
	}
	
	return 1;
}

forward DestroyTDFlag();
public DestroyTDFlag()
{
	TextDrawHideForAll(TDFlag);
	Country_Flags_Shown = 0;
}