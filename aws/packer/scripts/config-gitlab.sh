# /bin/sh

sudo apt-get update && sudo apt-get install -y gnupg software-properties-common gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update && apt-cache policy docker-ce
sudo usermod -aG docker ${USER}
wget https://gitlab.com/gitlab-org/fleeting/fleeting-plugin-aws/-/releases/v0.4.0/downloads/fleeting-plugin-aws-linux-arm64
chmod +x fleeting-plugin-aws-linux-arm64
mv fleeting-plugin-aws-linux-arm64 /bin/