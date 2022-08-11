## step 1 - Install docker, the daemon.json file in line 20 is attached here
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
sudo apt install docker-compose -y
sudo cp daemon.json /etc/docker/daemon.json
sudo usermod -aG docker $USER
sudo reboot
```

## step 2 - Test nvidia + docker
```
sudo docker run --rm --gpus all nvidia/cuda:11.0.3-base-ubuntu20.04 nvidia-smi
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

# step 8 - run notebook
```
cd limo/docker
docker-compose up limo
```
You will open the http link in the web browser starting with http://127.0.0.1:<special string>


# step 9 run limo demo
Open three terminals, on the first one run a container instance
```
docker-compose run --name docker_limo_run limo bash

cd /workspace/limo_ws/
roscore &
```
On the second and third one run
```
 docker exec -ti docker_limo_run bash
 source /opt/ros/melodic/setup.bash && source /workspace/limo_ws/devel/setup.bash
```
On the second one run
```
cd /limo_data
rosbag play 04.bag -r 0.1 --pause --clock
```
To stop the container run this a separate terminal
```
docker stop docker_limo_run
docker rm docker_limo_run
```