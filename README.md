# Overview
ICP is something that i started as "color processor" (a program that applies various effects, idk if this is a real term) and then I got too carried away with quantization and dithering. <br>
The program is still buggy and rough, but usable!<br>
You can find default palettes and images in `[path to exe]/Resources/Example Images` and `[path to exe]/Resources/Example Palettes`<br>
<img width="386" alt="icp1" src="https://github.com/user-attachments/assets/1689861b-9240-4fbc-945b-68e119f6b230"/>
<img width="386" alt="icp2" src="https://github.com/user-attachments/assets/870b21c2-4146-4e0d-8142-a16043d36eeb"/>
<img width="386" alt="icp3" src="https://github.com/user-attachments/assets/0c1f17ed-84d9-4657-b205-58fb5a6b67a5"/>
<img width="386" alt="icp4" src="https://github.com/user-attachments/assets/33708f27-c181-4fd2-9107-8fabfe8ba5e0"/>

# Building
This project uses [ldc2](https://github.com/ldc-developers/ldc) as compiler and doesn't guarantee you can build it with dmd or gdc. Run `dub run` to build and run debug build, or run:
* `build.bat (.sh)` to only build app in debug mode
* `buildr.bat (.sh)` to only build app in release mode
* `buildlto.bat (.sh)` to only build app in release mode with [LTO](https://llvm.org/docs/LinkTimeOptimization.html) enabled
* `run.bat (.sh)` to run last build (or do nothing if didn't build)  

# Known Issues
Sorry for these:
* Sometimes ICP doesn't like how you press buttons in open/save dialogue window and crashes
* When you open a preset second time, it restores old values but UI shows default values
* If you select preset A, then preset B and again select preset A, the program crashes (if you select preset C between them, it won't happen)
