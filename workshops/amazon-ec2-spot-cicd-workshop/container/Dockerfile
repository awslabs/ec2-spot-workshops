FROM jenkins/jenkins:2.361.2-lts-jdk11

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /usr/share/jenkins/ref/casc.yaml

COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli -f /usr/share/jenkins/ref/plugins.txt

COPY casc.yaml /usr/share/jenkins/ref/casc.yaml

WORKDIR /jenkins_seed
RUN curl https://raw.githubusercontent.com/christianhxc/ec2-spot-workshops/cicd-upgrade/workshops/amazon-ec2-spot-cicd-workshop/jobs/seed.tar.gz -o seed.tar.gz \
    && tar -xvf seed.tar.gz \
    && mkdir /usr/share/jenkins/ref/jobs \
    && mv jobs/* /usr/share/jenkins/ref/jobs/