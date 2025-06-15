# 🟩 Minecraft Server Installer

A Bash script to install and start a **Minecraft Java Edition 21 server** on **Ubuntu**.

---

## 🚀 Installation

### 1️⃣ Clone the repository

```bash
git clone https://github.com/jokikj/minecraft-server.git
cd minecraft-server
```

---

### 2️⃣ Make scripts executable

```bash
chmod +x install_minecraft.sh start_minecraft.sh
```

---

### 3️⃣ Configure environment variables

Before installing, edit the `.env` file to set the server parameters:

```bash
vim .env
```

💡 **Example content of `.env`:**
```
USER=mcadmin
PORT=25565
RAM=2G
```

➡ **Tip:**  
To change the memory allocated to the server, adjust the `RAM` variable.  
For example, to allocate 4 GB of RAM:
```
RAM=4G
```

---

### 4️⃣ Run the installation script

```bash
./install_minecraft.sh
```

---

### 5️⃣ Start the server

```bash
./start_minecraft.sh
```

---

## 🛠 Server Management

Here are some useful commands to manage your Minecraft server:

- **Access the server console**
  ```bash
  sudo -u mcadmin screen -r mc
  ```

- **Stop the server cleanly (from the console)**
  ```
  /stop
  ```

- **Detach from the console without stopping the server**
  ```
  Ctrl + A, D
  ```

---

## 📂 Server files location

All configuration files and world data are stored in:

```
/home/mcadmin/minecraftserver
```

---

## 🌐 Important notes

✅ Ensure that your chosen port (`PORT` in the `.env`, default `25565`) is opened on:  
- your **UFW firewall**  
- your **internet router / box** (port forwarding)

✅ After the server starts, both the local and public IP addresses (if accessible) will be displayed.

---

## 📎 Useful links

- [Official server download](https://www.minecraft.net/en-us/download/server)

---

