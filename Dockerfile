FROM jupyter/scipy-notebook
USER root
LABEL maintainer="Naoya Ikeda <n_ikeda@hotmail.com>"
COPY azcopy_linux_amd64_10.2.1/azcopy /usr/local/bin
RUN mkdir /home/jovyan/.R
RUN mkdir /root/.R
ADD Makevars /home/jovyan/.R
ADD Makevars /root/.R
ENV ACCEPT_EULA=Y
ENV TMPDIR=/tmp

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia
ENV JULIA_PKGDIR=/opt/julia
ENV JULIA_VERSION=1.2.0

RUN echo "now building..." && \
    cd /root && \
    apt update && \
    apt install -y git gnupg curl wget cmake gfortran unzip libsm6 pandoc libjpeg-dev libgsl-dev libunwind-dev libgmp3-dev　libfontconfig1-dev libudunits2-dev libgeos-dev　libmagick++-dev && \
    apt install -y lsb-release build-essential libssl-dev libc6-dev libicu-dev apt-file libxrender1 && \
    apt install -y texlive-latex-base texlive-latex-extra texlive-fonts-extra texlive-fonts-recommended texlive-generic-recommended && \
    apt install -y fonts-ipafont-gothic fonts-ipafont-mincho && \
    apt install -y vim default-jdk libv8-3.14-dev libxml2-dev libcurl4-openssl-dev libssl-dev && \
    apt install -y xorg libx11-dev libglu1-mesa-dev libfreetype6-dev && \
    apt clean && \
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list && \
    apt update && \
    apt install -y  unixodbc freetds-bin freetds-common tdsodbc unixodbc-dev mssql-tools && \
    apt clean && \
    conda update -n base -c defaults conda -y && \
    conda install -y python=3.6 rise pyodbc pymssql -y && \
    jupyter-nbextension install rise --py --sys-prefix && \
    jupyter-nbextension enable rise --py --sys-prefix && \
    conda install -y -c anaconda mysql-connector-python psycopg2 bokeh pillow pytz patsy python-dateutil networkx pygraphviz cython sphinx && \
    conda install -y -c h2oai h2o && \
    conda install -y -c conda-forge xgboost lightgbm fbprophet lime shap plotly tqdm chardet pulp python-igraph && \
    wget https://mran.blob.core.windows.net/install/mro/3.5.3/ubuntu/microsoft-r-open-3.5.3.tar.gz && \
    tar -xf microsoft-r-open-3.5.3.tar.gz && \
    cd microsoft-r-open/ && \
    ./install.sh -a -u && \
    apt clean

RUN cd /root && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    wget https://github.com/unicode-org/icu/archive/release-58-3.tar.gz && \
    tar xvzf release-58-3.tar.gz && \
    cd icu-release-58-3/icu4c/source && \
    ./configure && \
    make && \
    make install && \
    ldconfig /etc/ld.so.conf.d

RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "926ced5dec5d726ed0d2919e849ff084a320882fb67ab048385849f9483afc47 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-*/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    fix-permissions $JULIA_PKGDIR

RUN R -e "install.packages('devtools', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RCurl', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RODBC', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('caret', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('VGAM', dependencies=TRUE, repos='http://cran.rstudio.com/')"
#RUN R -e "install.packages('fuzzyreg', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('mgcv', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('forecast', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('beyesm', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('quantreg', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('brms', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('MCMCpack', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('dlookr', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('MLmetrics', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('glmnet', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rpart', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('randomForest', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('cluster', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('e1071', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('flexmix', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('mclust', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('fpc', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('mvtnorm', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('MASS', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('kernlab', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('Spectrum', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('xgboost', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tseries', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tseriesChaos', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('survival', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('fitdistrplus', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggExtra', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidytext', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('GGally', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('BNSL', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('V8', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('huge', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('Matrix', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('lme4', dependencies=TRUE, repos='http://cran.rstudio.com')"
RUN R -e "install.packages('h2o', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('nnet', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('lime', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('RUnit', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('reticulate', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('prophet', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rstanarm', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinystan', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(c('graph', 'RBGL'))" 
RUN R -e "install.packages('dlm', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('KFAS', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('bsts', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('pcalg', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('CausalImpact', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "devtools::install_github('Laurae2/lgbdl')"
RUN R -e "devtools::install_github('rstudio/r2d3')"
RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'uuid', 'digest'), dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "devtools::install_github('IRkernel/IRkernel')" && \
    R -e "IRkernel::installspec(user = FALSE)"

RUN cd /root && \
    git clone --recursive https://github.com/microsoft/LightGBM && \
    cd LightGBM && \
    Rscript build_r.R

RUN pip install optuna && \
    pip install rpy2 && \
    pip install pyunicorn && \
    pip install pyflux

RUN curl -L  "https://oscdl.ipa.go.jp/IPAexfont/ipaexg00301.zip" > font.zip && \
    unzip font.zip && \
    cp ipaexg00301/ipaexg.ttf /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/fonts/ttf/ipaexg.ttf && \
    echo "font.family : IPAexGothic" >>  /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
    rm -r ./.cache

USER $NB_UID

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.
RUN julia -e 'import Pkg; Pkg.update()' && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")')
USER root
RUN julia -e "using Pkg; pkg\"add IJulia\"; pkg\"precompile\"" && \
    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local && \
    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter
