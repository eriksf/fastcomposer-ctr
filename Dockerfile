FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04
LABEL maintainer="Erik Ferlanti <eferlanti@tacc.utexas.edu>"

########################################
# Configure ENV 
########################################
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

########################################
# Add OS updates
########################################
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        cuda-command-line-tools-12.1 \
        git \
        less \
        vim-tiny \
        wget \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

########################################
# Install conda
########################################
ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}
# Download and install miniforge
RUN wget -q -P /tmp https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Miniforge3-23.3.1-1-Linux-x86_64.sh \
    && bash /tmp/Miniforge3-23.3.1-1-Linux-x86_64.sh -b -p $CONDA_DIR \
    && rm /tmp/Miniforge3-23.3.1-1-Linux-x86_64.sh \
    && conda config --system --set auto_update_conda false \
    && conda config --system --set show_channel_urls true \
    && conda config --system --set default_threads 4 \
    && conda install --yes --no-update-deps python=3.9 \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && conda clean -ay

########################################
# Install PT and CUDA
########################################
RUN conda install --yes --no-update-deps -c pytorch -c nvidia \
    pytorch==2.1.0=*cuda* \
    torchaudio==2.1.0 \
    torchvision==0.16.0 \
    pytorch-cuda=12.1 \
    && conda clean -ay

########################################
# Install python reqs
########################################
RUN pip install transformers==4.25.1 \
    accelerate \
    datasets \
    evaluate \
    diffusers==0.16.1 \
    xformers \
    triton \
    scipy \
    clip \
    gradio

########################################
# Install fastcomposer
########################################
RUN pip install git+https://github.com/mit-han-lab/fastcomposer


