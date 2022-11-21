FROM stackql/stackql:latest AS stackql
EXPOSE 5444
WORKDIR /home/stackql
RUN adduser --system --uid 1001 stackql
RUN addgroup --system --gid 1001 stackql
RUN chown stackql:stackql /home/stackql
RUN chown stackql:stackql /srv
USER stackql
# pull stackql providers
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
# copy example notebooks to Jupyter workspace
COPY ./notebooks/* /jupyter
RUN chmod 644 *.ipynb && \
    chown jovyan:users *.ipynb
# copy magic extensions
RUN mkdir -p /jupyter/ext
COPY ./extensions/* /jupyter/ext
RUN chmod 644 /jupyter/ext/*.py && \
    chown jovyan:users /jupyter/ext/*.py
# create directory for service account keys
RUN mkdir -p /jupyter/.keys
RUN chmod 644 /jupyter/.keys && \
    chown jovyan:users /jupyter/.keys  
# copy entrypoint script
RUN mkdir -p /scripts
COPY ./scripts/entrypoint.sh /scripts
RUN chmod +x /scripts/entrypoint.sh
# setup python environment
ENV PYTHON_PACKAGES="\
    matplotlib \
    pandas \
	mplfinance \
    psycopg2-binary \
" 
# set stackql auth object
ENV STACKQL_PROVIDER_AUTH="{\
\"aws\": { \"type\": \"aws_signing_v4\", \"credentialsenvvar\": \"AWS_SECRET_ACCESS_KEY\", \"keyIDenvvar\": \"AWS_ACCESS_KEY_ID\" }, \
\"azure\": { \"type\": \"bearer\", \"credentialsenvvar\": \"AZ_ACCESS_TOKEN\" }, \
\"google\": { \"type\": \"service_account\",  \"credentialsfilepath\": \"/jupyter/.keys/google-sa-key.json\" }, \
\"github\": { \"type\": \"basic\", \"credentialsenvvar\": \"GITHUB_CREDS\" }, \
\"okta\": { \"type\": \"api_key\", \"valuePrefix\": \"SSWS \", \"credentialsenvvar\": \"OKTA_SECRET_KEY\" }, \
\"netlify\": { \"type\": \"bearer\", \"credentialsenvvar\": \"NETLIFY_TOKEN\" } \
}"
RUN pip install --upgrade pip \
    && pip install --no-cache-dir $PYTHON_PACKAGES
# copy stackql providers from stackql container 
COPY --from=stackql /home/stackql/.stackql /jupyter/.stackql
# copy stackql binary from stackql container
COPY --from=stackql /srv/stackql/stackql /srv/stackql/stackql