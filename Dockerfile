FROM ubuntu:20.04

WORKDIR /app

RUN apt-get update && apt-get -y install wget
RUN apt-get update && apt-get -y install git
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py310_24.7.1-0-Linux-x86_64.sh
RUN bash Miniconda3-py310_24.7.1-0-Linux-x86_64.sh -b -p /opt/conda
ENV PATH /opt/conda/bin:$PATH
RUN conda create -n conceptgraph anaconda python=3.10

# Activate the environment (sort of)
ENV CONDA_DEFAULT_ENV conceptgraph
ENV CONDA_PREFIX /opt/conda/envs/conceptgraph
ENV PATH /opt/conda/envs/conceptgraph/bin:$PATH


RUN conda install pytorch==2.0.1 torchvision==0.15.2 torchaudio==2.0.2 cpuonly -c pytorch
# Install the Faiss library (CPU version should be fine), this is used for quick indexing of pointclouds for duplicate object matching and merging
RUN conda install -c pytorch faiss-cpu=1.7.4 mkl=2021 blas=1.0=mkl
# Install Pytorch3D (https://github.com/facebookresearch/pytorch3d/blob/main/INSTALL.md)
# install dependencies for torch3d
RUN conda install -c conda-forge gxx
RUN conda install -c conda-forge yacs
RUN conda install -c iopath iopath
# build pytorch3d from source
# RUN mkdir concept_graph_code && cd concept_graph_code
RUN git clone https://github.com/facebookresearch/pytorch3d.git
RUN cd pytorch3d && pip install -e .
# RUN conda install https://anaconda.org/pytorch3d/pytorch3d/0.7.4/download/linux-64/pytorch3d-0.7.4-py310_cu118_pyt201.tar.bz2

# We find that cuda development toolkit is the least problemantic way to install cuda.
# Make sure the version you install is at least close to your cuda version.
# See here: https://anaconda.org/conda-forge/cudatoolkit-dev
# RUN conda install -c conda-forge cudatoolkit-dev
# /opt/conda/envs/conceptgraph
# Install the other required libraries
RUN pip install tyro open_clip_torch wandb h5py openai hydra-core distinctipy ultralytics dill supervision open3d imageio natsort kornia rerun-sdk pyliblzfse pypng git+https://github.com/ultralytics/CLIP.git

# Finally install conceptgraphs
RUN git clone https://github.com/concept-graphs/concept-graphs.git
RUN cd ./concept-graphs && git checkout ali-dev && pip install -e .