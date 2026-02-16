# Docker Installation Guide - MacOS

## Step 1: Download Docker
1. **Go to [www.docker.com](https://www.docker.com)**

![image.png](imgs/docker.com.png)  
2. **Locate and click the download button for Docker Desktop for Mac.**

- Typically, you will have a choice between:
    - "Download for Mac - Apple Silicon" (for newer M1/M2/M3 Macs)
    - "Download for Mac - Intel chip" (for older Intel-based Macs)
    - *Note: *How do I check whether I have Apple Silicon or Intel?:*
        - *Click the Apple logo () in the top-left corner of your computer screen → Select "About This Mac"*
        - *If it says "Chip: Apple M1" or "M2" or "M3" → Choose Apple Silicon*
        - *If it says "Processor: Intel" → Choose Intel chip*

![image.png](imgs/docker-download.png)  

- If prompted to sign in, look for a "Continue without signing in" or direct download option

3. **Download**
- A file named something like `Docker.dmg` or `Docker Desktop.dmg` will be downloaded. 
- It is a large file (500MB - 800MB) and will take several minutes to load

## Step 2: Locate downloaded file
1. **Find the downloaded `Docker.dmg` file**
    - **Option A**: Click directly on the downloaded file in your browser's download bar/area
    - **Option B**: Open **Finder** → Click **Downloads** in the left sidebar
    - **Option C**: Look on your Desktop if your browser saves files there
2. **Double-click on the `Docker.dmg` file to open it**
    - An installation window will open, typically showing The Docker (whale) logo icon ![image.png](imgs/docker-logo.png):
        - An arrow in the middle pointing right
        - The Applications folder icon on the right
        - Instructions that usually say something like "Drag Docker to Applications"

## Step 3: Installing Docker by Dragging to Applications
1. Click and hold on the Docker (whale) icon on the left side of the window
2. Drag it over to the Applications folder icon on the right
3. After releasing, a progress bar or copying window will appear showing "Copying Docker to Applications..."

> Notes:
- This copying process may take 1-3 minutes, `Docker Desktop` is being installed into your Applications folder (where all Mac apps live)
- If it says 'Docker already exists', this means Docker was previously installed. You'll see options:
    - **"Replace"** - Use this to install the new version over the old one (Recommended)
    - **"Keep Both"** - This creates a duplicate, not recommended
    - **"Stop"** - Cancels the installation
- Wait until the copying/installation progress completes before closing anything.

## Step 4: Completing the Installation and Cleaning Up
1. Once the copying is complete, close the Docker installation window
2. Eject the Docker disk image
    - **Option A**: Look for a "Docker" disk icon on your Desktop → Right-click it → Select "Eject"
    - **Option B**: Open Finder → Look in the left sidebar under "Locations" for "Docker" → Click the eject icon (⏏) next to it
    - **Option C**: Drag the Docker disk icon from your Desktop to the Trash (the Trash icon will change to an Eject symbol)

3. You're back to your normal Mac desktop

>Notes:
The original `Docker.dmg` file is still in your Downloads folder, you don't need it anymore since Docker is now installed in Applications. You can delete it from Downloads to free up space
Docker is installed but not running yet.

## Step 5: Launching Docker Desktop for the First Time
1. Open Docker Desktop from the Applications folder to start it for the first time.
    - Open **Finder**
    - Click on **Applications** in the left sidebar
    - Scroll down to find **Docker** or **Docker Desktop** (it has a blue whale icon)
    - Double-click on Docker to launch it
    - *Alternative ways to launch:*
        - Use *Spotlight Search*: Press `Command (⌘) + Space`, type "Docker", press Enter
        - Use *Launchpad*: Click Launchpad icon in the Dock, search for Docker, click it
2. After double-clicking:
    - a security dialog box will appear because this is the first time opening the app:
        - **Security Warning:**
        - Message: **"Docker is an app downloaded from the Internet. Are you sure you want to open it?"**
        - Two buttons: **"Cancel"** and **"Open"**
    - This is macOS's security feature (Gatekeeper) that warns you about apps downloaded from the internet. 
    - Click **"Open"**

## Step 6: Docker's Privileged Access Request

1. After clicking "Open", Docker will start to launch
2. A system dialog will appear asking for administrator privileges
    - A macOS authentication dialog box with:
        - Docker whale icon
        - Message: **"Docker Desktop wants to make changes"** or **"Docker Desktop needs privileged access to install networking components"** (or similar wording)
        - A password field with a key/lock icon
        - Text showing your username
        - Two buttons: **"Cancel"** and **"OK"** (or "Allow")
3. Type your Mac's administrator password (the password you use to log into your Mac)
4. Click **"OK"** or press Enter
5. After entering password:
    - Docker begins its initial setup and configuration
    - The Docker whale icon appears in the menu bar at the top of the screen (top-right area)
    - The icon will animate or show activity (the whale might appear to be "breathing" or moving)
    - Note: Be patient - the initial startup can take a few minutes


## Step 7: Docker Desktop Initial Startup and Service Agreement
Wait for Docker to complete its initial startup and accept the Service Agreement.
1. **Initial Loading Screen:**
    - After entering your password, Docker Desktop will open a window showing:
        - Docker whale logo
        - A progress indicator or spinning wheel
        - Text like "Starting Docker Desktop..." or "Initializing..."
        - This can take 1-3 minutes (sometimes longer on first launch)
2. **Service Agreement Window:**
    - Once loading completes, a window appears with:
        - Title: **"Docker Subscription Service Agreement"** or **"Docker Service Agreement"**
        - A long text box containing legal terms and conditions
        - A checkbox that says: **"I accept the terms"** (or similar wording)
        - Buttons: **"Accept"** or **"Decline"**
3. Docker continues its setup process. You may see additional configuration screens.
    - Note: Wait for the startup to complete (be patient - the whale icon in menu bar may animate)

## Step 8: Skip Docker Account Sign-In
1. After accepting the service agreement, a screen appears with:
    - **Sign In Screen:**
        - Docker logo at the top  
        - Title: **"Sign in to Docker Desktop"** or **"Get started with Docker"**  
        - Text explaining benefits of signing in  
        - Two main options:  
            - **"Sign In"** or **"Log In"** button
            - **"Continue without signing in"** or **"Skip"** link (usually smaller text at the bottom)
    - **Continue without signing in**
        - 1. Look for text that says **"Continue without signing in"** or **"Skip"**
        - 2. Click it

## Docker Installed
- After completing Step 8, the **Docker Desktop Dashboard** opens as the main application window, with a layout as below or a variation of it

```
        ╔════════════════════════════════════════════════════════════╗
        ║ Docker Desktop                    🔍Search    👤[Username]║
        ╠════════════════════════════════════════════════════════════╣
        ║ 📦 Containers  🖼️ Images  💾 Volumes  🔧 Dev Environments║
        ╠════════════════════════════════════════════════════════════╣
        ║                                                            ║
        ║                  Getting Started                           ║
        ║                                                            ║
        ║         Welcome to Docker Desktop!                         ║
        ║                                                            ║
        ║    Learn the basics and discover what you can build        ║
        ║                                                            ║
        ║              [Run a sample container]                      ║
        ║                                                            ║
        ║              [View documentation]                          ║
        ║                                                            ║
        ║                                                            ║
        ║  Or start by running your first container:                 ║
        ║                                                            ║
        ║  $ docker run hello-world                                  ║
        ║                                                            ║
        ╚════════════════════════════════════════════════════════════╝
```
- There is nothing else to do in docker here. You can minimize the windows and get ready to install the **agent builder starter pack**.
- **NEXT**: Instructions to setup the agent builder starter pack on MacOS [here](https://github.com/2diyai/agent-builder-starter-pack/blob/main/docs%2Fsetup-mac.md)