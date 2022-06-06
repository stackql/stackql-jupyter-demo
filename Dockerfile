FROM jupyter/base-notebook:latest

WORKDIR /work

USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git && \
    apt-get install -y unzip

RUN git clone https://github.com/stackql/pystackql
RUN wget --no-verbose https://releases.stackql.io/stackql/latest/stackql_linux_amd64.zip && \
    unzip stackql_linux_amd64.zip && \
    mv stackql /bin/stackql && \
    chmod +x /bin/stackql && \
    rm stackql_linux_amd64.zip

COPY ./keys /keys
COPY ./example.ipynb /work

RUN chmod 644 example.ipynb && \
    chown jovyan:users example.ipynb

ENV PYTHON_PACKAGES="\
    matplotlib \
    pandas \
	mplfinance \
" 

RUN pip install --upgrade pip \
    && pip install --no-cache-dir $PYTHON_PACKAGES