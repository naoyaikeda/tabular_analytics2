FROM jupyter/scipy-notebook
USER root
LABEL maintainer="Naoya Ikeda <n_ikeda@hotmail.com>"
COPY azcopy_linux_amd64_10.2.1/azcopy /usr/local/bin
ENV ACCEPT_EULA=Y
ENV TMPDIR=/tmp
RUN echo "now building..." && \

    cd /root && \
    apt update && \
    apt install -y git gnupg curl wget cmake gfortran unzip libsm6 pandoc libjpeg-dev && \
    apt install -y lsb-release build-essential libssl-dev libc6-dev libicu-dev apt-file libxrender1 && \
    apt install -y texlive-latex-base texlive-latex-extra texlive-fonts-extra texlive-fonts-recommended texlive-generic-recommended && \
    apt install -y fonts-ipafont-gothic fonts-ipafont-mincho && \
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list && \
    apt update && \
    apt install -y vim openjdk-11-jdk libv8-3.14-dev libxml2-dev libcurl4-openssl-dev libssl-dev unixodbc freetds-bin freetds-common tdsodbc unixodbc-dev mssql-tools && \
    conda update -n base -c defaults conda -y && \
    conda install -y python=3.6 rise pyodbc pymssql -y && \
    jupyter-nbextension install rise --py --sys-prefix && \
    jupyter-nbextension enable rise --py --sys-prefix && \
    conda install -y -c anaconda mysql-connector-python psycopg2 && \
    conda install -y -c h2oai h2o && \
    conda install -y -c conda-forge xgboost lightgbm fbprophet lime shap && \
    wget https://mran.blob.core.windows.net/install/mro/3.5.3/ubuntu/microsoft-r-open-3.5.3.tar.gz && \
    tar -xf microsoft-r-open-3.5.3.tar.gz && \
    cd microsoft-r-open/ && \
    ./install.sh -a -u

RUN cd /root && \
    ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    wget https://github.com/unicode-org/icu/archive/release-58-3.tar.gz && \
    tar xvzf release-58-3.tar.gz && \
    cd icu-release-58-3/icu4c/source && \
    ./configure && \
    make && \
    make install && \
    ldconfig /etc/ld.so.conf.d

RUN cd /root && \
    wget https://julialang-s3.julialang.org/bin/linux/x64/1.2/julia-1.2.0-linux-x86_64.tar.gz && \
    tar xzf julia-1.2.0-linux-x86_64.tar.gz -C /opt

RUN ln -fs /opt/julia-1.2.0/bin/julia /usr/local/bin/julia

RUN R -e "install.packages('devtools', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RODBC', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('glmnet', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rpart', dependencies=TRUE, repos='http://cran.rstudio.com/')"
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
RUN R -e "install.packages('RUnit', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('BiocManager', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('reticulate', dependencies=TRUE, repos='http://cran.rstudio.com/')"
ADD rconf.R .
RUN Rscript rconf.R && \
    R -e "install.packages('prophet', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('rstanarm', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinystan', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install(c('graph', 'RBGL'))" 
RUN R -e "install.packages('dlm', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('KFAS', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('bsts', dependencies=TRUE, repos='http://cran.rstudio.com/')" 
RUN R -e "install.packages('pcalg', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('CausalImpact', dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "devtools::install_github('Laurae2/lgbdl')"
RUN R -e "install.packages(c('repr', 'IRdisplay', 'evaluate', 'crayon', 'pbdZMQ', 'uuid', 'digest'), dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
    R -e "devtools::install_github('IRkernel/IRkernel')" && \
    R -e "IRkernel::installspec(user = FALSE)"

RUN cd /root && \
    git clone --recursive https://github.com/microsoft/LightGBM && \
    cd LightGBM && \
    Rscript build_r.R

RUN pip install optuna && \
    pip install rpy2

RUN curl -L  "https://oscdl.ipa.go.jp/IPAexfont/ipaexg00301.zip" > font.zip && \
    unzip font.zip && \
    cp ipaexg00301/ipaexg.ttf /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/fonts/ttf/ipaexg.ttf && \
    echo "font.family : IPAexGothic" >>  /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
    rm -r ./.cache
