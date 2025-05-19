# SleepTamagochi
Collaborative project to create a gamified sleep health app. Prototypes are created in Godot (https://godotengine.org/).

## Getting Started
### Clone Repository
Create a git account: https://docs.github.com/en/get-started/signing-up-for-github/signing-up-for-a-new-github-account.
<br/>
<br/>

If you are a student, you are eligible to sign up for ehanced benefits: https://docs.github.com/en/education/explore-the-benefits-of-teaching-and-learning-with-github-education/github-global-campus-for-students/apply-to-github-global-campus-as-a-student
<br/>
<br/>

Follow these instructions to install github on your development machine of choice: https://github.com/git-guides/install-git.
This guide assumes you are using the command line (Git Bash) but GitHub Desktop works fine as well.
<br/>
<br/>

Open Git Bash and navigate to the location where you want to clone your repository:
```
cd directory_path
```
<br/>

Clone the repository using the clone command:
```
https://github.com/KUAS-ubicomp-lab/SleepTamagochi.git
```
<br/>

### Install and Configure Godot 4.3
Follow this tutorial to download, install, and configure Godot to use Android: https://developer.android.com/games/engines/godot/godot-configure
- **Make sure you are downloading Godot 4.3 (other versions might cause issues): https://godotengine.org/download/archive/4.3-stable/**
- **We will not be using C# for the project, so ignore the *Set up Mono* portion of the tutorial.**
- **You can use the altgameslab.keystore at the root of this directory for your debug keystore. Contact the repository owner for the password needed to use it in Godot.**
<br/>

Once your Android SDK and debug keystore are linked proprely in Godot, follow this tutorial to configure your android export settings: https://developer.android.com/games/engines/godot/godot-export
- **WearOS requires the armeabi-v7a architecture to run properly, so make sure that architecture box is checked when customizing your Android export options.**
<br/>

You are now ready to build and export your own android projects.
<br/>
<br/>

## Development Pipeline
### Run Godot on WearOS Android Emulator
#### Setup
In order to run your Godot applications on a WearOS emulator, the first step is to configure a WearOS emulator on the Android Device Manager.
To start, open *Android Studio* and follow the **Configure an emulator** instructions here: https://developer.android.com/training/wearables/get-started/creating#configure-emulator
- **The Wear OS Large Round is the closest to the google pixel watch so it is recommended to create an emulator with that image and API level 33.**
<br/>

#### Running the Emulator
After setting up your emulator, the next step is to run it through the command line so that Godot can recognize it.
Follow these instructions to run the emulator: https://developer.android.com/studio/run/emulator-commandline\
<br/>
<br/>
**Note: You'll need to use the path to the Android SDK from earlier.** The command should look something like this where *user_name* is the user name for your device:
```
C:\Users\user_name\AppData\Local\Android\Sdk\emulator\emulator -avd Wear_OS_Large_Round_API_33
```
<br/>

You can also view what emulators are available with the the **-list-avds** command:
```
C:\Users\user_name\AppData\Local\Android\Sdk\emulator\emulator -list-avds
```

#### Connecting Godot to the Emulator
Once the WearOS emulator is running, Godot should automatically detect it and enable the **Remote Debug** option on the top right side of the editor. Simply click this button and select the appropriate Android emulator from the dropdown list (see image below).

![Godot Remote Debug of Android WearOS Emulator](Readme/GodotRemoteDebug.png?raw=true "Godot Remote Debug of Android WearOS Emulator")
<br/>
<br/>
That's it, Godot should handle the rest and install it on the emulator for you to test.
<br/>
<br/>

### Run Godot on Google Pixel Watch
#### Wirelessly Pairing with the Google Pixel Watch
**If you are connecting to your Google Pixel Watch wirelessly for the first time, it first needs to be paired to your development machine.**
This can be done by following the instructions in the **** section: https://developer.android.com/tools/adb#wireless-android11-command-line
The pairing command line should look should look something like this, replacing *user_name* with the user name for your machine:
```
C:\Users\user_name\AppData\Local\Android\Sdk\platform-tools\adb pair 192.168.1.13:42769
```
<br/>

#### Wirelessly connecting to the Google Pixel Watch
Once your Google Pixel Watch is paired to your development machine, you just need to connect it with the following command, replacing *user_name* with the user name for your machine:
```
C:\Users\user_name\AppData\Local\Android\Sdk\platform-tools\adb connect 192.168.1.13:43013
```
<br/>

You can check to ensure that your Google Pixel Watch is properly connected with the following command, replacing *user_name* with the user name for your machine:
```
C:\Users\user_name\AppData\Local\Android\Sdk\platform-tools\adb devices
```
<br/>

#### Installing an APK on the Google Pixel Watch
Once connected, the Google Pixel Watch should also appear as an option for the Godot **Remote Debug** button on the top right side of the editor. Just click the button to upload the apk.

If you would prefer install the apk over the command line, use the following install command with the path to your .apk file to install it on the Google Pixel Watch, replacing *user_name* with the user name for your machine:
```
C:\Users\user_name\AppData\Local\Android\Sdk\platform-tools\adb install -r "C:/Users/user_name/Desktop/ALT-Games-Lab/Projects/Gamified-Sleep-Health-App/Prototypes/Godot Wear Template/build/gamifiedsleephealthapp.apk"
```
<br/>

## Using Custom Android Plugins in Godot
### Creating Godot Android Plugins
Godot Android plugins now use the V2 architecture, which is much easier to work with (https://docs.godotengine.org/en/stable/tutorials/platform/android/android_plugin.html). There is also a template available to easily create your own Android Plugin for Godot, just download the repository and follow the README steps to configure it from here: https://github.com/m4gr3d/Godot-Android-Plugin-Template.

### Modifying Godot Android Plugins
The Android plugins for Godot are already preconfigured to work in Android Studio. Just download the latest version of Android Studio (https://developer.android.com/studio) and open the desired plugin folder as an existing project. Then just modify/add your own Java or Kotlin code for the plugin.

### Building Godot Android Plugins
When you are ready to build your plugin, navigate to the root of the plugin directory in a terminal and run the following command:
```
./gradlew assemble
```

#### Tips
You may get an error when trying to build the project if your SDK_HOME environmental variable is not set. To fix this, create a **local.properties** file at the root of your plugin directory and add the following line inside with the correct path to your Android SDK:
```
sdk.dir=/Path/To/Your/Android/sdk
```

### Adding Android Plugins to Godot
After building and when you are ready to add/update the plugin in Godot, go to the root folder of your desired plugin. Then navigate to "plugin" -> "demo" -> "addons". Then copy the folder inside of addons. This is your compiled Android plugin for Godot. Then paste this folder inside of your addons folder in your desired Godot project (e.g., Sleep-Hero-Journey).

The next time you open Godot, it should automatically recognize the new plugin in the project. To enable the plugin, go to "Project" -> "Project Settings..." and click the "Plugins" tab. Make sure the "On" checkbox is selected in order to use the plugin in your project.
