# DermaLens

## _Your Personal Skin Health Companion_

[![N|Solid](https://i.imgur.com/8wECp9E.png)](https://dermalens.com)

[![Build Status](https://img.shields.io/badge/build-passing-brightgreen)](https://github.com/yourusername/dermalens)
[![Flutter](https://img.shields.io/badge/Flutter-3.0.0+-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

DermaLens is a comprehensive mobile application that helps users analyze their skin condition and
receive personalized skincare recommendations. Using advanced image processing and AI technology,
DermaLens provides accurate skin assessments and tailored treatment plans.

- Capture skin images with your device camera
- Get AI-powered skin analysis and recommendations
- ✨Track your skin health progress over time✨

## Features

- **Skin Analysis** - Capture and analyze skin conditions using your device's camera
- **Personalized Recommendations** - Receive customized skincare routines and product suggestions
- **Progress Tracking** - Monitor improvements in your skin health over time
- **Expert Consultation** - Connect with dermatologists for professional advice
- **Educational Content** - Access informative articles about skin health and care

> The overriding design goal for DermaLens
> is to make professional-grade skin analysis
> accessible to everyone. We believe that
> understanding your skin is the first step
> to improving it.

## Tech Stack

DermaLens uses a number of open source projects to work properly:

- [Flutter](https://flutter.dev/) - Cross-platform UI toolkit for building beautiful applications
- [Provider](https://pub.dev/packages/provider) - State management solution for Flutter
- [Node.js](https://nodejs.org/) - Evented I/O for the backend
- [Express](https://expressjs.com/) - Fast, unopinionated, minimalist web framework for Node.js
- [MongoDB](https://www.mongodb.com/) - Document-oriented database program
- [TensorFlow](https://www.tensorflow.org/) - Open-source machine learning framework
- [JWT](https://jwt.io/) - JSON Web Token for secure authentication

And of course DermaLens itself is open source with
a [public repository](https://github.com/yourusername/dermalens) on GitHub.

## Installation

DermaLens requires [Flutter](https://flutter.dev/docs/get-started/install) (3.0.0+)
and [Dart](https://dart.dev/get-dart) (2.17.0+) to run.

Install the dependencies and run the application.

```sh
git clone https://github.com/yourusername/dermalens.git
cd dermalens
flutter pub get
flutter run
```

For production builds:

```sh
flutter build apk --release
# or
flutter build ios --release
```

## Project Structure

```
dermalens/
├── lib/
│   ├── controllers/       # Business logic controllers
│   ├── models/            # Data models
│   ├── providers/         # State management providers
│   ├── screens/           # UI screens
│   │   ├── auth/          # Authentication screens
│   │   ├── user/          # User-related screens
│   │   └── analysis/      # Skin analysis screens
│   ├── services/          # API and external services
│   ├── utils/             # Utility functions and constants
│   └── widgets/           # Reusable UI components
├── assets/                # Images, fonts, and other static resources
└── test/                  # Unit and widget tests
```

## Plugins

DermaLens is currently extended with the following plugins:

| Plugin                 | Purpose                              |
|------------------------|--------------------------------------|
| camera                 | Access device camera for skin images |
| http                   | API communication with backend       |
| provider               | State management                     |
| shared_preferences     | Local storage for user settings      |
| image_picker           | Select images from gallery           |
| flutter_secure_storage | Secure storage for sensitive data    |
| charts_flutter         | Visualize skin health progress       |

## Development

Want to contribute? Great!

DermaLens uses Flutter for fast development.
Make a change in your file and instantaneously see your updates!

Open your favorite Terminal and run these commands:

```sh
flutter run
```

For hot reload:

```sh
Press "r" in the terminal where flutter run is running
```

For hot restart:

```sh
Press "R" in the terminal where flutter run is running
```

## Docker (Backend)

DermaLens backend is very easy to install and deploy in a Docker container.

```sh
cd backend
docker build -t dermalens-api .
docker run -d -p 3000:3000 --name dermalens-api dermalens-api
```

Verify the deployment by navigating to your server address in your preferred browser.

```sh
127.0.0.1:3000/api/health
```

## License

MIT

**Free Software, Better Skin!**

[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen.)

[flutter]: <https://flutter.dev>

[git-repo-url]: <https://github.com/yourusername/dermalens.git>

[node.js]: <http://nodejs.org>

[express]: <http://expressjs.com>

[mongodb]: <https://www.mongodb.com/>

[tensorflow]: <https://www.tensorflow.org/>