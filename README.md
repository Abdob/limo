## step 1 - Install docker

install prereqs
```
sudo apt install git curl
```

if docker was installed before using
https://docs.docker.com/engine/install/ubuntu/
uninstall it
```
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin
```


The following is installation based on https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

```
curl https://get.docker.com | sh \
  && sudo systemctl --now enable docker
```
```
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
      && curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
            sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
            sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
```

```
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
sudo cp daemon.json /etc/docker/daemon.json
sudo usermod -aG docker $USER
sudo reboot
```

Note: if you have docker-compose version 1.25.0
```
docker-compose --version
docker-compose version 1.25.0, build unknown
```
Uninstall using 
```
sudo apt purge docker-compose
```
Install docker compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
close and reopen terminal you will see
```
docker-compose --version
docker-compose version 1.29.2, build 5becea4c
```

## step 2 - Test nvidia + docker
```
docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
```

## step 3 - Download dataset 
```
mkdir ~/limo_data
```

Download and place the six files in ~/limo_data and unzip each one, the link is:
http://www.cvlibs.net/datasets/kitti/eval_odometry.php

```
mv ~/Downloads/<file_name>.zip ~/limo_data
mv ~/Downloads/<file_name>.zip ~/limo_data
..
..
```
```
cd limo_data

unzip <filename>.zip 
unzip <filename>.zip 
..
..
```
Once you are done unzipping, unzip data_odometry_calib.zip again to make sure the correct calibration files were not overwritten.

Download 01.bag and 04.bag and place them in /limo_data

## step 4 - Build the semantic container
```
git clone https://github.com/Abdob/semantic-segmentation.git
cd semantic-segmentation
./docker_build.sh
```
## step 5 - Download semantic model
place the model in semantic-segmentation
https://drive.google.com/file/d/1OrTcqH_I3PHFiMlTTZJgBy8l_pladwtg/view?usp=sharing

## step 6 - Run the docker container
```
cd semantic-segmentation
./docker_run.h
```
# step 7 - Build limo container
```
git clone https://github.com/abdob/limo
cd limo/docker
docker-compose build limo
```
If the build fails comment or comment out line 86 and 97 from src/Dockerfile

# step 8 - run notebook
```
cd limo/docker
docker-compose up limo
```
You will open the http link in the web browser starting with http://127.0.0.1:<special string>


# step 9 run limo demo
Open three terminals, on the first one run a container instance
```
docker rm docker_limo_run
xhost +
docker-compose run --name docker_limo_run limo bash
```

On the second one run
```
docker exec -ti docker_limo_run bash
source /opt/ros/melodic/setup.bash && source /workspace/limo_ws/devel/setup.bash
roscore &
```
press enter a couple times to return to bash


On the second one run
```
cd /workspace/limo_ws
roslaunch demo_keyframe_bundle_adjustment_meta kitti_standalone.launch
```


on the third one
```
docker exec -ti docker_limo_run bash
source /opt/ros/melodic/setup.bash && source /workspace/limo_ws/devel/setup.bash
cd /limo_data
rosbag play 01.bag -r 0.2 --pause --clock

```
on the first one
```
source /opt/ros/melodic/setup.bash && source /workspace/limo_ws/devel/setup.bash
cd /workspace/limo_ws
rviz -d src/limo/demo_keyframe_bundle_adjustment_meta/res/default.rviz 
```
press space on the terminal playing the rosbag
when done move the results to the host
```
cp /tmp/poses_dump.txt /limo_data
```
To stop the container run this a separate terminal
```
docker stop docker_limo_run
docker rm docker_limo_run
```
