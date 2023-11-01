# /bin/sh
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && apt-cache policy docker-ce
curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo apt install -y docker-ce gitlab-runner=16.5.0
sudo usermod -aG docker ${USER}
wget https://gitlab.com/gitlab-org/fleeting/fleeting-plugin-aws/-/releases/v0.4.0/downloads/fleeting-plugin-aws-linux-arm64
sudo chmod +x fleeting-plugin-aws-linux-arm64  
sudo mv fleeting-plugin-aws-linux-arm64 /bin/
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update
