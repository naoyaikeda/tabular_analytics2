FROM jupyter/scipy-notebook
USER root
LABEL maintainer="Naoya Ikeda <n_ikeda@hotmail.com>"
COPY azcopy_linux_amd64_10.2.1/azcopy /usr/local/bin
ENV ACCEPT_EULA=Y
RUN echo "now building..." && \
    cd /root && \
    apt update && \
    apt install -y gnupg && \
    apt install -y curl && \
    apt install -y wget && \
    curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list && \
    apt update && \
    apt install -y vim openjdk-11-jdk libv8-3.14-dev libxml2-dev libcurl4-openssl-dev libssl-dev unixodbc freetds-bin freetds-common tdsodbc unixodbc-dev mssql-tools && \
    conda update -n base -c defaults conda -y && \
    conda install python=3.6 rise pyodbc pymssql -y && \
    jupyter-nbextension install rise --py --sys-prefix && \
    jupyter-nbextension enable rise --py --sys-prefix && \
    conda install -c h2oai h2o && \
    conda install -c conda-forge xgboost lightgbm fbprophet lime shap && \
    wget https://mran.blob.core.windows.net/install/mro/3.5.3/ubuntu/microsoft-r-open-3.5.3.tar.gz && \
    tar -xf microsoft-r-open-3.5.3.tar.gz && \
    cd microsoft-r-open/ && \
    ./install.sh -a -s
RUN pip install optuna

RUN curl -L  "https://oscdl.ipa.go.jp/IPAexfont/ipaexg00301.zip" > font.zip && \
    unzip font.zip && \
    cp ipaexg00301/ipaexg.ttf /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/fonts/ttf/ipaexg.ttf && \
    echo "font.family : IPAexGothic" >>  /opt/conda/lib/python3.6/site-packages/matplotlib/mpl-data/matplotlibrc && \
    rm -r ./.cache
