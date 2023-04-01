echo "Installing packages"
sudo apt-get update
sudo apt-get install -y git bc bison flex libssl-dev make

echo "cloning linux"
git clone --depth=1 https://github.com/raspberrypi/linux


cd linux
echo "Configuring the kernel"
KERNEL=kernel7l
make bcm2711_defconfig
echo "CONFIG_NETFILTER_TPROXY=m" >> .config
echo "CONFIG_NETFILTER_XT_TARGET_TPROXY=m" >> .config

echo "Creating the package and installing, take a breath as this will take a while. You can come back later :)"
sleep 5
make 
sudo make modules_install
sudo cp arch/arm/boot/zImage /boot/$KERNEL.img


read -p "Reboot your Raspberry Pi now to apply the changes (y/n)? " choice
case "$choice" in
  y|Y ) sudo reboot;;
  n|N ) echo "Remember to reboot your Raspberry Pi later to apply the changes.";;
  * ) echo "Invalid input. Remember to reboot your Raspberry Pi later to apply the changes.";;
esac
