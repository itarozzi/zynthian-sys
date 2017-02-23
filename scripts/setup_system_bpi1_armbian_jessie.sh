#!/bin/bash
#******************************************************************************
# ZYNTHIAN PROJECT: Zynthian Setup Script
#
# Setup a Zynthian Box in a fresh ARMBIAN 5.25 (Jessie) installation on BananaPI M1
#
# Copyright (C) 2015-2016 Fernando Moyano <jofemodo@zynthian.org>
# Copyright (C) 2017      Ivan Tarozzi<itarozzi@gmail.com>
#
#******************************************************************************
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of
# the License, or any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# For a full copy of the GNU General Public License see the LICENSE.txt file.
#
#******************************************************************************

source zynthian_envars.sh

#------------------------------------------------
# Update System & Firmware
#------------------------------------------------

# Update System
apt-get -y update
apt-get -y upgrade
#apt-get -y dist-upgrade

# Install required dependencies if needed
apt-get -y install apt-utils
apt-get -y install sudo apt-transport-https software-properties-common htpdate parted

# Adjust System Date/Time
htpdate 0.europe.pool.ntp.org

# Update Firmware
#rpi-update

#------------------------------------------------
# Add Repositories
#------------------------------------------------

# deb-multimedia repo
echo "deb http://www.deb-multimedia.org jessie main" >> /etc/apt/sources.list
apt-get -y --force-yes install deb-multimedia-keyring
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5C808C2B65558117


# TODO: Autostatic repo works for RPI only.
# Autostatic Repo
#wget -O - http://rpi.autostatic.com/autostatic.gpg.key| apt-key add -
#wget -O /etc/apt/sources.list.d/autostatic-audio-raspbian.list http://rpi.autostatic.com/autostatic-audio-raspbian.list

#apt-get update
#apt-get -y dist-upgrade

#------------------------------------------------
# Install Required Packages
#------------------------------------------------

# System
apt-get -y install systemd dhcpcd-dbus avahi-daemon
apt-get -y install xinit xserver-xorg-video-fbdev x11-xserver-utils
apt-get -y remove isc-dhcp-client
apt-get -y remove libgl1-mesa-dri

# CLI Tools
apt-get -y install psmisc tree joe
apt-get -y install fbi scrot mpg123 p7zip-full i2c-tools

# TODO: packages not found
apt-get -y install evtest tslib libts-bin # touchscreen tools
#apt-get install python-smbus (i2c with python)

#------------------------------------------------
# Development Environment
#------------------------------------------------

#Tools
# TODO: package premake not found
#apt-get -y install build-essential git swig subversion pkg-config autoconf automake premake gettext intltool libtool libtool-bin cmake cmake-curses-gui
apt-get -y install build-essential git swig subversion pkg-config autoconf automake gettext intltool libtool libtool-bin cmake cmake-curses-gui

# Libraries
apt-get -y --force-yes install libfftw3-dev libmxml-dev zlib1g-dev libfltk1.3-dev libncurses5-dev \
liblo-dev dssi-dev libjpeg-dev libxpm-dev libcairo2-dev libglu1-mesa-dev \
libasound2-dev dbus-x11 jackd2 libjack-jackd2-dev a2jmidid laditools \
liblash-compat-dev libffi-dev fontconfig-config libfontconfig1-dev libxft-dev \
libexpat-dev libglib2.0-dev libgettextpo-dev libglibmm-2.4-dev libeigen3-dev \
libsndfile-dev libsamplerate-dev libarmadillo-dev libreadline-dev lv2-c++-tools python3-numpy-dev \
libavcodec56 libavformat56 libavutil54 libavresample2 python3-pyqt4



# wiringpi absent in Armbian repository, compile from source
cd /
git clone https://github.com/BPI-SINOVOIP/BPI-WiringPi.git -b BPI_M1_M1Plus
cd BPI-WiringPi
chmod +x ./build
./build

#libjack-dev-session
#non-ntk-dev
#libgd2-xpm-dev


# Python
apt-get -y install python-dbus
apt-get -y install python3 python3-dev python3-pip cython3 python3-cffi python3-tk python3-dbus python3-mpmath
pip3 install websocket-client
pip3 install JACK-Client

# Clean
apt-get -y autoremove

#************************************************
#------------------------------------------------
# Create Zynthian Directory Tree &
# Install Zynthian Software from repositories
#------------------------------------------------
#************************************************
mkdir $ZYNTHIAN_DIR
cd $ZYNTHIAN_DIR

# Zyncoder library
git clone https://github.com/zynthian/zyncoder.git
mkdir zyncoder/build
cd zyncoder/build
cmake ..
make




# Zynthian UI
cd $ZYNTHIAN_DIR
git clone -b $ZYNTHIAN_BRANCH --single-branch https://github.com/zynthian/zynthian-ui.git
# Exclude configuration file from git commands
cd zynthian-ui
git update-index --assume-unchanged zynthian_gui_config.py

# Zynthian System Scripts and Config files
cd $ZYNTHIAN_DIR
git clone -b $ZYNTHIAN_BRANCH --single-branch https://github.com/zynthian/zynthian-sys.git

# Zynthian Data
cd $ZYNTHIAN_DIR
git clone https://github.com/zynthian/zynthian-data.git



# Zynthian Plugins => TODO! => Rethink plugins directory!!
#git clone https://github.com/zynthian/zynthian-plugins.git

# Zynthian emuface => Not very useful here ... but somebody used it
git clone https://github.com/zynthian/zynthian-emuface.git

# Create needed directories
mkdir $ZYNTHIAN_SW_DIR
mkdir "$ZYNTHIAN_DATA_DIR/soundfonts"
mkdir "$ZYNTHIAN_DATA_DIR/soundfonts/sf2"
mkdir "$ZYNTHIAN_DATA_DIR/soundfonts/sfz"
mkdir "$ZYNTHIAN_DATA_DIR/soundfonts/gig"
mkdir $ZYNTHIAN_MY_DATA_DIR
mkdir "$ZYNTHIAN_MY_DATA_DIR/zynbanks"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts/sf2"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts/sfz"
mkdir "$ZYNTHIAN_MY_DATA_DIR/soundfonts/gig"
mkdir "$ZYNTHIAN_MY_DATA_DIR/snapshots"
mkdir "$ZYNTHIAN_MY_DATA_DIR/mod-pedalboards"
mkdir $ZYNTHIAN_PLUGINS_DIR
mkdir "$ZYNTHIAN_PLUGINS_DIR/lv2"
mkdir $ZYNTHIAN_MY_PLUGINS_DIR
mkdir "$ZYNTHIAN_MY_PLUGINS_DIR/lv2"



# Copy some files
cp -a $ZYNTHIAN_DATA_DIR/mod-pedalboards/*.pedalboard $ZYNTHIAN_MY_DATA_DIR/mod-pedalboards

#************************************************
#------------------------------------------------
# System Adjustments
#------------------------------------------------
#************************************************

#Change Hostname
echo "zynthian" > /etc/hostname
sed -i -e "s/bananapi/zynthian/" /etc/hosts




# Copy "boot" config files
# TODO:   verificafre se e come gestire i parametri di boot!!!!!
#cp $ZYNTHIAN_SYS_DIR/boot/* /boot
#sed -i -e "s/#AUDIO_DEVICE_DTOVERLAY/dtoverlay=hifiberry-dacplus/g" /boot/config.txt



# Copy "etc" config files
#TODO:   i moduli contenuti nel file modules di zynthian non sono presenti in Amrbian per BPI, e sovrascriverebbero quelli presenti
# versificare quindi se occorre aggiungere l'equivalente dei seguenti moduli
#stmpe-ts
#i2c-dev
#cp $ZYNTHIAN_SYS_DIR/etc/modules /etc

#TODO: Armbian non sembra avere il file /etc/inittab !!!!
#cp $ZYNTHIAN_SYS_DIR/etc/inittab /etc

#TODO: verificare se questo file dbus viene processato!
cp $ZYNTHIAN_SYS_DIR/etc/dbus-1/* /etc/dbus-1

cp $ZYNTHIAN_SYS_DIR/etc/systemd/* /etc/systemd/system/

#TODO: verificare.... a cosa serve???
cp $ZYNTHIAN_SYS_DIR/etc/udev/rules.d/* /etc/udev/rules.d

# Systemd Services
systemctl daemon-reload
systemctl enable dhcpcd
systemctl enable avahi-daemon
#systemctl disable raspi-config
systemctl disable cron
systemctl disable rsyslog
systemctl disable ntp
systemctl disable triggerhappy
#systemctl disable serial-getty@ttyAMA0.service
#systemctl disable sys-devices-platform-soc-3f201000.uart-tty-ttyAMA0.device
systemctl enable backlight
systemctl enable cpu-performance
systemctl enable splash-screen
systemctl enable jack2
systemctl enable mod-ttymidi
systemctl enable zynthian



# X11 Config
#mkdir /etc/X11/xorg.conf.d     #Already exists
cp $ZYNTHIAN_SYS_DIR/etc/X11/xorg.conf.d/99-calibration.conf /etc/X11/xorg.conf.d
cp $ZYNTHIAN_SYS_DIR/etc/X11/xorg.conf.d/99-pitft.conf /etc/X11/xorg.conf.d

# Copy fonts to system directory
cp -rf $ZYNTHIAN_UI_DIR/fonts/* /usr/share/fonts/truetype


# User Config (root) =>
# Set Zynthian Environment variables ...
echo "source /zynthian/zynthian-sys/scripts/zynthian_envars.sh" >> /root/.bashrc
# => Shell & Login Config
echo "source $ZYNTHIAN_SYS_DIR/etc/profile.zynthian" >> /root/.profile
# => ZynAddSubFX Config
cp $ZYNTHIAN_SYS_DIR/etc/zynaddsubfxXML.cfg /root/.zynaddsubfxXML.cfg

# Resize SD partition on first boot
#sed -i -- "s/exit 0/\/zynthian\/zynthian-sys\/scripts\/rpi-wiggle\.sh/" /etc/rc.local
echo "exit 0" >> /etc/rc.local

#************************************************
#------------------------------------------------
# Compile / Install Required Libraries
#------------------------------------------------
#************************************************

#------------------------------------------------
# Install Alsaseq Python Library
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
wget http://pp.com.mx/python/alsaseq/alsaseq-0.4.1.tar.gz
tar xfvz alsaseq-0.4.1.tar.gz
cd alsaseq-0.4.1
python3 setup.py install
cd ..
rm -f alsaseq-0.4.1.tar.gz

#------------------------------------------------
# Install NTK (http://non.tuxfamily.org/ntk/)
#------------------------------------------------
git clone git://git.tuxfamily.org/gitroot/non/fltk.git ntk
cd ntk
./waf configure
./waf
./waf install



#------------------------------------------------
# Install pyliblo (liblo OSC library for Python)
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/dsacre/pyliblo.git
cd pyliblo
python3 ./setup.py build
python3 ./setup.py install

#------------------------------------------------
# Install mod-ttymidi (MOD's version!)
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/moddevices/mod-ttymidi.git
cd mod-ttymidi
make install

#------------------------------------------------
# Install LV2 lilv library
#------------------------------------------------
sh $ZYNTHIAN_RECIPE_DIR/install_lv2_lilv.sh # throws an error at the end - ignore it!

#------------------------------------------------
# Install Aubio Library & Tools
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
git clone https://github.com/aubio/aubio.git
cd aubio
make -j 4
cp -fa ./build/src/libaubio* /usr/local/lib
cp -fa ./build/examples/aubiomfcc /usr/local/bin
cp -fa ./build/examples/aubionotes /usr/local/bin
cp -fa ./build/examples/aubioonset /usr/local/bin
cp -fa ./build/examples/aubiopitch /usr/local/bin
cp -fa ./build/examples/aubioquiet /usr/local/bin
cp -fa ./build/examples/aubiotrack /usr/local/bin

#------------------------------------------------
# Install jpmidi (MID player for jack with transport sync)
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
wget http://juliencoder.de/jpmidi/jpmidi-0.2.tar.gz
tar xfvz jpmidi-0.2.tar.gz
cd jpmidi
./configure
make -j 4
cp /src/jpmidi /usr/local/bin
cd ..
rm -f jpmidi-0.2.tar.gz


#************************************************
#------------------------------------------------
# Compile / Install Synthesis Software
#------------------------------------------------
#************************************************

#------------------------------------------------
# Install zynaddsubfx
#------------------------------------------------
apt-get -y install
bash $ZYNTHIAN_RECIPE_DIR/install_zynaddsubfx.sh

#------------------------------------------------
# Install Fluidsynth & SondFonts
#------------------------------------------------
apt-get -y install fluidsynth fluid-soundfont-gm fluid-soundfont-gs

# Create SF2 soft links
cd $ZYNTHIAN_DATA_DIR/soundfonts/sf2
ln -s /usr/share/sounds/sf2/*.sf2 .

#------------------------------------------------
# Install Linuxsampler => TODO Upgrade to Version 2
#------------------------------------------------

#TODO: linuxsampler not present in armbian repository, need to compile
#apt-get -y install linuxsampler


cd $ZYNTHIAN_SW_DIR
wget --no-check-certificate http://download.linuxsampler.org/packages/libgig-4.0.0.tar.bz2
tar xvf libgig-4.0.0.tar.bz2
cd libgig-4.0.0
./configure
make -j 4
make install
cd ..

apt-get -y install bison libatomic-ops-dev
wget --no-check-certificate http://download.linuxsampler.org/packages/linuxsampler-2.0.0.tar.bz2
tar xvf linuxsampler-2.0.0.tar.bz2
cd linuxsampler-2.0.0/


#TODO : sqlite into repo is 2.8
#*** Required sqlite version not found!
#*** You need to have sqlite version 3.3 or higher for instruments database support to be enabled.
#*** Support for instruments DB will be disabled!
./configure

#TODO: need to patch the file src/common/RTMath.cpp
# see: https://sourceforge.net/p/linuxsampler/mailman/message/32878699/

#TODO: need to patch the file src/common/atomic.h
#  see https://www.mail-archive.com/linuxsampler-devel@lists.sourceforge.net/msg01228.html
#  see https://www.raspberrypi.org/forums/viewtopic.php?t=37011&p=943685

#TODO : remove lscpparser, regenerated on make phase
mv src/network/lscpparser.cpp src/network/lscpparser.cpp__

make -j 4
make install

#------------------------------------------------
# Install Fantasia (linuxsampler Java GUI)
#------------------------------------------------
cd $ZYNTHIAN_SW_DIR
mkdir fantasia
cd fantasia
wget --no-check-certificate http://downloads.sourceforge.net/project/jsampler/Fantasia/Fantasia%200.9/Fantasia-0.9.jar
# java -jar ./Fantasia-0.9.jar

#------------------------------------------------
# Install setBfree
#------------------------------------------------
sh $ZYNTHIAN_RECIPE_DIR/install_setbfree.sh

#TODO: verificar se ok che la GUI non venga compilata e installata
#Makefile:19: "Synth GUI will not be built"
#Makefile:20: "either openGL/GLU is not available - install glu-dev, ftgl-dev"
#Makefile:21: "or /usr/share/fonts/truetype/ttf-bitstream-vera/VeraBd.ttf cannot be found"


#------------------------------------------------
# Install MOD stuff
#------------------------------------------------
cd $ZYNTHIAN_SYS_DIR/scripts
./setup_mod.sh

###   .................. to be continued !!!


#------------------------------------------------
# Install Plugins
#------------------------------------------------
cd $ZYNTHIAN_SYS_DIR/scripts
./setup_plugins_rbpi.sh
