
# react-native-sm-rongim

## Getting started

`$ npm install react-native-sm-rongim --save`

### Mostly automatic installation

`$ react-native link react-native-sm-rongim`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-sm-rongim` and add `SMOSmRongim.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libSMOSmRongim.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.sm_rongim.SMOSmRongimPackage;` to the imports at the top of the file
  - Add `new SMOSmRongimPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-sm-rongim'
  	project(':react-native-sm-rongim').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-sm-rongim/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-sm-rongim')
  	```


## Usage
```javascript
import SMOSmRongim from 'react-native-sm-rongim';

// TODO: What to do with the module?
SMOSmRongim;
```
  