FROM stackql/stackql:latest AS stackql
EXPOSE 5444
WORKDIR /home/stackql
RUN adduser --system --uid 1001 stackql
RUN addgroup --system --gid 1001 stackql
RUN chown stackql:stackql /home/stackql
RUN chown stackql:stackql /srv
USER stackql
RUN stackql exec 'registry pull aws v0.1.3'
RUN stackql exec 'registry pull azure v0.3.0'
RUN stackql exec 'registry pull google v1.0.4'
RUN stackql exec 'registry pull github v0.3.6'
RUN stackql exec 'registry pull k8s v0.1.1'
RUN stackql exec 'registry pull netlify v0.2.0'
RUN stackql exec 'registry pull okta v0.1.0'

FROM jupyter/base-notebook:latest AS jupyter
WORKDIR /jupyter
USER root
RUN apt-get update && \
    apt-get upgrade -y
COPY ./notebooks/* /jupyter
COPY ./extensions/* /jupyter
RUN chmod 644 *.ipynb && \
    chown jovyan:users *.ipynb
RUN chmod 644 *.py && \
    chown jovyan:users *.py
ENV PYTHON_PACKAGES="\
    matplotlib \
    pandas \
	mplfinance \
    psycopg2-binary \
" 
RUN pip install --upgrade pip \
    && pip install --no-cache-dir $PYTHON_PACKAGES
COPY --from=stackql /home/stackql/.stackql /jupyter/.stackql
COPY --from=stackql /srv/stackql/stackql /srv/stackql/stackql