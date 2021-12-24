# jarbatexe
Batch script that turns a .jar file into a self contained x64 .exe file.

# How does this script work?
The script first generates a custom Java Runtime Environment that only includes modules used by your .jar file. <br>
Then it uses Launch4j to generate an .exe file that calls the .jar file using the custom JRE. <br>
After that, warp-packer is used to pack the generated .exe and the custom JRE into a single .exe file that unpacks itsself at runtime and then starts the application. <br>
If ```-icon <path_to_icon>``` is provided, then ResourceHacker is used to set a custom icon for the generated .exe. <br>
Jeyy, that's it. Now you got a standalone .exe file to share!

# Setup
* Put the bin folder of your java installation into path.<br>
* Download Launch4j and put its installation folder into path. http://launch4j.sourceforge.net/ <br>
* Download warp-packer and put it into path or into the same folder as jarbatexe.bat. https://github.com/dgiagio/warp <br>

Optional: <br>
* Download Resourcehacker and put its installation folder into path. Needed for setting an icon. http://www.angusj.com/resourcehacker/ <br>

# Usage
```
jarbatexe.bat -in <path_to_jar> -out <path_to_exe> [-icon <path_to_icon>]
```
