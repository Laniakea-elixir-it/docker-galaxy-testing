FROM laniakeacloud/galaxy:18.05

MAINTAINER ma.tangaro@ibiom.cnr.it

ENV container docker

COPY ["playbook.yaml","/"]

RUN ansible-galaxy install indigo-dc.galaxycloud-tools
RUN ansible-galaxy install indigo-dc.galaxycloud-tooldeps
RUN ansible-galaxy install indigo-dc.cvmfs-client
RUN ansible-galaxy install indigo-dc.galaxycloud-refdata

# Download refdata configuration file
ENV REFDATA_CVMFS_REPOSITORY_NAME=elixir-italy.galaxy.refdata
ADD https://raw.githubusercontent.com/indigo-dc/Reference-data-galaxycloud-repository/master/cvmfs_server_keys/$REFDATA_CVMFS_REPOSITORY_NAME.pub /tmp/$REFDATA_CVMFS_REPOSITORY_NAME.pub
ADD https://raw.githubusercontent.com/indigo-dc/Reference-data-galaxycloud-repository/master/cvmfs_server_config_files/$REFDATA_CVMFS_REPOSITORY_NAME.conf /tmp/$REFDATA_CVMFS_REPOSITORY_NAME.conf

RUN echo "localhost" > /etc/ansible/hosts

# Install tools and configure cvmfs
RUN ansible-playbook /playbook.yaml -e 'GALAXY_VERSION=release_17.05
    refdata_provider_type=cvmfs_preconfigured
    refdata_repository_name=elixir-italy.galaxy.refdata
    refdata_cvmfs_repository_name=elixir-italy.galaxy.refdata'

# This overwrite docker-galaxy CMD line
CMD /bin/mount -t cvmfs ${REFDATA_CVMFS_REPOSITORY_NAME} /cvmfs/${REFDATA_CVMFS_REPOSITORY_NAME}; /usr/local/bin/galaxy-startup; /usr/bin/sleep infinity
