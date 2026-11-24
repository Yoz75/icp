# Overview
ICP is something that i started as "color processor" (a program that applies various effects, idk if this is a real term) and then I got too carried away with quantization and dithering. <br>
The program is still buggy and rough, but usable!<br>
You can find default palettes and images in `[path to exe]/Resources/Example Images` and `[path to exe]/Resources/Example Palettes`<br>
<img width="386" alt="icp1" src="https://github.com/user-attachments/assets/1689861b-9240-4fbc-945b-68e119f6b230"/>
<img width="386" alt="icp2" src="https://github.com/user-attachments/assets/870b21c2-4146-4e0d-8142-a16043d36eeb"/>
<img width="386" alt="icp3" src="https://github.com/user-attachments/assets/0c1f17ed-84d9-4657-b205-58fb5a6b67a5"/>
<img width="386" alt="icp4" src="https://github.com/user-attachments/assets/33708f27-c181-4fd2-9107-8fabfe8ba5e0"/>
<img width="386" alt="icp5" src="https://github.com/user-attachments/assets/e4f94585-2856-4d9b-9252-ae5bf3f80d06"/>
<img width="386" alt="knollTestPalette" src="https://github.com/user-attachments/assets/a26ba121-8463-4813-9052-87c49dafd1be"/>

# Building
This project uses [ldc2](https://github.com/ldc-developers/ldc) as compiler and doesn't guarantee you can build it with dmd or gdc. Run `dub run` to build and run debug build, or run:
* `build.bat (.sh)` to only build app in debug mode
* `buildr.bat (.sh)` to only build app in release mode
* `buildlto.bat (.sh)` to only build app in release mode with [LTO](https://llvm.org/docs/LinkTimeOptimization.html) enabled
* `run.bat (.sh)` to run last build (or do nothing if didn't build)  

# Hotkeys
* `F5` or `ctrl + F` -- run ICP
* `F6` or `ctrl + O` -- open an image
* `F7` or `ctrl + S` -- save processed image
* `shift + F7` or `ctrl + shift + s` -- save processed image as a new file
* `F13` (yup) or `alt + S` -- open settings (currently you can only change app theme)

# Known Issues
Sorry for these:
* Combo boxes don't remember it's last choice between sessions. For example, if you'd chose russian and then restarted the app, it'd still be in russian, but
language-choice-combo-box's value would be `english`