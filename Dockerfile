FROM nvidia/cuda:11.8.0-cudnn8-devel-rockylinux8

ENV http_proxy=http://172.16.18.104:20171
ENV https_proxy=http://172.16.18.104:20171

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
    && groupadd -g 996 sdgrp \
    && useradd -u 996 -m -g sdgrp sduser

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

RUN wget https://github.com/ninja-build/ninja/releases/download/v1.11.1/ninja-linux.zip \
    && unzip ninja-linux.zip -d /usr/bin/ \
    && rm -rf ninja-linux.zip \
    && chmod +x /usr/bin/ninja

RUN pip3 --no-cache-dir install --upgrade pip \
    && pip3 --no-cache-dir install --upgrade setuptools

RUN wget https://download.pytorch.org/whl/cu118/torch-2.0.1%2Bcu118-cp311-cp311-linux_x86_64.whl \
    && pip3 install --no-cache-dir ./torch-2.0.1+cu118-cp311-cp311-linux_x86_64.whl \
    && rm -rf ./torch-2.0.1+cu118-cp311-cp311-linux_x86_64.whl \
    && wget https://download.pytorch.org/whl/cu118/torchvision-0.15.2%2Bcu118-cp311-cp311-linux_x86_64.whl \
    && pip3 install --no-cache-dir ./torchvision-0.15.2+cu118-cp311-cp311-linux_x86_64.whl \
    && rm -rf ./torchvision-0.15.2+cu118-cp311-cp311-linux_x86_64.whl

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git --depth 1 \
    && cd stable-diffusion-webui \
    && git clone https://github.com/dtlnor/stable-diffusion-webui-localization-zh_CN extensions/stable-diffusion-webui-localization-zh_CN \
    && pip3 install  --no-cache-dir -r requirements_versions.txt \
    && pip3 install --no-cache-dir -r requirements.txt

RUN cd / \
    && git clone --depth=1 https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && git submodule update --init --recursive \
    && set NVCC_FLAGS=-allow-unsupported-compiler \
    && python setup.py build \
    && python setup.py bdist_wheel \
    && pip3 --no-cache-dir install dist/xformers*.whl opencv-python-headless \
    && cd .. && rm -rf xformers

WORKDIR ./stable-diffusion-webui

CMD ["python","launch.py","--share","--no-gradio-queue","--enable-insecure-extension-access","--xformers","--listen"]
