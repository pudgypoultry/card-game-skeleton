# Godot Card Game Skeleton

An addon meant for building card games in **Godot 4.x**. 

This addon provides a workflow for designing cards, managing data, building decks, and instantiating card scenes within the Godot editor.

(Images provided here are based on the example project based around a standard deck of 52 playing cards.)

## Features

### Card Database Management
* Saves cards to a JSON dictionary for easy loading and management.
* Text-readable data storage that plays nicely with version control.
* Create, Read, Update, and Delete cards directly from the editor dock.
* Automatically associates card art and scene files with data based on folder structure or custom paths.

<img width="924" height="366" alt="image" src="https://github.com/user-attachments/assets/dfa6747a-02a4-4a52-9093-2afe82730fb5" />
<img width="582" height="545" alt="image" src="https://github.com/user-attachments/assets/840efdb5-00c6-40da-b1f1-46ebf6423b7c" />

### Custom Attribute System
* Allows the user to define their own custom card attributes (e.g., *Health, Mana, Power, Description*).
* Attributes can be added or removed via the Project Settings menu.
* Attributes can be in the form of either Text, Numeric, or Enumerated types.
* Prevents saving "broken" cards by enforcing required fields like Name and Scene Path.

<img width="571" height="448" alt="image" src="https://github.com/user-attachments/assets/0bfd82a9-7183-4c6b-b3ba-2659af558508" />

### Template & Inheritance System
* The user can choose the location that cards are saved to in the Project Settings menu.
* Automatically generates unique `.gd` scripts for every new card, inheriting from either the provided abstract base class or the user's own.
* Safely batch-update the inheritance path of all existing cards when you refactor/relocate your base script.

<img width="577" height="347" alt="image" src="https://github.com/user-attachments/assets/5bfaef01-0d0d-459e-bac1-29168aa87b10" />


### Visual Deck Builder
* Saves decklists to a JSON dictionary for easy loading and management.
* Create, edit, and delete decks via the Manage Decks menu.
* Building decks is easy with the card browser that lets the user search through their library of created cards.
* Search cards via filtering by Name, Attribute and sorting or numerical stats.
  
<img height="500" alt="image" src="https://github.com/user-attachments/assets/707e7554-9986-41fb-9e3f-303f05094b2e" />
<img height="500" alt="image" src="https://github.com/user-attachments/assets/d1ef85be-ea29-4a92-aa72-96e988a75522" />


## Installation

1.  Download the latest release or clone this repository.
2.  Copy the `addons/CardGameSkeleton` folder into your Godot project's `res://addons/` directory.
3.  Open **Project > Project Settings > Plugins**.
4.  Enable **CardGameSkeleton**.
5.  A new tab called **"Card CMS"** (or your custom name) will appear in the bottom panel.

## Getting Started

### 1. Configuration
Go to the **Settings** tab in the addon menu:
* **Root Directory:** Set where your card files will be saved (default: `res://Cards/`).
* **Attributes:** Add the stats your game needs (e.g., "Cost" as a Number, "Rarity" as an Enum).
* **Template Path:** (Optional) Point to your custom `MyCardBase.tscn` to use it as a factory template.

### 2. Creating a Card
1.  Open the **New Card** tab.
2.  Fill in the stats (Name, Cost, Description, etc.).
3.  Click **Save Card**.
4.  The addon generates a `.tscn` scene, a `.gd` script, and a JSON entry automatically.

### 3. Using Data in Game
You can either write your own loader from the JSON files created, or you can use the CardLibrary script attached to the CardJSONManager node in the addon as an API in your game.
