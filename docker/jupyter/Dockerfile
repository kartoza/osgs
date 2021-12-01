# Cloned from https://github.com/anitagraser/EDA-protocol-movement-data/blob/main/docker/Dockerfile
ARG BASE_CONTAINER=jupyter/minimal-notebook
FROM python:3.7
FROM $BASE_CONTAINER
LABEL author="Tim Sutton"

# Installations
USER root
# Copied from 
# https://github.com/anitagraser/EDA-protocol-movement-data/blob/main/docker/Dockerfile#L9
RUN conda install -c conda-forge movingpandas && \
    conda clean --all -f -y && \
    rm -rf /home/$NB_USER/.cache/yarn 
RUN conda install -y -c anaconda psycopg2
RUN conda install -y -c conda-forge geoalchemy2
# Replace the config files from the base image
# with our own that tell jupyter to run in URL
# /jupyter/ instead of in the root path
# so that we can reverse proxy to it nicely
RUN rm /etc/jupyter/jupyter_notebook_config.py  
RUN rm /etc/jupyter/jupyter_server_config.py
ADD jupyter_notebook_config.py /etc/jupyter/jupyter_notebook_config.py  
ADD jupyter_server_config.py /etc/jupyter/jupyter_server_config.py
# Switch back to jovyan to avoid accidental container runs as root
USER $NB_UID
