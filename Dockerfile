FROM jupyter/tensorflow-notebook

USER root

#Julialang
RUN mkdir /julia && \
    cd /julia && \
    wget -O julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/1.8/julia-1.8.1-linux-x86_64.tar.gz && \
    tar -xzvf julia.tar.gz && \
    ln -s /julia/julia-1.8.1/bin/julia /bin/julia

USER jovyan

RUN julia -e 'using Pkg; \
    Pkg.add("IJulia"); \
    Pkg.add("Plots"); \
    Pkg.add("CUDA"); \
    Pkg.add("Flux"); \
    Pkg.add("Clp"); \
    Pkg.add("Cbc"); \
    Pkg.add("GLPK"); \
    Pkg.add("JuMP"); \
    Pkg.add("HiGHS"); \
    Pkg.add("Ipopt");'