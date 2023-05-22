# stable diffusion webgui gpu docker
my env information:

 ubuntu22.04



- install latest nvidia dirvser / CUDA ToolKit  >= 11.8.0

- install docker 

- install nvidia-docker  *** makesuer your system need support nvidia-docker(very importent)***



Dockerfile

```dockerfile
FROM nvidia/cuda:11.8.0-cudnn8-devel-rockylinux8

# set http/https proxy
ENV http_proxy=http://192.168.1.100:20171
ENV https_proxy=http://192.168.1.100:20171

# update and install compile tools and devel lib
RUN sed -e 's|^mirrorlist=|#mirrorlist=|g' -e 's|^#baseurl=http://dl.rockylinux.org/$contentdir|baseurl=https://mirrors.sjtug.sjtu.edu.cn/rocky|g' -i.bak /etc/yum.repos.d/Rocky*.repo \
    && dnf makecache \
    && dnf groupinstall "Development tools" -y \
    && dnf install -y \
        wget \
        openssl \
        openssl-devel \
        libffi-devel \
        tar \
        git \
        bzip2-devel \
        which \
        unzip \
    && dnf clean all \
    && rm -rf /var/cache/yum/* \
    && groupadd -g 1996 sdgrp \
    && useradd -u 1996 -m -g sdgrp sduser

# download and build python 3.11.3 sorcecode
RUN wget "https://www.python.org/ftp/python/3.11.3/Python-3.11.3.tgz" \
    && tar xf Python-3.11.3.tgz \
    && cd Python-3.11.3 \
    && ./configure --prefix=/usr/local/python311 --enable-shared --with-ssl \
    && mkdir -p /usr/local/python311 \
    && make -j8 \
    && make install \
    && ln -s /usr/local/python311/bin/python3 /usr/bin/python3 \
    && ln -s /usr/local/python311/bin/python3 /usr/bin/python \
    && ln -s /usr/local/python311/bin/pip3 /usr/bin/pip3 \
    && ln -s /usr/local/python311/bin/pip /usr/bin/pip \
    && cd .. \
    && rm -rf Python-3.11.3.tgz Python-3.11.3 \
    && echo "/usr/local/python311/lib" > /etc/ld.so.conf.d/python3.conf \
    && ldconfig

# install ninja (for building xformers incase)
RUN wget https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip \
    && unzip ninja-linux.zip -d /usr/bin/ \
    && rm -rf ninja-linux.zip \
    && chmod +x /usr/bin/ninja

# update pip setuptools
RUN pip3 --no-cache-dir install --upgrade pip \
    && pip3 --no-cache-dir install --upgrade setuptools

# install torch torchvision --> cuda11.8
RUN wget https://download.pytorch.org/whl/cu118/torch-2.0.1%2Bcu118-cp311-cp311-linux_x86_64.whl \
    && pip3 install --no-cache-dir ./torch-2.0.1+cu118-cp311-cp311-linux_x86_64.whl \
    && rm -rf ./torch-2.0.1+cu118-cp311-cp311-linux_x86_64.whl \
    && wget https://download.pytorch.org/whl/cu118/torchvision-0.15.2%2Bcu118-cp311-cp311-linux_x86_64.whl \
    && pip3 install --no-cache-dir ./torchvision-0.15.2+cu118-cp311-cp311-linux_x86_64.whl \
    && rm -rf ./torchvision-0.15.2+cu118-cp311-cp311-linux_x86_64.whl

# get stable diffusion webui and install extensions/
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git --depth 1 \
    && cd stable-diffusion-webui \
    && git clone https://github.com/dtlnor/stable-diffusion-webui-localization-zh_CN extensions/stable-diffusion-webui-localization-zh_CN \
    && pip3 install  --no-cache-dir -r requirements_versions.txt \
    && pip3 install --no-cache-dir -r requirements.txt

# install xformers
RUN pip3 install --no-cache-dir xformers==0.0.20.dev539 opencv-python-headless

WORKDIR ./stable-diffusion-webui

CMD ["python","launch.py","--share","--no-gradio-queue","--enable-insecure-extension-access","--xformers","--listen"]

```

use command below to build image

```shell
docker build -t sd-web-gpu .
```

start sd web gui docker 

```shell
bash start_sd_web.sh
```

```shell
docker run -itd \
    --net host \
    -v /home/$USER/sd-data/models:/stable-diffusion-webui/models \
    -v /home/$USER/sd-data/configs:/stable-diffusion-webui/configs \
    -v /home/$USER/sd-data/data:/data \
    -v /home/$USER/sd-data/outputs:/stable-diffusion-webui/outputs \
    --gpus all \
    --runtime=nvidia \
    --name Stable-Diffusion-WebGUI \
    --restart always \
    sd-web-gpu
```

