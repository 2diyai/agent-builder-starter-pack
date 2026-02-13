# Setup Instructions for MacOS
All files and information required are in the github repo [Agent Builder Starter Pack](https://github.com/2diyai/agent-builder-starter-pack/)

## 1. Create the project folder
### Option 1 (easy)
- Download the zip including all required files. Click [here](https://github.com/2diyai/agent-builder-starter-pack/archive/refs/heads/main.zip) to download.
- Create a project folder (e.g. `agent-builder`) in a convenient place on your system with command.
- Unzip all files from the ZIP into this project folder

### Option 2 (more robust)
- Clone the repository in a convenient place on your system with command:
    ```shell
    git clone git@github.com:2diyai/agent-builder-starter-pack.git agent-builder
    ```



## 2. Install software
This will install all required software into their containers and set it up as a one system. It will install N8N and Ollama. It will also create some disk space to keep configurations, workflows and models locally when you stop Docker and relieve you from having to download them every time.

- open a terminal window in your project folder (top folder)
    - navigate to the project folder in Finder
    - turn on the path bar if needed: View → Show Path Bar.
    - in the path bar (bottom of the Finder window), `Control‑click` the folder and choose `Open in Terminal` (or `Services` → `New Terminal Tab at Folder`)
    - a terminal window will open where you can enter commands
- enter and execute the following commands.
    ```shell
    chmod +x scripts/setup.sh
    ./scripts/setup.sh
    ```
- you should see something like, while N8N and Ollama are installed: 
    ```shell
        Setting up in root directory: /home/.....
        [+] pull 3/3
        ✔ python                     Skipped No image to be pulled                  0.0s
        ✔ Image n8nio/n8n:latest     Pulled                                         7.3s
        ✔ Image ollama/ollama:latest Pulled                                         7.2s
        [+] Building 4.0s (12/12) FINISHED               
        => [internal] load local bake definitions                                                                  0.0s
        => => reading from stdin 560B                                                                         0.0s
        => [internal] load build definition from Dockerfile                                                                   0.0s
        => => transferring dockerfile: 249B                                          0.0s
        => [internal] load metadata for docker.io/library/python:3.12-slim           3.4s

        [+] build 1/1
        ✔ Image n8n-ollama-dev-python Built                                          4.1s
        Setup complete.
    ```
- When you see `Setup complete`, the installation is done.

### 2.2 Start N8N and Ollama
Before you can use N8N and Ollama you need to start the containers

- open a terminal window in your project folder (top folder)
- run the following command:
    ```shell
    ./scripts/start.sh
    ```
- you will see something like:
    ```shell
    [+] up 4/4
    ✔ Network n8n-ollama-dev_app_net Created                               0.3s
    ✔ Container my_ollama            Created                               0.2s
    ✔ Container my_python            Created                               0.2s
    ✔ Container my_n8n               Created                               0.1s
    Services started.
    ```
- when you see `Services Started`, N8N and Ollama are running

### 2.3 Download models (once)
Ollama needs specific models to be downloaded to work. The file `list-of-models.txt` includes a list of a few models convenient to download.

See the full list of models on Ollama's webside [here](https://ollama.com/search)

To download all models in the list:
- open a terminal window in your project folder (top folder)
- run the following command:
    ```shell
    ./scripts/download-models.sh
    ```
- you will see something like:
    ```shell
    Pulling model: gemma3:4b
    pulling manifest 
    pulling aeda25e63ebd: 100% ▕██████████████████▏ 3.3 GB                         
    pulling e0a42594d802: 100% ▕██████████████████▏  358 B                         
    pulling dd084c7d92a3: 100% ▕██████████████████▏ 8.4 KB                         
    pulling 3116c5225075: 100% ▕██████████████████▏   77 B                         
    pulling b6ae5839783f: 100% ▕██████████████████▏  489 B                         
    verifying sha256 digest 
    writing manifest 
    success 
    Model download complete.
    ```
- when you see `Model downld complete`, the models are loaded.

