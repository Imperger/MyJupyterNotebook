FROM jupyterhub/jupyterhub
ARG user

RUN useradd -m ${user} && \
    echo ${user}:${user} | chpasswd

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y wget && \
    apt-get install -y  --allow-unauthenticated libgtk2.0-dev && \
    apt-get install -y tesseract-ocr libtesseract-dev

RUN pip install --upgrade pip && \
    pip install jupyter pandas numpy scipy chart-studio plotly gmaps googlemaps opencv-python pillow pytesseract tensorflow matplotlib

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
