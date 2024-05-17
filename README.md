## What is this?
This project simply removes some restrictions on BeamNG.drive. It works by patching memory or hooking functions in the game. To use it, simply place `winmm.dll` in the game directory and then use whichever argument(s) you want below. If you don't specify anything, then nothing will happen, the game won't get touched. And the `-c` part is the prefix I have, that way there's no conflicts with the real game arguments.  

I also don't see anyone ever even using this, there's not really much point of it. I get to mess around with the game though, so yeah :)

## Installation
Simply download `winmm.lib` and `signatures.json` from the releases and put them in the game's `Bin64` folder (in the installation path, not where mods and other stuff is located).
All you have to do then is launch the game with the argument specified above. It works because programs automatically load dll's like `winmm`.

(Also, the `nsb` stands for "no sandbox". That's what it was originally called, but the function that I hook doesn't really handle that, it only handles loadlib)

## Commandline Arguments
- `-c-allow-loadlib` : Allows functions such as `loadlib`, `ffi.load` and maybe others.
- `-c-unrestrict-openwebbrowser` : Unrestricts the `openWebBrowser` (as of recently (0.30 or 0.31), they secured this function (to some extent..), this will just remove those restrictions)