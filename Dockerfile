FROM jupyterhub/jupyterhub
ARG user

RUN useradd -m ${user} && \
    echo ${user}:${user} | chpasswd

RUN pip install --upgrade pip && \
    pip install jupyter pandas numpy scipy plotly gmaps googlemaps opencv-python pillow pytesseract

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y  --allow-unauthenticated libgtk2.0-dev && \
    apt-get install -y tesseract-ocr libtesseract-dev

RUN jupyter nbextension enable --py --sys-prefix gmaps

#Julialang
RUN mkdir /julia && \
    cd /julia && \
    wget -O julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.0/julia-1.0.1-linux-x86_64.tar.gz && \
    tar -xzvf julia.tar.gz && \
    ln -s /julia/julia-1.0.1/bin/julia /bin/julia

RUN julia -e 'using Pkg; Pkg.add("IJulia"); Pkg; Pkg.add("Plots"); Pkg.add("PyPlot"); Pkg.build("PyPlot")'

CMD ["jupyterhub", "--port", "80"]