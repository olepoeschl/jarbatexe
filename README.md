# jarbatexe
Batch script that turns a jar file into a self contained exe file

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
