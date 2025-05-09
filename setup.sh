#!/bin/bash

# -------------------------------------------
# Strikodot-Kali-edition Bootstrap Installer
# -------------------------------------------

set -e

# --- Step -1: Make setup location-aware ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --- Step 0: Install Essential Packages ---
echo -e "\n[+] Installing required packages..."
sudo apt update && sudo apt install -y git tmux feroxbuster dirbuster gobuster seclists

# --- Step 1: Create Workspace Directory ---
echo -e "\n[+] Creating ~/strikodot directory..."
mkdir -p ~/strikodot
cd ~/strikodot

# --- Step 2.1: Download Linux Enumeration Scripts ---
echo -e "[+] Downloading Linux enumeration tools..."
# https://github.com/peass-ng/PEASS-ng/tree/master/linPEAS
wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas_linux_amd64
chmod +x linpeas.sh
# https://github.com/The-Z-Labs/linux-exploit-suggester
wget -q https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh -O linuxexploitsuggester.sh
chmod +x linuxexploitsuggester.sh
# https://github.com/rebootuser/LinEnum
wget -q https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh -O LinEnum.sh
chmod +x LinEnum.sh
# https://github.com/sleventyeleven/linuxprivchecker
wget -q https://raw.githubusercontent.com/sleventyeleven/linuxprivchecker/master/linuxprivchecker.py -O linuxprivchecker.py

# --- Step 2.2: Download Windows Enumeration Scripts ---
echo -e "[+] Downloading Linux enumeration tools..."


# --- Step 3: Setup .zshrc Block ---
echo -e "\n[+] Appending tmux auto-launch and addhost function to ~/.zshrc..."
cat << 'EOF' >> ~/.zshrc

# Auto-start tmux with vertical split on login
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
    tmux has-session -t main 2>/dev/null || {
        tmux new-session -d -s main
        tmux split-window -h -t main
    }
    tmux attach-session -t main
fi

# Add or update a host entry in /etc/hosts
addhost() {
  if [ $# -ne 2 ]; then
    echo "Usage: addhost <IP> <hostname>"
    return 1
  fi
  sudo sed -i "/[[:space:]]$2$/d" /etc/hosts
  echo "$1 $2" | sudo tee -a /etc/hosts > /dev/null
  echo "Added/Updated: $1 $2"
}
EOF

# --- Step 4: Create ~/.tmux.conf ---
echo -e "\n[+] Writing tmux configuration to ~/.tmux.conf..."
cat << 'EOF' > ~/.tmux.conf
# Prefix Key
unbind C-b
set -g prefix C-s
bind C-s send-prefix

# Mouse and Clipboard
set -g mouse on
set -g set-clipboard on

# Function Key Window Shortcuts
bind-key -n F1 select-window -t :1
bind-key -n F2 select-window -t :2
bind-key -n F3 select-window -t :3
bind-key -n F4 select-window -t :4
bind-key -n F5 select-window -t :0

# Status Bar
set -g status-right "Strikoder"

# --- Step 5: Vim clipboard fixing ---
echo -e "\n[+] Enabling system clipboard for Vim..."
echo "set clipboard=unnamedplus" | sudo tee -a /etc/vim/vimrc > /dev/null

# --- Step 6: Copy Custom Tools ---
echo -e "\n[+] Installing full_nmap and cme-brute-multiusers to /usr/local/bin..."
sudo install -m 755 "$SCRIPT_DIR/full_nmap.sh" /usr/local/bin/full_nmap
sudo install -m 755 "$SCRIPT_DIR/cme-brute-multiusers.sh" /usr/local/bin/cme-brute-multiusers

# --- Step 7: Create my_commands helper ---
echo -e "\n[+] Installing 'my_commands' helper to /usr/local/bin..."
sudo tee /usr/local/bin/my_commands > /dev/null << 'EOF'
#!/bin/bash
echo -e "\nAvailable Custom Commands:\n"
echo -e "🔹 full_nmap <target>\n   → Run full + detailed Nmap scans"
echo -e "🔹 cme-brute-multiusers <target> <userlist> <passlist>\n   → Brute SMB with CME and save valid creds for multiple users"
EOF
sudo chmod +x /usr/local/bin/my_commands

# --- Step 8: Keyboard Shortcut Guidance ---
echo -e "\n[!] Don’t forget to configure keyboard shortcuts under Settings > Keyboard > Shortcuts > Navigation:"
echo -e "    Super+1 = Switch to Workspace 1"
echo -e "    Super+2 = Switch to Workspace 2"
echo -e "    Ctrl+Super+1 = Move window to Workspace 1"
echo -e "    Ctrl+Super+2 = Move window to Workspace 2"

# --- Final Notices ---
echo -e "\n[✓] Run 'my_commands' to see your available custom tools."
echo -e "\n[!] Manual step: Download Ligolo-ng from https://github.com/nicocha30/ligolo-ng/releases"
echo -e "\n[✔] Strikodot-Kali-edition setup complete. Enjoy your shell."
