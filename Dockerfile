FROM jupyter/base-notebook:latest

WORKDIR /work

USER root
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git

RUN git clone https://github.com/stackql/pystackql

ADD ./bin/stackql /work/

RUN mv stackql /bin && \
    chmod +x /bin/stackql 

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