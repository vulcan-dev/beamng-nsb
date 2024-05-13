This project allows you to launch BeamNG with `-c-allow-loadlib`, with this, you can use the loadlib function and `ffi.load`.
I plan on making it so you can do other things as well, but I'm not sure what to do next. I just wanted a way to load custom dll's easily into the game from Lua, and now I can do that.

# Installation
Simply download `winmm.lib` and `signatures.json` from the releases and put them in the game's `Bin64` folder (in the installation path, not where mods and other stuff is located).
All you have to do then is launch the game with the argument specified above. It works because programs automatically load dll's like `winmm`.