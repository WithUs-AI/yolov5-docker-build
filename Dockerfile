ARG base_image=pytorch/pytorch:2.0.1-cuda11.7-cudnn8-runtime
ARG timezone
FROM $base_image

ENV DEBIAN_FRONTEND=noninteractive, TZ=$timezone

RUN apt-get update && \
    apt-get -y --no-install-recommends install git build-essential python3-opencv wget vim sudo

RUN git clone https://github.com/ultralytics/yolov5 && \
    cd yolov5 && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    pip install comet_ml tensorboard onnx

RUN git config --global --add safe.directory /workspace/yolov5

ENV PYTHONPATH=/workspace/yolov5
WORKDIR /workspace/yolov5

RUN cd /workspace/yolov5 && wget https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5n.pt -q
RUN cd /workspace/yolov5 && wget https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5s.pt -q
RUN cd /workspace/yolov5 && wget https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5m.pt -q
RUN cd /workspace/yolov5 && wget https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5l.pt -q
RUN cd /workspace/yolov5 && wget https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5x.pt -q

RUN cd /workspace/yolov5 && wget https://hailo-model-zoo.s3.eu-west-2.amazonaws.com/ObjectDetection/Detection-COCO/yolo/yolov5m/pretrained/2022-04-19/yolov5m_wo_spp.pt -q

ARG user=hailo
ARG group=hailo
ARG uid=1000
ARG gid=1000

RUN groupadd --gid $gid $group && \
    adduser --uid $uid --gid $gid --shell /bin/bash --disabled-password --gecos "" $user && \
    chmod u+w /etc/sudoers && echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && chmod -w /etc/sudoers && \
    chown -R $user:$group /workspace
