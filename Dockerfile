FROM jupyterhub/jupyterhub
ARG user

RUN useradd -m ${user} && \
    echo ${user}:${user} | chpasswd

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y wget software-properties-common && \
    apt-get install -y  --allow-unauthenticated libgtk2.0-dev && \
    apt-get install -y tesseract-ocr libtesseract-dev


# Add NVIDIA package repositories
RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin && \
    mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub && \
    add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/ /" && \
    apt-get update

RUN wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb && \
    apt install ./nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb && \
    apt-get update


RUN wget https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/libnvinfer7_7.1.3-1+cuda11.0_amd64.deb && \
    apt install -y ./libnvinfer7_7.1.3-1+cuda11.0_amd64.deb && \
    apt-get update

# Install TensorRT. Requires that libcudnn8 is installed above.
RUN apt-get install -y --no-install-recommends libnvinfer7=7.1.3-1+cuda11.0 \
    libnvinfer-dev=7.1.3-1+cuda11.0 \
    libnvinfer-plugin7=7.1.3-1+cuda11.0

RUN pip install --upgrade pip && \
    pip install jupyter pandas numpy scipy chart-studio plotly gmaps googlemaps opencv-python pillow pytesseract matplotlib nvidia-pyindex

RUN pip install nvidia-tensorflow[horovod]

RUN jupyter nbextension enable --py --sys-prefix gmaps


#Julialang
RUN mkdir /julia && \
    cd /julia && \
    wget -O julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.1-linux-x86_64.tar.gz && \
    tar -xzvf julia.tar.gz && \
    ln -s /julia/julia-1.6.1/bin/julia /bin/julia

USER ${user}

RUN julia -e 'using Pkg; Pkg.add("IJulia");'
RUN julia -e 'using Pkg; Pkg.add("Plots");'

USER root

RUN chown ${user}:${user} /srv/jupyterhub

COPY bin/start_jupyter /usr/local/bin/
RUN chmod +x /usr/local/bin/start_jupyter

RUN mv /home/${user} /home/_${user}

USER ${user}

CMD ["start_jupyter"]
