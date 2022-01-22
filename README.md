# jarbatexe
Batch script that turns a .jar file into a self contained x64 .exe file.

# How does this script work?
The script first generates a custom Java Runtime Environment that only includes modules used by your .jar file. <br>
Then it uses Launch4j to generate an .exe file that calls the .jar file using the custom JRE. <br>
After that, warp-packer is used to pack the generated .exe and the custom JRE into a single .exe file that unpacks itsself at runtime and then starts the application. <br>
If ```-icon <path_to_icon>``` is provided, then ResourceHacker is used to set a custom icon for the generated .exe. <br>
Use ```-headless``` if you want to convert a console application. Otherwise it will not work.<br>
Note: if you don't generate your executable with ```-headless```, then it is not possible to see command line output!

Jeyy, that's it.

# Setup
* Put the bin folder of your java installation into PATH.<br>
* Download Launch4j and put its installation folder into PATH. http://launch4j.sourceforge.net/ <br>
* Download warp-packer and put it into PATH or into the same folder as jarbatexe.bat. https://github.com/dgiagio/warp <br>

Optional: <br>
* Download Resourcehacker and put its installation folder into PATH. Needed for setting an icon. http://www.angusj.com/resourcehacker/ <br>

# Usage
```
jarbatexe.bat -in <path_to_jar> -out <path_to_exe> [-icon <path_to_icon>] [-headless]
```
