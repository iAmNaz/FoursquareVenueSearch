# Venue Search

A simple Foursquare app that fetches venue information based on the user's current location.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

The app depends on the DecouplerKit project so you will need to clone it and preferably in the same directory as this project.

```
https://github.com/iAmNaz/DecouplerKit.git
```

Before running pod install you need to make sure you already have cocoapods installed. Visit [cocoapods.org](https://cocoapods.org) for installation instructions.

You also need XCode 10 installed to work with the project.

### Installing

Make sure the path to the DecouplerKit is concurrent with how you organized the projects.

The path to the kit should suffice if you put them in one folder.

```
pod 'DecouplerKit', :path => '../DecouplerKit/'
```

While in the root directory of this app, in the terminal run the pod install command to install the DecouplerKit

```
~$ pod install
```

## Running the tests

Open the project in XCode 10 using the workspace file then using the keyboard press command+U to run the tests.

Command+R to run and build the app on a device or simulator.


## Built With

* [DecouplerKit](https://github.com/iAmNaz/DecouplerKit.git/) - The decoupling framework
* [PromiseKit](https://github.com/mxcl/PromiseKit.git) - Promises for Swift & ObjC
* [DIP](https://github.com/AliSoftware/Dip.git) - Simple Swift Dependency container


## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags). 

## Authors

* **Naz Mariano** - *Initial work* - [iAmNaz](https://github.com/iAmNaz)
