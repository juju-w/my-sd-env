docker run -itd \
    --net host \
    -v /home/$USER/sd-data/models:/stable-diffusion-webui/models \
    -v /home/$USER/sd-data/configs:/stable-diffusion-webui/configs \
    -v /home/$USER/sd-data/data:/data \
    -v /home/$USER/sd-data/output:/stable-diffusion-webui/output \
    --gpus all \
    --runtime=nvidia \
    --name Stable-Diffusion-WebGUI \
    --restart always \
    sd-web-gpu