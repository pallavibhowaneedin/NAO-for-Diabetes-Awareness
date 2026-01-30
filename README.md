# An Interactive NAO Robot System for Child-Focused Diabetes Education

## Project Overview

This project focuses on the development of an interactive application that communicates with the NAO robot to educate children about diabetes awareness and its potential risks. Through speech-based interaction, quizzes, and personalized responses, the system aims to deliver educational content in an engaging and child-friendly manner using human–robot interaction (HRI).

---

## Tools and Technologies

The development of this project required the use of several technologies and tools, including:

### Flutter

Flutter is an open-source development framework used to build applications for iOS, Android, and other platforms. It is based on a widget-driven architecture, allowing efficient design, development, and testing of user interfaces.

### NAOqi SDK

The NAOqi SDK is a software framework used to develop applications that interact with the NAO robot. It provides access to key robot functionalities such as speech synthesis and motion control. In this project, it enables real-time communication between the application and the NAO robot.

### SQLite

SQLite is a lightweight relational database management system embedded directly within the application. It allows user data to be stored locally on the device without the need for an external server.

### Python

Python is used to develop scripts that facilitate communication between the application and the NAO robot. These scripts process incoming commands and manage the robot’s responses using the NAOqi SDK.

### Android Studio

Android Studio is the integrated development environment used to build the application. It provides tools for code editing, debugging, and testing through an integrated Android emulator.

---

## System Architecture

The system is structured into three main layers:

1. **User Interface Layer**
   Developed using Flutter, this layer provides a child-friendly interface that allows users to interact with the robot and trigger educational activities.

2. **Application & Communication Layer**
   Python scripts act as an intermediary between the application and the NAO robot, handling command processing and communication via the NAOqi SDK.

3. **Robot & Data Layer**
   The NAO robot executes speech and movement actions, while SQLite manages local storage of user-related data within the application.

---

## System Workflow

1. The user interacts with the Flutter-based application interface.
2. User actions generate commands sent to the Python communication layer.
3. Python scripts transmit these commands to the NAO robot using the NAOqi SDK.
4. The NAO robot processes the commands and performs actions such as speaking or moving.
5. The robot’s responses are sent back to the application in real time.
6. User data and interaction results are stored locally using SQLite.

---

## NAO Robot Integration

The integration with the NAO robot plays a fundamental role in this project by enabling interactive and educational communication.

### Communication Using the NAOqi SDK

The application uses the NAOqi SDK to send commands to the NAO robot, including asking quiz questions, speaking personalized text, and executing movements. The SDK provides a simple API that allows connection to the robot over a local network.

### Quiz Question Delivery

Quiz questions are stored in JSON format within the Android application resources. When triggered, these questions are sent to the robot, which verbally presents them to children using speech synthesis.

### Personalized Text Interaction

Users can send custom-written text to the NAO robot via the application. The robot receives the text through the NAOqi SDK and speaks it aloud, enabling more engaging and personalized interactions.

### User Response Handling

The NAO robot recognizes user responses through its built-in microphones and speech recognition algorithms. Once a response is received, the robot processes the input and reacts accordingly.

---

## Core Functionalities Overview

### `connect.py`

This Python script manages communication between the application and the NAO robot.

* **`ensure_connected()`** – Verifies the connection to the NAO robot and attempts reconnection if necessary.
* **`start_nao_behaviour()`** – Activates interactive robot behaviors such as movement and attentiveness.
* **`nao_wave_naturally()`** – Triggers a natural greeting gesture once the connection is established.
* **`nao_wave_and_speak()`** – Ensures the robot greets while speaking simultaneously.
* **`connect_nao()`** – Establishes the robot connection and executes greeting behavior.
* **`send_text()`** – Sends text to the robot for speech output.
* **`ask_questions()`** – Sends a set of quiz questions for the robot to ask the user.
* **`check_connection()`** – Confirms the robot connection status.
* **Main Section** – Launches the script and enables interaction with the NAO robot.

---

### `connected.dart`

Handles interaction logic between the user interface and the NAO robot.

* **`_checkConnection()`** – Verifies that the robot is connected.
* **`_askQuestion()`** – Presents quiz questions sequentially.
* **`_startListening()`** – Activates speech recognition to capture user responses.
* **`_checkAnswer()`** – Validates the user’s response.
* **`_sendTextToNao()`** – Sends custom text to the robot for speech output.
* **`_showErrorDialog()`** – Displays error messages when issues occur.

---

### `sleep.dart`

Manages the initial connection process.

* **`_connectToNao()`** – Attempts to connect to the NAO robot and automatically navigates to the connected screen upon success.

---

## Key Features

* Real-time communication with the NAO robot
* Speech-based interaction for child engagement
* Educational quiz system focused on diabetes awareness
* Personalized robot speech responses
* Local data storage using SQLite
* Cross-platform mobile application built with Flutter

---

## Application Interface Preview
<img width="772" height="368" alt="image" src="https://github.com/user-attachments/assets/18339c88-1b8a-492e-8c9e-1a68bd4d0ce9" />
