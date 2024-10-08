# FROM stackql/stackql:latest AS stackql
# EXPOSE 5444
# WORKDIR /home/stackql
# RUN adduser --system --uid 1001 stackql
# RUN addgroup --system --gid 1001 stackql
# RUN chown stackql:stackql /home/stackql
# RUN chown stackql:stackql /srv
# USER stackql
# # pull stackql providers
# RUN stackql exec 'registry pull aws' || (echo "Failed to pull aws provider" && exit 1)
# RUN stackql exec 'registry pull google' || (echo "Failed to pull google provider" && exit 1)
# RUN stackql exec 'registry pull github' || (echo "Failed to pull github provider" && exit 1)
# RUN stackql exec 'registry pull azure' || (echo "Failed to pull azure provider" && exit 1)
# # RUN stackql exec 'registry pull k8s'
# # RUN stackql exec 'registry pull netlify'
# # RUN stackql exec 'registry pull okta'
# # RUN stackql exec 'registry pull sumologic'
# # RUN stackql exec 'registry pull digitalocean'

# FROM jupyter/base-notebook:latest AS jupyter
# WORKDIR /jupyter
# USER root
# RUN apt-get update && \
#     apt-get upgrade -y
# # copy example notebooks to Jupyter workspace
# COPY ./notebooks/ /jupyter/
# RUN chmod 644 *.ipynb && \
#     chown jovyan:users *.ipynb
# # copy magic extensions
# RUN mkdir -p /jupyter/ext
# COPY ./extensions/* /jupyter/ext
# RUN chmod 644 /jupyter/ext/*.py && \
#     chown jovyan:users /jupyter/ext/*.py
# # copy entrypoint script
# RUN mkdir -p /scripts
# COPY ./scripts/start-server.sh /scripts
# COPY ./scripts/entrypoint.sh /scripts
# RUN chmod +x /scripts/start-server.sh
# RUN chmod +x /scripts/entrypoint.sh
# # set up matplotlib temp dir
# RUN mkdir -p /tmp/matplotlib
# RUN chmod 777 /tmp/matplotlib
# ENV MPLCONFIGDIR=/tmp/matplotlib
# ENV PYDEVD_DISABLE_FILE_VALIDATION=1
# # setup python environment
# ENV PYTHON_PACKAGES="\
#     pystackql>=3.6.4 \
#     matplotlib \
#     pandas \
# 	mplfinance \
#     psycopg2-binary \
#     nest_asyncio \
#     plotly \
#     ipytree \
#     nbformat \
#     networkx \
# " 
# RUN pip install --upgrade pip \
#     && pip install --no-cache-dir $PYTHON_PACKAGES
# # copy stackql providers from stackql container 
# COPY --from=stackql /home/stackql/.stackql /jupyter/.stackql
# RUN ls -al /jupyter/.stackql/src/aws || (echo "aws provider not present" && exit 1)
# RUN ls -al /jupyter/.stackql/src/googleapis.com || (echo "google provider not present" && exit 1)
# RUN ls -al /jupyter/.stackql/src/github || (echo "github provider not present" && exit 1)
# # copy stackql binary from stackql container (service instance)
# COPY --from=stackql /srv/stackql/stackql /srv/stackql/stackql

# Stage 1: StackQL setup
FROM stackql/stackql:latest AS stackql
EXPOSE 5444
WORKDIR /home/stackql
RUN adduser --system --uid 1001 stackql
RUN addgroup --system --gid 1001 stackql
RUN chown stackql:stackql /home/stackql
RUN chown stackql:stackql /srv
USER stackql

# Pull stackql providers
RUN stackql exec 'registry pull aws' || (echo "Failed to pull aws provider" && exit 1)
RUN stackql exec 'registry pull google' || (echo "Failed to pull google provider" && exit 1)
RUN stackql exec 'registry pull github' || (echo "Failed to pull github provider" && exit 1)
RUN stackql exec 'registry pull azure' || (echo "Failed to pull azure provider" && exit 1)

# Stage 2: Jupyter setup
FROM jupyter/base-notebook:latest AS jupyter
WORKDIR /jupyter
USER root
RUN apt-get update && \
    apt-get upgrade -y

# Copy example notebooks to Jupyter workspace
COPY ./notebooks/ /jupyter/
RUN chmod 644 /jupyter/*.ipynb && \
    chown jovyan:users /jupyter/*.ipynb

# Copy magic extensions
RUN mkdir -p /jupyter/ext
COPY ./extensions/* /jupyter/ext/
RUN chmod 644 /jupyter/ext/*.py && \
    chown jovyan:users /jupyter/ext/*.py

# Copy entrypoint script
RUN mkdir -p /scripts
COPY ./scripts/start-server.sh /scripts
COPY ./scripts/entrypoint.sh /scripts
RUN chmod +x /scripts/start-server.sh /scripts/entrypoint.sh

# Set up matplotlib temp dir
RUN mkdir -p /tmp/matplotlib
RUN chmod 777 /tmp/matplotlib
ENV MPLCONFIGDIR=/tmp/matplotlib
ENV PYDEVD_DISABLE_FILE_VALIDATION=1

# Setup python environment
ENV PYTHON_PACKAGES="\
    pystackql>=3.6.4 \
    matplotlib \
    pandas \
    mplfinance \
    psycopg2-binary \
    nest_asyncio \
    plotly \
    ipytree \
    nbformat \
    networkx \
" 
RUN pip install --upgrade pip && pip install --no-cache-dir $PYTHON_PACKAGES

# Copy stackql providers and binary from stackql container
COPY --from=stackql /home/stackql/.stackql /jupyter/.stackql
COPY --from=stackql /srv/stackql/stackql /srv/stackql/stackql

# Ensure providers are present
RUN ls -al /jupyter/.stackql/src/aws || (echo "aws provider not present" && exit 1)
RUN ls -al /jupyter/.stackql/src/googleapis.com || (echo "google provider not present" && exit 1)
RUN ls -al /jupyter/.stackql/src/github || (echo "github provider not present" && exit 1)

# Set user back to default jovyan
USER jovyan

# Set entrypoint
# ENTRYPOINT ["/scripts/entrypoint.sh"]
# CMD ["start-notebook.sh"]
