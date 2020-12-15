#!/bin/bash
set -u # error on undefined
set -e # stop on error
#set -x # for debugging

# get UBUNTU_CODENAME, ROS_DISTRO
export UBUNTU_CODENAME="$(lsb_release -s -c)"
export ROS_DISTRO="noetic"

UBUNTU_RELEASE="`lsb_release -rs`"
if [[ "${UBUNTU_RELEASE}" == "14.04" ]]; then
  echo "Ubuntu 14.04 is no longer supported, please use 20.04"
  exit 1
elif [[ "${UBUNTU_RELEASE}" == "16.04" ]]; then
  echo "Ubuntu 16.04 is no longer supported, please use 20.04"
  exit 1
elif [[ "${UBUNTU_RELEASE}" == "18.04" ]]; then
  echo "Ubuntu 18.04 is no longer supported, please use 20.04"
  exit 1
elif [[ "${UBUNTU_RELEASE}" == "20.04" ]]; then
  echo "Configuring for Ubuntu 20.04 ROS Noetic"
fi

ROOT=$PWD

if [ ! -d src ]; then
  echo no src directory found, please configure workspace first and run tii_cmd from tii_ws root
  exit 1
fi

if [ ! -f /etc/ros/rosdep/sources.list.d/ros-latest.list ]; then
  echo "Adding ROS to apt"
  sudo sh -c "echo \"deb http://packages.ros.org/ros/ubuntu $UBUNTU_CODENAME main\" > /etc/apt/sources.list.d/ros-latest.list"
  wget -qO - http://packages.ros.org/ros.key | sudo apt-key add -
fi

echo "Updating package lists ..."
sudo apt-get update -y
sudo apt-get dist-upgrade -y

echo "Installing ROS $ROS_DISTRO and some dependencies..."
sudo apt-get install -y build-essential xterm ccache openssh-server sshpass python3-pip protobuf-compiler
sudo apt-get install -y ros-$ROS_DISTRO-desktop-full
sudo apt-get install -y python3-numpy python3-jinja2 python3-pandas python3-scipy python3-shapely
sudo -H pip3 install wstool rosdep vcstools catkin_tools catkin_pkg rospkg rosinstall_generator rosinstall 
sudo apt-get install -y ros-$ROS_DISTRO-geometry2 ros-$ROS_DISTRO-geographic-msgs ros-$ROS_DISTRO-gazebo-ros
sudo apt-get install -y ros-$ROS_DISTRO-mavlink ros-$ROS_DISTRO-angles ros-$ROS_DISTRO-diagnostic-msgs ros-$ROS_DISTRO-diagnostic-updater 
sudo apt-get install -y ros-$ROS_DISTRO-pcl-ros ros-$ROS_DISTRO-eigen-conversions ros-$ROS_DISTRO-nav-msgs
sudo apt-get install -y ros-$ROS_DISTRO-octomap ros-$ROS_DISTRO-octomap-msgs  ros-$ROS_DISTRO-octomap-ros
sudo apt-get install -y ros-$ROS_DISTRO-tf2-sensor-msgs ros-$ROS_DISTRO-rosconsole-bridge ros-$ROS_DISTRO-trajectory-msgs
sudo apt-get install -y ros-$ROS_DISTRO-image-proc ros-$ROS_DISTRO-urdf ros-$ROS_DISTRO-visualization-msgs ros-$ROS_DISTRO-control-toolbox
sudo apt-get install -y ros-$ROS_DISTRO-qt-gui ros-$ROS_DISTRO-python-qt-binding
sudo apt-get install -y libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-bad gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly -y
sudo apt-get install -y ros-$ROS_DISTRO-mavros ros-$ROS_DISTRO-mavros-extras ros-$ROS_DISTRO-rosbridge-server 
sudo apt-get install -y ros-$ROS_DISTRO-teleop-twist-keyboard
sudo apt-get install -y python3-pyqt5 xmlstarlet libimage-exiftool-perl

if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi

cd src
wstool update
cd ..
rosdep update

$ROOT/scripts/setprofile
source ~/.bashrc

if [ ! -d "/usr/local/include/GeographicLib" ] 
then
    cd ~/Downloads
    wget https://raw.githubusercontent.com/mavlink/mavros/master/mavros/scripts/install_geographiclib_datasets.sh
    sudo bash ./install_geographiclib_datasets.sh
    cd $ROOT
else
    echo "GeographicLib exists at /usr/local. Will not install from source."
fi

git config --global core.editor "vim"
sudo adduser $USER dialout
pip3 install grpcio grpcio-tools tsp_solver2 transforms3d toml shapely --user
pip3 install numpy zbar-py --user
pip3 install --ignore-installed psutil --user

sudo apt-get autoremove -y

#source bashrc
source ~/.bashrc
