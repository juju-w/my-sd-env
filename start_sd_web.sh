docker run -itd \
    --net host \
    -v /home/wkj/sd-data/models:/stable-diffusion-webui/models \
    -v /home/wkj/sd-data/configs:/stable-diffusion-webui/configs \
    -v /home/wkj/sd-data/data:/data \
    --gpus all \
    --runtime=nvidia \
    --name Stable-Diffusion-WebGUI \
    --restart always \
    sd-web-gpu